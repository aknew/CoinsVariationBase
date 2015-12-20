#include "CBNotesProvider.h"
#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QVariantMap>

CBNotesProvider::CBNotesProvider(const QString &basePath, QObject *parent) : QObject(parent)
{
    _basePath = basePath + "Notes/";
}


void CBNotesProvider::selectID(const QString &newID){
    _selectedID = new QString(newID);

    if (QDir(_basePath+*_selectedID).exists()){
        QString filename=notesAttributePath();
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
         attributes = sd.array();
    }
    else{
        attributes = QJsonArray();
    }
}

void CBNotesProvider::insertNewNote(const QString &notePath){
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
    attributes.append(QJsonObject::fromVariantMap(newNote));
    saveAttributes();
    //TODO: need rewrite notes to property and emit its changing
}

void CBNotesProvider::saveAttributes(){
    QFile saveFile(notesAttributePath());
    if (!saveFile.open(QIODevice::WriteOnly)) {
            qWarning("Couldn't open save file.");
    }
    QJsonDocument saveDoc(attributes);
    saveFile.write(saveDoc.toJson());
}
