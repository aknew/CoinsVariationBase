#ifndef PICTUREDELEGATE_H
#define PICTUREDELEGATE_H

#include <QItemDelegate>
#include "CVBBaseProvider.h"

class PictureDelegate : public QItemDelegate
{
Q_OBJECT
private:
    CVBBaseProvider *_provider;
public:
  PictureDelegate(CVBBaseProvider *provider, QObject *parent = 0);

  QWidget *createEditor(QWidget *parent, const QStyleOptionViewItem &option, const QModelIndex &index) const;
  void setEditorData(QWidget *editor, const QModelIndex &index) const;
  void setModelData(QWidget *editor, QAbstractItemModel *model, const QModelIndex &index) const;
  void updateEditorGeometry(QWidget *editor, const QStyleOptionViewItem &option, const QModelIndex &index) const;
  void paint(QPainter *painter, const QStyleOptionViewItem &option, const QModelIndex &index) const;

};

#endif // PICTUREDELEGATE_H
