#include "CBAttachmentsProvider.h"
#include <QDir>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QVariantMap>

CBAttachmentsProvider::CBAttachmentsProvider(const QString &basePath, QObject *parent) : QObject(parent)
{
    _basePath = basePath + "attachments/";
}


void CBAttachmentsProvider::selectID(const QString &newID){
    _selectedID = new QString(newID);

    if (QDir(_basePath+*_selectedID).exists()){
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

void CBAttachmentsProvider::insertNewNote(const QString &notePath){
    QString dirPath = _basePath+*_selectedID;
    if (!QDir(dirPath).exists()){
        QDir().mkdir(dirPath);
    }
    QString fileName = QFileInfo(notePath).fileName();
    QFile::copy(notePath,dirPath+fileName);
    QVariantMap newNote;
    newNote["file"]=QVariant(fileName);
    newNote["description"]=QVariant("");
    newNote["source"]=QVariant("");
    newNote["comment"]=QVariant("");
    attributes.append(newNote);
    saveAttributes();
    emit attributesChanged();
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
