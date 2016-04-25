#include "CBNode.h"

#include <QJsonObject>
#include <QJsonArray>
#include <QtSql>
#include <QDebug>

#include "CBBaseProvider.h"

const QString kWrongString = "*wrongString*"; //< marker that some string wasn't filled

CBNode::CBNode(const QJsonObject &obj, QSqlDatabase &db, QObject *parent) : QObject(parent), db(db), levelFilter(kWrongString,kWrongString)
{

    filter = "";

    // TODO: Добавить проверку что все хорошо прошло, проще здесь найти что таблица называется не так как в struct.json чем отлавливать это в qml
    tableName=obj.value("name").toString();

    //TODO: Need create model only when it used and delete it when we don't use it
    model=new CBSqlRelationalTableModel(this,db);
    model->setEditStrategy(QSqlTableModel::OnManualSubmit);
    model->setTable(this->tableName);
    model->applyRoles();
    _listModel = NULL;

    QJsonValue json_usesUUIDs = obj.value("usesUUIDs");
    if (!json_usesUUIDs.isUndefined()){
        usesUUIDs = json_usesUUIDs.toBool();
    }

    QJsonValue json_useFullForm = obj.value("useFullForm");
    if (!json_useFullForm.isUndefined()){
            useFullForm = json_useFullForm.toBool();
    }

    QJsonValue json_useListForm = obj.value("useListForm");
    if (!json_useListForm.isUndefined()){
            useListForm = json_useListForm.toBool();
    }

    QJsonValue json_listModel = obj.value("listModel");

    if (!json_listModel.isUndefined()){
        _listModel=new CBSqlRelationalTableModel(this,db);
        _listModel->setTable(json_listModel.toString());
        _listModel->applyRoles();
    }

    QJsonValue json_sortColumn = obj.value("sortColumn");
    if (!json_sortColumn.isUndefined()){
        QString sortColumn = json_sortColumn.toString();
        this->model->sortByColumn(sortColumn);
        if (_listModel){
            _listModel->sortByColumn(sortColumn);
        }
    }


    QJsonArray json_childNodes = obj.value("childNode").toArray();
    foreach (QJsonValue value1,json_childNodes) {        
        if (value1.isString()){
            this->childNodes.insert(
                        value1.toString(),
                        "parentId"
                        );
        }
        else{

            QJsonObject obj=value1.toObject();
            this->childNodes.insert(
                    obj.value("name").toString(),
                    obj.value("relation").toString()
                    );
        }
    }

    // TODO: need generate listViewFields and fullFormFields only when it need if it doesn't exists into json
    QJsonValue  json_listViewFields = obj.value("listViewFields");
    if ( json_listViewFields.isArray()){
        this->listViewFields = json_listViewFields.toVariant();
    }
    else {
        this->listViewFields =this->model->fieldList;
    }

    QJsonValue json_fullFormFields = obj.value("fullFormFields");

    if ( json_fullFormFields.isArray()){
        this->fullFormFields =  json_fullFormFields.toVariant();
    }
    else {
        this->fullFormFields =this->model->fieldList;
    }
}

QObject *CBNode::listModel(){
    if (_listModel){
        return _listModel;
    }
    else{
        return model;
    }
}

QString CBNode::listFormName(){
    return tableName+"List.qml";
}

QString CBNode::fullFormName(){
    return tableName+"Full.qml";
}

QPair<QString, QString> CBNode::filterForChildNode(const QString& childNodeName){
    QString str=childNodes.value(childNodeName);
    if (str==""){
        return QPair<QString, QString>(kWrongString,kWrongString);
    }
    return QPair<QString, QString>(str,model->selectedItemId());
}

void CBNode::setLevelFilter(const QPair<QString, QString> &filter){
    levelFilter = filter;
    applyFilters();
}

void CBNode::addFilter(const QString &filterString){
    filter = filterString;
    applyFilters();
}

