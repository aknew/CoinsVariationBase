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

     // create and init imageProvider

     imageProvider= new CBImageProvider(QQuickImageProvider::Pixmap);
     imageProvider->imageFolder = rootPath+"images/";
     m_imageModel = new CBSqlRelationalTableModel(this,db);
     m_imageModel->setTable("Images");
     m_imageModel->applyRoles();

     QJsonArray nodes = baseStruct.value("nodes").toArray();

     foreach (QJsonValue value1,nodes) {
         QJsonObject obj=value1.toObject();

         CBNode *node=new CBNode(obj,db, this);
         if (node->hasImages){
             connect(node,&CBNode::idWasSelected,this,&CBBaseProvider::idWasSelected);
         }
         //bool isSystem=obj.value("isSystem").toBool();

//         if (isSystem){
//             systemTables.append(node->tableName);
//         }

         nodeMap.insert(node->tableName,node);
     }

     CBSettings *settings = CBSettings::settingsInstance();
     settings->lastBasePath = rootPath;
     settings->addRecentBase(m_baseTitle,rootPath);

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
     QString filePath=rootPath+"forms/"+node->listFormName();
     CBUtils::SaveStringToFile(qmlString,filePath);
 }

 void CBBaseProvider::saveFullForm(const QString& qmlString, CBNode *node){
     QString filePath=rootPath+"forms/"+node->fullFormName();
     CBUtils::SaveStringToFile(qmlString,filePath);
 }


 void CBBaseProvider::idWasSelected(const QString &id){
     // FIXME: need add stack of previous selected ids whenwe go back from some node
     QString filter = QString("\"ParentID\"=\"%1\"").arg(id);
     m_imageModel->setFilter(filter);
     m_imageModel->select();
 }

 void CBBaseProvider::saveImageInfo(QVariantMap imageInfo){
         QSqlQuery query(db);
         query.prepare("INSERT OR REPLACE INTO Images(\"id\",\"comment\",\"source\",\"ParentID\") VALUES(:id,:comment,:source,:ParentID)");
         query.bindValue(":id",imageInfo["id"]);
         query.bindValue(":ParentID",imageInfo["ParentID"]);
         query.bindValue(":comment",imageInfo["comment"]);
         query.bindValue(":source",imageInfo["source"]);
         if (!query.exec()){
             qDebug()<<query.lastError();
         }
}

void CBBaseProvider::saveImage(QString imageId, QString savingPath){


    QSize size=QSize();
    QImage img = imageProvider->requestImage(imageId,&size,size);

    // TODO: need check that savingPath is file and it has correct extantion. Maybe also need sheck that file does not exist
    CBUtils::FromQmlFilePath(&savingPath);

    img.save(savingPath);

}

QString CBBaseProvider::loadImage(QString imagePath){
    return "";
}

void CBBaseProvider::copyImageToClipboard(QString imageId){
    QSize size=QSize();
    QImage img = imageProvider->requestImage(imageId,&size,size);
    QClipboard *clipboard = QApplication::clipboard();
    clipboard->setImage(img);
}

QString CBBaseProvider::importImageFromClipboard(){
    return "";
}


 CBBaseProvider::~CBBaseProvider(){
     db.close();
     db.removeDatabase(rootPath + "base.sqlite");
 }
