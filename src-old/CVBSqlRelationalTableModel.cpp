#include "CVBSqlRelationalTableModel.h"
#include <QDebug>
#include <QtSql>

//based on http://qt-project.org/wiki/How_to_use_a_QSqlQueryModel_in_QML

void CVBSqlRelationalTableModel::applyRoles()
{
    roles.clear();
    //qDebug()<<"\n"<<this->tableName();
    QStringList fields;
    for (int i = 0; i < this->columnCount(); i++) {
            QString role=this->headerData(i, Qt::Horizontal).toString();
            roles[Qt::UserRole + i + 1] = QVariant(role).toByteArray();
            //qDebug()<<this->headerData(i, Qt::Horizontal);
            fields.append(role);
    }
    fieldList=QVariant(fields);
}

void CVBSqlRelationalTableModel::sortByColumn(const QString &columnName){
    for (int i = 0; i < this->columnCount(); i++) {
        QString role=this->headerData(i, Qt::Horizontal).toString();
        if (role == columnName){
            this->sort(i,Qt::AscendingOrder);
            return;
        }
    }
    //XXX: Maybe not best practice
    qDebug()<<"Wrong sort column name: "<<columnName;
}

QVariant CVBSqlRelationalTableModel::data(const QModelIndex &index, int role= Qt::DisplayRole ) const{

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

QVariantMap CVBSqlRelationalTableModel::selectedItem(){

    QVariantMap myMap;
    QSqlRecord record=this->record(selectedRow);

    for (int i=0;i<record.count();++i){
        myMap[record.fieldName(i)]=record.field(i).value();
    }
    return myMap;
}

void CVBSqlRelationalTableModel::setSelectedItem(const QVariantMap &map){
    //FIXME: refactoring is needed
    QSqlRecord record=this->record(selectedRow);
    QStringList keys=map.keys();
    for (int i=0;i<keys.count();++i){
        record.setValue(keys[i],map[keys[i]]);
    }
    if (selectedRow==this->rowCount()){
        this->insertRecord(selectedRow,record);
    }
    else
        this->setRecord(selectedRow,record);
    this->submitAll();

}

void CVBSqlRelationalTableModel::removeCurrentItem(){
    this->removeRow(this->selectedRow);
    this->submitAll();
}
