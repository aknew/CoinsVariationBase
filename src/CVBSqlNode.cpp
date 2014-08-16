#include "CVBSqlNode.h"
#include "CVBBaseProvider.h"

CVBSqlNode::CVBSqlNode(const QJsonObject &obj,  QSqlDatabase &db, QObject *parent = 0):QObject(parent){

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
        this->m_subNodesParameters.insert(
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

 QObject* CVBSqlNode::getListModel(){
     if (listModel){
         return listModel;
     }
     else{
         return model;
     }
 }

void CVBSqlNode::selectItemWithIndex(int index){
    /*! \brief This method prepares subnodes and model for showing data with index
     */
    if (index == kNewRowIndex){
        index = model->rowCount();
    }

     model->selectedRow = index;

     m_subNodes.clear();
     CVBBaseProvider * baseProvider= qobject_cast<CVBBaseProvider *>(parent());
     QMap<QString, QString>::iterator iterator;
     QString id = selectedItem()["id"].toString();
     for (iterator = m_subNodesParameters.begin(); iterator != m_subNodesParameters.end(); ++iterator){
         CVBSqlNode *node=baseProvider->nodeWithName(iterator.key());
         if (node){
             QString str1="%1=%2";
             node->model->setFilter(str1
                                    .arg(iterator.value())
                                    .arg(id)
                                    );
             node->model->select();
             m_subNodes.append(node);
         }
     }
}
