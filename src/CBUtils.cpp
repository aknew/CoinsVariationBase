#include "CBUtils.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>

void CBUtils::FromQmlFilePath(QString *str){

    // HOTFIX: QFile won't open places like /D:/
#ifdef Q_OS_WIN32
    const QString kPrefix = "file:///";
#else
    const QString kPrefix = "file://";
#endif

    if (str->startsWith(kPrefix)){
        str->remove(kPrefix);
    }
}

void CBUtils::SaveStringToFile(const QString &stringToSave,const QString &filePath){
    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly)) {
            qWarning("Couldn't open save file.");
    }
    QTextStream outstream(&file);
    outstream << stringToSave;
}

void CBUtils::collectTranslation(const QString &original){
    QFile saveFile("translationList.json");
    if (!saveFile.open(QIODevice::ReadOnly)){
        qDebug() << "Cannot open translation file to read";
    }
    QString jsonData = saveFile.readAll();
    saveFile.close();

    QJsonDocument sd = QJsonDocument::fromJson(jsonData.toUtf8());

    if (sd.isNull()){
        qDebug() << "Wrong translation file format";
    }
    QVariantMap strings1 =sd.object().toVariantMap();
    if (!saveFile.open(QIODevice::WriteOnly)) {
            qWarning("Couldn't open translation file to right.");
    }
    strings1[original] = QVariant(original);
    QJsonDocument saveDoc(QJsonObject::fromVariantMap(strings1));
    saveFile.write(saveDoc.toJson());
}
