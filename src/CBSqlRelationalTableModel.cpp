#include "CBSqlRelationalTableModel.h"
#include <QDebug>
#include <QtSql>

//based on http://qt-project.org/wiki/How_to_use_a_QSqlQueryModel_in_QML

void CBSqlRelationalTableModel::applyRoles()
{
    roles.clear();
    for (int i = 0; i < this->columnCount(); i++) {
            QString role=this->headerData(i, Qt::Horizontal).toString();
            roles[Qt::UserRole + i + 1] = QVariant(role).toByteArray();
            fieldList.append(role);
    }
}

void CBSqlRelationalTableModel::sortByColumn(const QString &columnName, Qt::SortOrder order){
    for (int i = 0; i < this->columnCount(); i++) {
        QString role=this->headerData(i, Qt::Horizontal).toString();
        if (role == columnName){
            this->sort(i,order);
            return;
        }
    }
    //XXX: Maybe not best practice
    qDebug()<<"Wrong sort column name: "<<columnName;
}

QVariant CBSqlRelationalTableModel::data(const QModelIndex &index, int role= Qt::DisplayRole ) const{

    QVariant value;
    if(role < Qt::UserRole)
    {
        value = QSqlRelationalTableModel::data(index, role);
    }
    else {
        int columnIdx = role - Qt::UserRole - 1;
        QModelIndex modelIndex = this->index(index.row(), columnIdx);
        value = QSqlRelationalTableModel::data(modelIndex, Qt::DisplayRole);
    }
    return value;
}

QVariantMap CBSqlRelationalTableModel::selectedItem(){
    return itemForRow(selectedRow);
}

QVariantMap CBSqlRelationalTableModel::itemForRow(int index){
    QVariantMap myMap;
    QSqlRecord record=this->record(index);

    for (int i=0;i<record.count();++i){
        myMap[record.fieldName(i)]=record.field(i).value();
    }
    return myMap;
}

void CBSqlRelationalTableModel::setSelectedItem(const QVariantMap &map){

    QSqlRecord record=this->record(selectedRow);
    QStringList keys=map.keys();
    for (int i=0;i<keys.count();++i){
        record.setValue(keys[i],map[keys[i]]);
        record.setGenerated(keys[i],true);
    }
    bool flag = this->setRecord(selectedRow,record);
    if (!flag){
        qDebug()<<this->lastError();
    }
    flag = this->submitAll();
    if (!flag){
        qDebug()<<this->lastError();
    }

}

void CBSqlRelationalTableModel::removeCurrentItem(){
    this->removeRow(this->selectedRow);
    this->submitAll();
}

QString CBSqlRelationalTableModel::selectedItemId(){
    QSqlRecord record=this->record(selectedRow);
    QSqlField id=record.field("id");
    return id.value().toString();
}
