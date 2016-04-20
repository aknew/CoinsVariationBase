#include "CBBaseProvider.h"
#include <QClipboard>
#include <QApplication>

#include "CBUtils.h"
#include "CBSettings.h"

const QString kFormDir = "forms/";

void CBBaseProvider::startWithPath(const QString &path){
    // TODO: need rewrite this method: controller should know was base loading succesed and push error messages to GUI

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
        return;
    }

    //enable foreign key
    QSqlQuery query=QSqlQuery(db);
    query.exec("PRAGMA foreign_keys = ON;");

    // parse ifo about base struct from json

    QString filename=rootPath+"struct.json";

     QFile file(filename);
     if (!file.open(QIODevice::ReadOnly)){
         qDebug() << "Cannot open json";
         return;
     }
     QString jsonData = file.readAll();
     file.close();

     QJsonDocument sd = QJsonDocument::fromJson(jsonData.toUtf8());

     if (sd.isNull()){
        qDebug()<<"Wrong file json format";
        return;
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

     QString locale = QLocale::system().name();
     filename = QString("languages/") + locale+".json";

     translator.m_needCollect = settings->needCollect;
     if( translator.load(filename, rootPath) ){
         QApplication::instance()->installTranslator(&translator);
     } else
         qDebug() << "Translation file not loaded:" << filename << "  dir:"<<rootPath;

     // Creating dirs if not exists

     if (!QDir(attachmentsProvider->_basePath).exists()){
         QDir().mkdir(attachmentsProvider->_basePath);
     }

     if (!QDir(rootPath+kFormDir).exists()){
         QDir().mkdir(rootPath+kFormDir);
     }

     emit readyToWork();
}

 CBNode* CBBaseProvider::getNode(const QString &name, CBNode * currentNode){
    CBNode *node = nodeMap.contains(name)?nodeMap[name]:NULL;
    if (node && currentNode){ // I.e. it is not start node and node is exists
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
     attachmentsProvider->selectID(id);
 }

 void CBBaseProvider::currentItemWillBeRemoved(){
     //Recurently remove all related items

     CBNode* node = qobject_cast<CBNode*>(sender());

     for (auto subnodeName : node->getNextLevelList()){
         CBNode *subnode = getNode(subnodeName,node);
         while(subnode->model->rowCount()){
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
         if (!ids.empty()){
             attachmentsProvider->selectID(ids.top());
         }
     }
 }

 CBBaseProvider::~CBBaseProvider(){
     db.close();
     db.removeDatabase(rootPath + "base.sqlite");

     //XXX: I don't destroy imageProviders here because QQmlApplicationEngine destroy it

     QApplication::instance()->removeTranslator(&translator);
 }
