#include "delegatedtableview.h"
#include "comboboxdelegate.h"
#include "picturedelegate.h"
#include <QHeaderView>
#include <QMenu>

DelegatedTableView::DelegatedTableView(QWidget *parent) :
    QTableView(parent)
{
}

void DelegatedTableView::setBaseProvider(CVBBaseProvider *baseProvider){

    _baseProvider=baseProvider;
    CVBSqlNode *_node=_baseProvider->currentNode();

    this->setModel(_node->model);

    //_node->model->setEditStrategy(QSqlTableModel::OnManualSubmit);
    setSortingEnabled(true);
    sortByColumn(_node->defaultSortColumn ,Qt::AscendingOrder);

    QVector < QPair<int,QString> > *delegates=& _node->comboDelegates;
    for (int i=0;i<delegates->count();++i){
        QPair<int,QString> currentPair=delegates->at(i);
        ComboBoxDelegate *combo=new ComboBoxDelegate(this);
        combo->Items=baseProvider->listForID(currentPair.second);
        setItemDelegateForColumn(currentPair.first, combo);
    }

    if(_node->height!=-1)
        this->verticalHeader()->setDefaultSectionSize(_node->height);

    if(_node->columnWidth){
        for (int i=0; i<_node->columnWidth->count();++i)
            setColumnWidth(i,_node->columnWidth->at(i));
    }
    else
        resizeColumnsToContents();

    int pictDelegate=_node->pictDelegate;
    if (pictDelegate!=-1){
        setItemDelegateForColumn(pictDelegate,new PictureDelegate(_baseProvider));
    }

    this->setContextMenuPolicy(Qt::CustomContextMenu);
    connect(this,SIGNAL(customContextMenuRequested(QPoint)),this,SLOT(showNextLevelMenu(QPoint)));
    /*
    coinsTable->setSelectionBehavior( QAbstractItemView::SelectRows );
    //QObject::connect(coinsTable,SIGNAL(doubleClicked(QModelIndex)),parent,SLOT(fullInfo(QModelIndex)));
    QObject::connect(coinsTable->model(),SIGNAL(dataChanged(QModelIndex,QModelIndex)),this,SLOT(DataChanged()));
    QObject::connect(coinsTable->horizontalHeader(),SIGNAL(sectionDoubleClicked(int)),this,SLOT(headerRightClick()));
    connect(coinsTable,SIGNAL(doubleClicked(QModelIndex)),this,SLOT(cellDoubleClicked(QModelIndex)));
    */

}

void DelegatedTableView::showNextLevelMenu(const QPoint &pos){
    QModelIndex modelIndex=this->indexAt(pos);
    qDebug()<<"clicked";
    _baseProvider->currentNode()->model->selectedRow=modelIndex.row();
    QMenu myMenu;
    QStringList items=_baseProvider->buttonIDs();
    for (int i=0;i<items.count();++i){
        myMenu.addAction(items.at(i));
    }
    QAction* selectedItem = myMenu.exec(pos);
    if (selectedItem)
    {
        int k=items.indexOf(selectedItem->text());
        _baseProvider->pressedButton(k);
    }
}

/*

QModelIndexList CoinsTableWidget::selectionList(){
    return coinsTable->selectionModel()->selectedRows();
}

void CoinsTableWidget::needSaveData(){
    if (dataWasChanged){
        if(QMessageBox::question(this,"Unsaved data",
                                 "There is changed data. Would you apply change or cancel it?",
                                 QMessageBox::Apply,QMessageBox::Cancel)==QMessageBox::Apply){
            if (!((QSqlTableModel *)coinsTable->model())->submitAll())
                qDebug()<<((QSqlTableModel *)coinsTable->model())->lastError();
        }
        else
            ((QSqlTableModel *)coinsTable->model())->revertAll();
        dataWasChanged=false;
    }
}

void CoinsTableWidget::setDataChanged(bool flag){
    dataWasChanged=flag;
}

void CoinsTableWidget::DataChanged(){
    dataWasChanged=true;
}

void CoinsTableWidget::headerRightClick(){
    QStringList columns;
    unsigned int visibleMask=0;
    QSqlTableModel * model=(QSqlTableModel *)coinsTable->model();
    for (int i=0;i<model->columnCount();++i){
        columns.append(model->headerData(i, Qt::Horizontal, Qt::DisplayRole).toString());
        unsigned int k=coinsTable->isColumnHidden(i)<<i;
        visibleMask=visibleMask | k;
    }
    ShowColumnDialog *dialog= new ShowColumnDialog(columns,visibleMask);
    dialog->show();
    connect(dialog,SIGNAL(closeWithByteArray(uint)),this,SLOT(dialogClose(uint)));
}


void CoinsTableWidget::dialogClose(unsigned int mask){
    unsigned int visibleMask=1;
    QSqlTableModel * model=(QSqlTableModel *)coinsTable->model();
    for (int i=0;i<model->columnCount();++i){
        bool k=(visibleMask & mask)==0;
        coinsTable->setColumnHidden(i,k);
        visibleMask=visibleMask*2;
    }
}

void CoinsTableWidget::cellDoubleClicked(QModelIndex modelIndex){
    QSqlTableModel * model=(QSqlTableModel *)coinsTable->model();
    QSqlRecord record=model->record(modelIndex.row());
    //FIXME временно делаю так чтобы посмотреть как все это будет работать
    if (record.fieldName(modelIndex.column())!="hyperlink")
        return;
    QUrl url(record.field(modelIndex.column()).value().toString());
    QDesktopServices::openUrl(url);
}

void CoinsTableWidget::actionButtonClicked(){
    ButtonsDialog *dialog =new ButtonsDialog(this);
    dialog->initButtons(this->buttonList(),mainWindow);
    dialog->show();
}

*/
