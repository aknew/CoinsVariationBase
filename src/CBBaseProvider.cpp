#include "CBBaseProvider.h"
#include <QClipboard>
#include <QApplication>

#include "CBUtils.h"
#include "CBSettings.h"

const QString kFormDir = "forms/";

bool CBBaseProvider::baseExistsAtPath(const QString &path){

    QString rootPath = path;

    if (rootPath.lastIndexOf("/")!=rootPath.length()-1){
        rootPath += "/";
    }

    QString basePath = rootPath + "base.sqlite";
    QString structPath = rootPath+"struct.json";

    return QFile::exists(basePath) && QFile::exists(structPath);
}

bool CBBaseProvider::startWithPath(const QString &path){

    rootPath = path;

    if (rootPath.lastIndexOf("/")!=rootPath.length()-1){
        rootPath += "/";
    }

    // open sqlite base

    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(rootPath + "base.sqlite");
    if (!db.open()) {
        // TODO: need cleanup logging and excaptioning
        qDebug() << "Cannot open database:" << db.lastError();
        qDebug() << "base path " << rootPath;
        return false;
    }

    //enable foreign key
    QSqlQuery query=QSqlQuery(db);
    query.exec("PRAGMA foreign_keys = ON;");

    // parse ifo about base struct from json

    QString filename=rootPath+"struct.json";

     QFile file(filename);
     if (!file.open(QIODevice::ReadOnly)){
         qDebug() << "Cannot open json";
         return false;
     }
     QString jsonData = file.readAll();
     file.close();

     QJsonDocument sd = QJsonDocument::fromJson(jsonData.toUtf8());

     if (sd.isNull()){
        qDebug()<<"Wrong file json format";
        return false;
     }
     QJsonObject baseStruct = sd.object();
     m_baseTitle = baseStruct.value("baseTitle").toString();

     startTable = baseStruct.value("startTable").toString();

     attachmentsProvider = new CBAttachmentsProvider(rootPath,this);

     imageProvider= new CBImageProvider(QQuickImageProvider::Pixmap);
     imageProvider->attachmentsProvider =attachmentsProvider;

     QJsonArray nodes = baseStruct.value("nodes").toArray();

     foreach (QJsonValue value1,nodes) {
         QJsonObject obj=value1.toObject();

         CBNode *node=new CBNode(obj,db, this);
         if (node->usesUUIDs){
             connect(node,&CBNode::idWasSelected,this,&CBBaseProvider::idWasSelected);
             connect(node,&CBNode::currentItemWillBeRemoved,this,&CBBaseProvider::currentItemWillBeRemoved);
         }
         nodeMap.insert(node->tableName,node);
     }

     CBSettings *settings = CBSettings::settingsInstance();
     settings->lastBasePath = rootPath;
     settings->addRecentBase(m_baseTitle,rootPath);
     settings->saveSetting();

     // load translator for specific base termins (mostly fieldnames)



     translator.m_needCollect = settings->needCollect;
     if( translator.load("", rootPath + "languages/") ){
         QApplication::instance()->installTranslator(&translator);
     }

     // Creating dirs if not exists

     if (!QDir(attachmentsProvider->_basePath).exists()){
         QDir().mkdir(attachmentsProvider->_basePath);
     }

     if (!QDir(rootPath+kFormDir).exists()){
         QDir().mkdir(rootPath+kFormDir);
     }

     emit readyToWork();
    return true;
}

 CBNode* CBBaseProvider::getNode(const QString &name, CBNode * currentNode){

    if (currentNode && !currentNode->containsSubnode(name)){
        return NULL;
    }

    CBNode *node = nodeMap.contains(name)?nodeMap[name]:NULL;
    if (node && currentNode){ // I.e. it is not start node and node is exists
        QPair<QString,QString> filter =currentNode->filterForChildNode(name);
        node->setLevelFilter(filter);
    }
    return node;
}

 QString CBBaseProvider::listFormPath(CBNode *node){
     return rootPath+kFormDir+node->listFormName();
 }

 QString CBBaseProvider::fullFormPath(CBNode *node){
     return rootPath+kFormDir+node->fullFormName();
 }

 QString CBBaseProvider::getAbout(){
     QFile file(rootPath + "about.html");
     QString about = "";
     if (!file.open(QIODevice::ReadOnly)){
         about = m_baseTitle;
         // When I add base backuping, I will add last backup data here
     }else{
         about = file.readAll();
         file.close();
     }
     return about;
 }


 void CBBaseProvider::idWasSelected(const QString &id){
     ids.push(id);
     CBNode* node = qobject_cast<CBNode*>(sender());
     selectedDescription.push(node->selectedItemDescription());
     attachmentsProvider->selectID(id);
 }

 void CBBaseProvider::currentItemWillBeRemoved(){
     //Recurently remove all related items

     CBNode* node = qobject_cast<CBNode*>(sender());

     for (auto subnodeName : node->_nextLevelList){
         CBNode *subnode = getNode(subnodeName,node);
         while(subnode->m_listModel->rowCount()){
             subnode->selectItemWithIndex(0);
             subnode->deleteSelectedItem();
         }
     }

     attachmentsProvider->removeSelectedIdAttaches();
     deselectCurrentId();

 }

 void CBBaseProvider::deselectCurrentId(){
     if (!ids.empty()){
         ids.pop();
         selectedDescription.pop();
         if (!ids.empty()){
             attachmentsProvider->selectID(ids.top());
         }
     }
 }

 QString CBBaseProvider::getSelectedWay(){
     QString str = "";
     for (auto iter: selectedDescription){
         str += iter;
     }
     if (str ==""){
         str = tr("You are at start level, nothing have been selected yet");
     }
     return str;
 }

 CBBaseProvider::~CBBaseProvider(){
     db.close();
     db.removeDatabase(rootPath + "base.sqlite");

     //XXX: I don't destroy imageProviders here because QQmlApplicationEngine destroy it

     QApplication::instance()->removeTranslator(&translator);
 }

