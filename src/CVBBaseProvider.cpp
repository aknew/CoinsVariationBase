#include "CVBBaseProvider.h"

CVBBaseProvider::CVBBaseProvider(QString pathPath, QObject *parent) :
    QObject(parent)
{
/*
    *FIXME: name basePath is legacy - in very old version it was only db file, all struct was hardcoded and tables were
    *shown into QTableView. pathPath is typo. There is no any reasons using it now

*/
    basePath = pathPath;
    pathPath.append("base.sqlite");

    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(pathPath);
    if (!db.open()) {
        qDebug() << "Cannot open database:" << db.lastError();
    }

    //enable foreign key
    QSqlQuery query=QSqlQuery(db);
    query.exec("PRAGMA foreign_keys = ON;");

    this->parse();
}

CVBBaseProvider::~CVBBaseProvider(){
    db.close();
}

QStringList CVBBaseProvider::listForID(const QString &name){

    QStringList list;

    qDebug()<<name;
    //qDebug()<<"comboBoxes.keys()="<<comboBoxes.keys();

    ComboBoxDescription desc=comboBoxes[name];

    QSqlQuery query;
    QString str=desc.query;

    if (desc.params.count()!=0){
        /*
         *здесь мы добавляем значения в запрос, теоретически должно работать для любого числа,
         *но пока больше одного мне не нужно было и не проверлось
         */
        for (int i=0;i<desc.params.count();++i){
            QStringList params=desc.params.at(i).split(".");
            qDebug()<<params;
            if (params.count()!=2){
                QVariantMap map=currentNode()->model->selectedItem();
                str=str.arg(map[desc.params.at(i)].toString());
                continue;

            }
            QVariantMap map=nodeMap.value(params[0])->model->selectedItem();
            str=str.arg(map[params[1]].toString());
        }
    }
    qDebug()<<str;
    query.exec(str);

    while (query.next()) {
        list<<query.value(0).toString();
    }

    return list;

}

void CVBBaseProvider::previousLevel(){
    if (nodeStack.count()<=1)
        return;
    //FIXME хак для удаления параметров для внешних ключей - весь механизм работы с ними не верен
    qDebug()<<"Before:\n"<<ids;
    QString buttonID=currentNode()->tableName;
    nodeStack.pop();
    QString str=currentNode()->childNodes.value(buttonID);
    if (str!=""){
        ids.remove(str);
    }
    qDebug()<<"After:\n"<<ids;
    emit removeCurrentWidget();
}

void CVBBaseProvider::startLevel(){
    CVBSqlNode *node=nodeMap.value(startTable);
    if (node){
        node->model->select();
        nodeStack.push(node);
        emit newTableWidget();
    }
}

void CVBBaseProvider::loadSystemTables(const QString &name){
    CVBSqlNode *node=nodeMap.value(name);
    if (node){
        node->model->select();
        nodeStack.push(node);
        emit newTableWidget();
    }
}

QStringList CVBBaseProvider::buttonIDs(){
    QStringList buttonIDs=currentNode()->childNodes.keys();

    return buttonIDs;
}

void CVBBaseProvider::pressedButton(int index){


    CVBSqlNode *currentNode=nodeStack.top();
    int rowIndex = currentNode->model->selectedRow;
    QString buttonID=buttonIDs().at(index);
    CVBSqlNode *node=nodeMap.value(buttonID);
    if (node){
        QString str=currentNode->childNodes.value(buttonID);
        if (str!=""){
            QSqlRecord record=currentNode->model->record(rowIndex);
            QSqlField id=record.field("id");
            QString str1="%1=%2";
            // XXX: Need refactoring
            str1 = str1.arg(str).arg(id.value().toString());
            node->model->setFilter(str1);
            if (node->listModel){
                node->listModel->setFilter(str1);
            }
            ids.insert(str,id.value().toString());
        }
        if (node->listModel){
            node->listModel->select();
            qDebug()<<node->listModel->rowCount();
        }
        node->model->select();
        qDebug()<<node->model->filter();
        qDebug()<<node->model->rowCount();
        nodeStack.push(node);
        emit newTableWidget();
    }
}

void CVBBaseProvider::addForeignKeyToMap(QVariantMap &map){
    qDebug()<<map;
    CVBSqlNode *currentNode=nodeStack.top();
    for (int i=0;i<currentNode->rowParamNames.count();++i){
        QString str=ids.value(currentNode->rowParamNames.at(i));
        map[currentNode->rowParamNames.at(i)]=str;
    }
    qDebug()<<"after addForeignKeyToMap "<<map;
}

void CVBBaseProvider::deleteCurrentRow(){
    CVBSqlNode *currentNode=nodeStack.top();
    currentNode->model->removeCurrentItem();
}

CVBSqlNode *CVBBaseProvider::currentNode(){
    return nodeStack.top();
}

