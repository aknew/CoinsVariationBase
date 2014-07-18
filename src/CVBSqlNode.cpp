#include "CVBSqlNode.h"

CVBSqlNode::CVBSqlNode(const QJsonObject &obj,  QSqlDatabase &db){

    this->tableName=obj.value("name").toString();
    //FIXME: Cтоит создавать модели только тогда, когда они нужны и выгружать потом
    this->model=new CVBSqlRelationalTableModel(this,db);
    this->model->setTable(this->tableName);
    this->model->applyRoles();

    listModel = NULL;

    QJsonValue json_listModel = obj.value("listModel");

    if (!json_listModel.isUndefined()){
        this->listModel=new CVBSqlRelationalTableModel(this,db);
        this->listModel->setTable(json_listModel.toString());
        this->listModel->applyRoles();
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
        QJsonObject obj=value1.toObject();
        this->subNodes.insert(
                    obj.value("name").toString(),
                    obj.value("relation").toString()
                    );
    }

    QJsonValue  json_rowParameters = obj.value("rowParamNames");// FIXME: древний костыль, надо исправить, а может при изменении структуры базы и сам уйдет
    if ( json_rowParameters.isArray()){
        foreach (QJsonValue value, json_rowParameters.toArray()) {
            QJsonObject obj=value.toObject();
            this->rowParamNames.push_back(obj.value("name").toString());
        }
    }
    else{
        QJsonObject obj= json_rowParameters.toObject();
        this->rowParamNames.push_back(obj.value("name").toString());
    }

    this->fullFormName = obj.value("fullForm").toString();

    this->listFormName = obj.value("listForm").toString();

    QJsonValue  json_listViewFields = obj.value("listViewFields");
    if ( json_listViewFields.isArray()){
        this->listViewFields = new QStringList();
        foreach (QJsonValue value, json_listViewFields.toArray()) {
            this->listViewFields->append(value.toString());
        }
    }

    QJsonValue json_fullFormFields = obj.value("fullFormFields");

    if ( json_fullFormFields.isArray()){
        this->fullFormFields =  json_fullFormFields.toVariant();
    }
    else {
        this->fullFormFields =this->model->fieldList;
    }
}


QVariant CVBSqlNode::getListViewFields(){
    if (this->listViewFields && this->listViewFields->count()>0)
        return QVariant(*this->listViewFields);
    else{
        return this->model->fieldList;
    }
}
