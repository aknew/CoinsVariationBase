#include "CBBaseProvider.h"
#include <QClipboard>
#include <QApplication>

#include "CBUtils.h"
#include "CBSettings.h"

void CBBaseProvider::startWithPath(const QString &path){

    rootPath = path;

    if (rootPath.lastIndexOf("/")!=rootPath.length()-1){
        rootPath += "/";
    }

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

     attachmentsProvider = new CBAttachmentsProvider(rootPath);

     imageProvider= new CBImageProvider(QQuickImageProvider::Pixmap);
     imageProvider->attachmentsProvider =attachmentsProvider;

     QJsonArray nodes = baseStruct.value("nodes").toArray();

     foreach (QJsonValue value1,nodes) {
         QJsonObject obj=value1.toObject();

         CBNode *node=new CBNode(obj,db, this);
         if (node->usesUUIDs){
             connect(node,&CBNode::idWasSelected,this,&CBBaseProvider::idWasSelected);
         }
         nodeMap.insert(node->tableName,node);
     }

     CBSettings *settings = CBSettings::settingsInstance();
     settings->lastBasePath = rootPath;
     settings->addRecentBase(m_baseTitle,rootPath);
     settings->saveSetting();

     qDebug() << db.connectOptions();

     emit readyToWork();
}

 CBNode* CBBaseProvider::getNode(const QString &name, CBNode * currentNode){
    CBNode *node = nodeMap[name];
    if (currentNode){ // I.e. it is not start node
        QPair<QString,QString> filter =currentNode->filterForChildNode(name);
        node->setLevelFilter(filter);
    }
    return node;
}

 void CBBaseProvider::saveListForm(const QString& qmlString, CBNode *node){
     CBUtils::SaveStringToFile(qmlString,listFormPath(node));
 }

 void CBBaseProvider::saveFullForm(const QString& qmlString, CBNode *node){
     CBUtils::SaveStringToFile(qmlString,fullFormPath(node));
 }

 QString CBBaseProvider::listFormPath(CBNode *node){
     return rootPath+"forms/"+node->listFormName();
 }

 QString CBBaseProvider::fullFormPath(CBNode *node){
     return rootPath+"forms/"+node->fullFormName();
 }


 void CBBaseProvider::idWasSelected(const QString &id){
     // FIXME: need add stack of previous selected ids whenwe go back from some node
     attachmentsProvider->selectID(id);
 }

 CBBaseProvider::~CBBaseProvider(){
     db.close();
     db.removeDatabase(rootPath + "base.sqlite");
 }
