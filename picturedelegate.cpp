#include "picturedelegate.h"
#include <QFileDialog>
#include <QPainter>

PictureDelegate::PictureDelegate(CVBBaseProvider *provider, QObject *parent)
:_provider(provider),QItemDelegate(parent)
{
}


QWidget *PictureDelegate::createEditor(QWidget *parent, const QStyleOptionViewItem &/* option */, const QModelIndex &/* index */) const
{
    //TODO переделать picture delegate чтобы при нажатии на него показывался виджет с полной картинкой
    //TODO найти filedialog с препросмотром картинки
    QFileDialog *editor=new QFileDialog(parent,"Select file");
    return editor;
}

void PictureDelegate::setEditorData(QWidget *editor, const QModelIndex &index) const
{
}

void PictureDelegate::setModelData(QWidget *editor, QAbstractItemModel *model, const QModelIndex &index) const
{
  QFileDialog *dialog = static_cast<QFileDialog*>(editor);
  QStringList filenames=dialog->selectedFiles();
  if (filenames.count()!=0){
      QFile file(filenames.at(0));

      if (!file.open(QIODevice::ReadOnly)) return;
      QByteArray byteArray = file.readAll();

      model->setData(index, _provider->idForAttach(byteArray), Qt::EditRole);
  }
}

void PictureDelegate::updateEditorGeometry(QWidget *editor, const QStyleOptionViewItem &option, const QModelIndex &/* index */) const
{
  //editor->setGeometry(option.rect);
}


void PictureDelegate::paint(QPainter *painter, const QStyleOptionViewItem &option, const QModelIndex &index) const
{
  QStyleOptionViewItemV4 myOption = option;
  QPixmap pcx;
  pcx.loadFromData(_provider->attachForId(index.model()->data(index).toString()));
  double scaleH=pcx.rect().height()/(double)myOption.rect.height();
  double scaleW=pcx.rect().width()/(double)myOption.rect.width();
  double scaleFactor=(scaleW>scaleH)?scaleW:scaleH;
  QRect rect=QRect(myOption.rect.x(),myOption.rect.y(),pcx.rect().width()/scaleFactor,pcx.rect().height()/scaleFactor);
  painter->save();
  painter->drawPixmap(rect,pcx);
  painter->restore();
}

