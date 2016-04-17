#include "CBAttachmentsProvider.h"
#include <QDir>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QVariantMap>
#include <QDebug>
#include <QDesktopServices>
#include <QUrl>

#include "CBUtils.h"

CBAttachmentsProvider::CBAttachmentsProvider(const QString &basePath, QObject *parent) : QObject(parent)
{
    _basePath = basePath + "attachments/";
}


void CBAttachmentsProvider::selectID(const QString &newID){
    _selectedID = new QString(newID);

    if (QDir(currentPath()).exists()){
        QString filename=attributePath();
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
         attributes = sd.array().toVariantList();
    }
    else{
        attributes = QVariantList();
    }
    emit attributesChanged();
}

QVariantMap CBAttachmentsProvider::insertNewAttach(QString notePath){
    CBUtils::FromQmlFilePath(&notePath);
    // TODO: add checking that file was realy copied and that name is unique
    QString dirPath = currentPath();
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
        QFile::remove(currentPath()+"/"+noteID);
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
    QDesktopServices::openUrl(QUrl("file:///"+currentPath()+attachID));
}

void CBAttachmentsProvider::openFolder(){
    QDesktopServices::openUrl(QUrl("file:///"+_basePath+*_selectedID, QUrl::TolerantMode));
}

void CBAttachmentsProvider::setMain(const QString &attachID){
    // TODO: add checking that file Main.jpg doesn't exist and this is realy jpeg
    QFile::rename(currentPath()+attachID,currentPath()+"Main.jpg");
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
    QDir dir(currentPath());
    if (!dir.removeRecursively()){
        qWarning() << "Can't remove folder at " << currentPath();
    }
}
