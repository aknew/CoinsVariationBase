#include "CBBaseProvider.h"
#include "CBUtils.h"

void CBBaseProvider::startWithPath(const QString &path){

    rootPath = path + "/";

    // open sqlite base

    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(rootPath + "base.sqlite");
    if (!db.open()) {
        // FIXME: need cleanup logging and excapting
        qDebug() << "Cannot open database:" << db.lastError();
        exit(-1);
    }

    //enable foreign key
    QSqlQuery query=QSqlQuery(db);
    query.exec("PRAGMA foreign_keys = ON;");

    // parse ifo about base struct from json

    QString filename=rootPath+"struct.json";

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
        qDebug()<<"Wrong file json format";
        exit(-1);
     }
     QJsonObject baseStruct = sd.object();
     m_baseTitle = baseStruct.value("baseTitle").toString();

     startTable = baseStruct.value("startTable").toString();

     QJsonArray nodes = baseStruct.value("nodes").toArray();

     foreach (QJsonValue value1,nodes) {
         QJsonObject obj=value1.toObject();

         CBNode *node=new CBNode(obj,db, this);
         //bool isSystem=obj.value("isSystem").toBool();

//         if (isSystem){
//             systemTables.append(node->tableName);
//         }

         nodeMap.insert(node->tableName,node);
     }

//     nodes = baseStruct.value("comboBoxes").toArray();

//     foreach (QJsonValue value,nodes) {

//         QJsonObject obj=value.toObject();

//         ComboBoxDescription desc;

//         desc.query=obj.value("query").toString();

//         QString param=obj.value("param").toString();
//         if (!param.isEmpty())
//             desc.params.push_back(param);
//         comboBoxes[obj.value("name").toString()]=desc;
//     }

    // create imageProvider

//    imageProvider= new CVBImageProvider(QQuickImageProvider::Pixmap);
//    imageProvider->imageFolder=basePath+"images/";

     emit readyToWork();
}

 CBNode* CBBaseProvider::getNode(const QString &name, CBNode * currentNode){
    CBNode *node = nodeMap[name];
    if (currentNode){ // I.e. it is not start node
        QString filterString =currentNode->filteringStringForChildNode(name);
        node->setLevelFilter(filterString);
    }
    return node;
}

 void CBBaseProvider::saveListForm(const QString& qmlString, CBNode *node){
     QString filePath=rootPath+"forms/"+node->listFormName();
     CBUtils::SaveStringToFile(qmlString,filePath);
 }

 void CBBaseProvider::saveFullForm(const QString& qmlString, CBNode *node){
     QString filePath=rootPath+"forms/"+node->fullFormName();
     CBUtils::SaveStringToFile(qmlString,filePath);
 }