QString CVBBaseProvider::idForAttach(QByteArray attach){

    QString md5=QCryptographicHash::hash(attach,QCryptographicHash::Md5).toHex();

    //TODO Сделать здесь проверку на наличие картинки в базе и только если нет переписывать
    QSqlQuery query;

    query.prepare("insert into attachStorage(attach) values(?)");
    query.bindValue(0,md5);
    if (!query.exec())
        qDebug()<<query.lastError();
    query.prepare("select id from attachStorage where attach=?");
    query.bindValue(0,md5);
    if (!query.exec())
        emit getError(query.lastError().text());
    if (query.next()){
            QString id=query.value(0).toString();
            QString str="%1images/%2";
            QFile file(str.arg(basePath).arg(id));

            if (!file.open(QIODevice::WriteOnly)) return "NULL";
            file.write(attach);
            return id;
    }
    else return "NULL";
}

QByteArray CVBBaseProvider::attachForId(QString id){
    QString str="%1images/%2";
    QFile file(str.arg(basePath).arg(id));

    if (!file.open(QIODevice::ReadOnly)) return NULL;
    QByteArray byteArray = file.readAll();
    return byteArray;
}

QAbstractItemModel *CVBBaseProvider::getModelWithName(const QString& name){
    CVBSqlNode *node=nodeMap.value(name);
    if (node){
        QString str=currentNode()->childNodes.value(name);
        if (str!=""){
            QString str1="%1=%2";
            node->model->setFilter(str1
                                   .arg(str)
                                   .arg(currentNode()->model->selectedItem()["id"].toString())
                    );
        }
        node->model->select();
        qDebug()<<node->model->filter();
        qDebug()<<node->model->rowCount();
    }
    return node->model;
}

void CVBBaseProvider::parse(){

    QString filename=basePath+"struct.json";

    qDebug()<<"parser start - ok";
     QFile file(filename);
     if (!file.open(QIODevice::ReadOnly)){
         qDebug() << "Cannot open json";
         exit(-1);
     }
     QString jsonData = file.readAll();
     file.close();

     QJsonDocument sd = QJsonDocument::fromJson(jsonData.toUtf8());

     if (sd.isNull()){
         qDebug() << "Wrong file format";
         exit(-1);
     }
     QJsonObject baseStruct = sd.object();
     qDebug() << baseStruct.value(QString("name"));

     startTable = baseStruct.value("startTable").toString();

     QJsonArray nodes = baseStruct.value("nodes").toArray();

     foreach (QJsonValue value1,nodes) {
         QJsonObject obj=value1.toObject();

         CVBSqlNode *node=new CVBSqlNode();
         node->tableName=obj.value("name").toString();
         //FIXME Cтоит создавать модели только тогда, когда они нужны и выгружать потом
         node->model=new CVBSqlRelationalTableModel(this,db);
         node->model->setTable(node->tableName);
         node->model->applyRoles();

         QJsonValue listModel = obj.value("listModel");

         if (!listModel.isUndefined()){
             node->listModel=new CVBSqlRelationalTableModel(this,db);
             node->listModel->setTable(listModel.toString());
             node->listModel->applyRoles();
         }

         bool isSystem=obj.value("isSystem").toBool();

         if (isSystem){
             systemTables.append(node->tableName);
         }

         QJsonArray childNodes = obj.value("childNode").toArray();
         foreach (QJsonValue value1,childNodes) {
             QJsonObject obj=value1.toObject();
             node->childNodes.insert(
                         obj.value("name").toString(),
                         obj.value("relation").toString()
                         );
         }

         QJsonArray subNodes = obj.value("subNodes").toArray();
         foreach (QJsonValue value1,subNodes) {
             QJsonObject obj=value1.toObject();
             node->subNodes.insert(
                         obj.value("name").toString(),
                         obj.value("relation").toString()
                         );
         }

         QJsonValue rowParameters = obj.value("rowParamNames");// FIXME: древний костыль, надо исправить, а может при изменении структуры базы и сам уйдет
         if (rowParameters.isArray()){
             foreach (QJsonValue value,rowParameters.toArray()) {
                 QJsonObject obj=value.toObject();
                 node->rowParamNames.push_back(obj.value("name").toString());
             }
         }
         else{
             QJsonObject obj=rowParameters.toObject();
             node->rowParamNames.push_back(obj.value("name").toString());
         }

         node->fullFormName = obj.value("fullForm").toString();

         node->listFormName = obj.value("listForm").toString();

         QJsonValue listViewFields = obj.value("listViewFields");
         if (listViewFields.isArray()){
             node->listViewFields = new QStringList();
             foreach (QJsonValue value,listViewFields.toArray()) {
                 node->listViewFields->append(value.toString());
             }
         }

         QJsonValue fullFormFields = obj.value("fullFormFields");

         if (fullFormFields.isArray()){
             node->fullFormFields = fullFormFields.toVariant();
         }
         else {
             node->fullFormFields =node->model->fieldList;
         }

         nodeMap.insert(node->tableName,node);
     }

     nodes = baseStruct.value("comboBoxes").toArray();

     foreach (QJsonValue value,nodes) {

         QJsonObject obj=value.toObject();

         ComboBoxDescription desc;

         desc.query=obj.value("query").toString();

         QString param=obj.value("param").toString();
         if (!param.isEmpty())
             desc.params.push_back(param);
         comboBoxes[obj.value("name").toString()]=desc;
     }
}
