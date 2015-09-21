#include "CBNode.h"

#include <QJsonObject>
#include <QJsonArray>

const QString kWrongString = "*wrongString*"; //< marker that some string wasn't filled

CBNode::CBNode(const QJsonObject &obj, QSqlDatabase &db, QObject *parent) : QObject(parent)
{
    levelFilter = kWrongString;

    // TODO: Добавить проверку что все хорошо прошло, проще здесь найти что таблица называется не так как в struct.json чем отлавливать это в qml
    tableName=obj.value("name").toString();

    //FIXME: Cтоит создавать модели только тогда, когда они нужны и выгружать потом
    model=new CBSqlRelationalTableModel(this,db);
    model->setTable(this->tableName);
    model->applyRoles();
    //filterParam.first = kNotValidPair;
    _listModel = NULL;

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
        QJsonObject obj=value1.toObject();
        this->childNodes.insert(
                    obj.value("name").toString(),
                    obj.value("relation").toString()
                    );
    }

    QJsonArray json_subNodes = obj.value("subNodes").toArray();
    foreach (QJsonValue value1,json_subNodes) {
        if (value1.isString()){
            this->m_subNodesParameters.insert(
                        value1.toString(),
                        "parentId"
                        );
        }
        else{
            QJsonObject obj=value1.toObject();
            this->m_subNodesParameters.insert(
                        obj.value("name").toString(),
                        obj.value("relation").toString()
                        );
        }
    }

    // FIXME: need generate listViewFields and fullFormFields only when it need if it doesn't exists into json
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

QString CBNode::filteringStringForChildNode(const QString& childNodeName){
    QString str=childNodes.value(childNodeName);
    if (str!=""){
        str = str + "=\"" + model->selectedItemId() + "\"";
    }
    return str;
}

void CBNode::setLevelFilter(const QString &filterString){
    levelFilter = filterString;
    applyFilters();
}

void CBNode::addFilter(const QString &filterString){
    filters.append(filterString);
    applyFilters();
}

void CBNode::dropFilters(){
    filters.clear();
    applyFilters();
}

void CBNode::applyFilters(){
    QString fullFilterString = filters.join(" and ");

    if (levelFilter!=kWrongString){
        if (filters.isEmpty()){
            fullFilterString = levelFilter;
        }
        else{
            fullFilterString = levelFilter + " and " + fullFilterString;
        }
    }

    // TODO: need analyze what it will happend if we will use filter that is defined only in one of models
    model->setFilter(fullFilterString);
    model->select();

    if(_listModel){
        _listModel->setFilter(fullFilterString);
        _listModel->select();
    }

}
