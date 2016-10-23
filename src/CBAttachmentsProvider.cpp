#include "CBAttachmentsProvider.h"
#include <QDir>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QVariantMap>
#include <QDebug>
#include <QDesktopServices>
#include <QUrl>
#include <QUuid>

#include "CBUtils.h"

CBAttachmentsProvider::CBAttachmentsProvider(const QString &basePath, QObject *parent) : QObject(parent)
{
    _basePath = basePath + "attachments/";
    if (!QDir(_basePath).exists()){
        QDir().mkdir(_basePath);
    }
}


QVariantList CBAttachmentsProvider::attributesForId(const QString &recId)
{
    if (QDir(pathForId(recId)).exists()){
        QString filename=attributePath(recId);
         QFile file(filename);
         if (!file.open(QIODevice::ReadOnly)){
             qWarning("Cannot open attribute json");
         }
         QString jsonData = file.readAll();
         file.close();

         QJsonDocument sd = QJsonDocument::fromJson(jsonData.toUtf8());

         if (sd.isNull()){
            qWarning("Wrong file attribute json format");
         }
         return sd.array().toVariantList();
    }
    else{
        return QVariantList();
    }
}

void CBAttachmentsProvider::selectID(const QString &newID){
    _selectedID = new QString(newID);

    attributes = attributesForId();
    emit attributesChanged();
}

QVariantMap CBAttachmentsProvider::insertNewAttach(QString notePath){
    CBUtils::FromQmlFilePath(&notePath);
    // TODO: add checking that file was realy copied and that name is unique
    QString dirPath = pathForId();
    if (!QDir(dirPath).exists()){
        QDir().mkdir(dirPath);
    }
    QFileInfo fileInfo(notePath);
    QString fileName = fileInfo.fileName();
    if(fileInfo.completeSuffix().toLower() == "jpg" && !QFileInfo(dirPath+ "/Main.jpg").exists()){
        fileName = "Main.jpg";
    }

    bool flag = CBUtils::copyRecursively(notePath,dirPath+"/"+fileName);
    if (!flag){
        qDebug() << "Attach wasn't copy";
    }

    QVariantMap newNote;
    newNote["file"]=QVariant(fileName);
    attributes.append(newNote);
    saveAttributes();
    emit attributesChanged();
    return newNote;
}

void CBAttachmentsProvider::deleteAttach(const QString& noteID){
    int index = -1;
    for (int i = 0; i<attributes.size(); ++i){
        QVariantMap map = attributes.at(i).toMap();
        if (map["file"] == noteID){
            index = i;
            break;
        }
    }
    if (index==-1){
        qWarning()<<"Can't find attributes for "<< noteID;
    }
    else{
        QFile::remove(pathForId()+"/"+noteID);
        attributes.removeAt(index);
        saveAttributes();
        emit attributesChanged();
    }
}

void CBAttachmentsProvider::saveAttributes(){
    QFile saveFile(attributePath());
    if (!saveFile.open(QIODevice::WriteOnly)) {
            qWarning("Couldn't open save file.");
    }
    QJsonDocument saveDoc(QJsonArray::fromVariantList(attributes));
    saveFile.write(saveDoc.toJson());
}

void CBAttachmentsProvider::updateAttributes(QVariantMap newAttributes){
    QVariant &fileName = newAttributes["file"];
    int index = -1;
    for (int i = 0; i<attributes.size(); ++i){
        QVariantMap map = attributes.at(i).toMap();
        if (map["file"] == fileName){
            index = i;
            break;
        }
    }
    if (index == -1){
        attributes.append(newAttributes);
    }
    else{
        attributes.replace(index, newAttributes);
    }
    saveAttributes();
    emit attributesChanged();
}

void CBAttachmentsProvider::openAttach(const QString &attachID){
    QString path = pathForId()+attachID;
    QFileInfo fileInfo(path);
    if (fileInfo.isDir()){
        QDir dir(path);
        QVector<QString> possibleMainFiles ={"index.htm", "index.html"};
        for( auto f : possibleMainFiles) {
            if (dir.exists(f)){
                path = path + "/" + f;
                break;
            }
        }
    }

    QDesktopServices::openUrl(QUrl("file:///"+path));
}

void CBAttachmentsProvider::openFolder(){
    QDesktopServices::openUrl(QUrl("file:///"+_basePath+*_selectedID, QUrl::TolerantMode));
}

void CBAttachmentsProvider::setMain(const QString &attachID){
    // TODO: add checking that file Main.jpg doesn't exist and this is realy jpeg
    QFile::rename(pathForId()+attachID,pathForId()+"Main.jpg");
    QVariant fileName = QVariant(attachID);
    for (int i = 0; i<attributes.size(); ++i){
        QVariantMap map = attributes.at(i).toMap();
        if (map["file"] == fileName){
            map["file"] = QVariant("Main.jpg");
            attributes.replace(i, map);
            break;
        }
    }
    saveAttributes();
    emit attributesChanged();
}

void CBAttachmentsProvider::removeSelectedIdAttaches(){
    QDir dir(pathForId());
    if (!dir.removeRecursively()){
        qWarning() << "Can't remove folder at " << pathForId();
    }
}


void CBAttachmentsProvider::mergeAttachments(const QString &srcId, const QString &dstID,const QString &diff){
    QString srcPath = pathForId(srcId);
    QDir srcDir(srcPath);
    if (!srcDir.exists() ){
        // there is no attachments in source
        return;
    }
    QString dstPath = pathForId(dstID);
    QDir dstDir(dstPath);
    if (!dstDir.exists() ){
        // just rename srcDir
        srcDir.rename(srcId,dstID);
        return;
    }

    QVariantList dstAttributes = attributesForId(dstID);
    QStringList dstFiles;
    for (int i = 0; i<dstAttributes.size(); ++i){
        QVariantMap map = dstAttributes.at(i).toMap();
        dstFiles.append(map["file"].toString());
    }

    QVariantList srcAttributes = attributesForId(srcId);
    foreach (QVariant v, srcAttributes) {
        QVariantMap map = v.toMap();
        QString fileName = map["file"].toString();
        QString filePath = srcPath+fileName;
        if (dstFiles.contains(fileName)){
            QFileInfo fileInfo(filePath);
            QUuid u=QUuid::createUuid();
            fileName =u.toString() +"."+fileInfo.completeSuffix();
            map["file"] = QVariant(fileName);
        }
        map["description"] = diff;
        QString copyTo = dstPath+fileName;
        bool flag = CBUtils::copyRecursively(filePath,copyTo);
        if (!flag){
            return;
        }
        dstAttributes.append(map);
    }
    QFile saveFile(attributePath(dstID));
    if (!saveFile.open(QIODevice::WriteOnly)) {
            qWarning("Couldn't open save file.");
    }
    QJsonDocument saveDoc(QJsonArray::fromVariantList(dstAttributes));
    saveFile.write(saveDoc.toJson());
    saveFile.close();
    bool flag = srcDir.removeRecursively();
    if (!flag){
        qWarning()<<"can't remove dir "<<srcPath;
    }
}