void CBNode::dropFilter(){
    filterList = NULL;
    filter = "";
    applyFilters();
}

void CBNode::applyFilters(){

    QString fullFilterString = filter;

    QString s_levelFilter  = kWrongString;

    if (levelFilter.first!=kWrongString){
        s_levelFilter = levelFilter.first + "=\"" + levelFilter.second + "\"";
    }
    if (s_levelFilter!=kWrongString){
        if (filter == ""){
            fullFilterString = s_levelFilter;
        }
        else{
            fullFilterString = s_levelFilter + " and " + fullFilterString;
        }
    }

    model->setFilter(fullFilterString);
    model->select();

    if(_listModel){
        _listModel->setFilter(fullFilterString);
        _listModel->select();
    }

}

QStringList CBNode::listFromQuery(QString queryString){

    QSqlQuery query(db);

    bool flag = query.exec(queryString);

    if (!flag){
        qDebug()<<query.lastError();
    }

    QStringList list;
    list << "";
    while (query.next()) {
        QString str = query.value(0).toString();
        // HOTFIX: For default empty string. I don't use sql condition because I don't want to add
        // restrictions to query field of struct json
        if (str == ""){
           continue;
        }
        list<<str;
    }

    return list;

}

void CBNode::selectItemWithID(const QString &selID)
{
    for (int i = 0; i< model->rowCount(); ++i){
        QSqlRecord record=model->record(i);
        QSqlField id=record.field("id");
        if (id.value().toString() == selID){
            model->selectedRow =i;
            return;
        }
    }
    //XXX: Maybe not best practice, rewrite with exaption?
    qWarning()<<"There is no record with id "<<selID;
}

void CBNode::selectItemWithIndex(int index){
    if (_listModel && !insertingNewRow){
        _listModel->selectedRow = index;
        QString selId = _listModel->selectedItemId();
        selectItemWithID(selId);
    }
    else{
        model->selectedRow = index;
    }
    emit idWasSelected(model->selectedItemId());

}

void CBNode::prepareToNewItem(){
    insertingNewRow = true;

    QSqlRecord record;

    if(levelFilter.first!=kWrongString){
        // add filters - foreign keys
        QSqlField f1(levelFilter.first, QVariant::String);
        f1.setValue(QVariant(levelFilter.second));
        record.append(f1);
    }
    if(usesUUIDs){
        QSqlField f1("id", QVariant::String);
        QUuid u=QUuid::createUuid();
        f1.setValue(QVariant(u.toString()));
        record.append(f1);
    }
    if (!model->insertRecord(-1, record)){
        qDebug()<<model->lastError();
    }

    selectItemWithIndex(model->rowCount()-1);
}

void CBNode::cloneItem(){
    insertingNewRow = true;
    QSqlRecord record = model->record(model->selectedRow);
    if(usesUUIDs){
        QSqlField f1("id", QVariant::String);
        QUuid u=QUuid::createUuid();
        f1.setValue(QVariant(u.toString()));
        record.append(f1);
    }
    if (!model->insertRecord(-1, record)){
        qDebug()<<model->lastError();
    }

    selectItemWithIndex(model->rowCount()-1);
}

void CBNode::applyChanges(QVariantMap changedItem){
    QString uuid = model->selectedItemId();
    model->setSelectedItem(changedItem);
    selectItemWithID(uuid);
    if (insertingNewRow){
        insertingNewRow = false;
    }
    if (_listModel){
        _listModel->select();
        emit dataChanged();
    }
}

void CBNode::dropChanges(){
    if (insertingNewRow){
       insertingNewRow = false;
       model->removeCurrentItem();
    }
}

void CBNode::deleteSelectedItem(){
    // FIXME: rename from delete to remove
    if (usesUUIDs){
        emit currentItemWillBeRemoved();
    }

    model->removeCurrentItem();
    if (_listModel){
        _listModel->select();
        emit dataChanged();
    }
}
