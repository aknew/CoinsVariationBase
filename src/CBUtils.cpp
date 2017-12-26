#include "CBUtils.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QTextStream>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>

#include "CBAttachmentsProvider.h"

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

//https://qt.gitorious.org/qt-creator/qt-creator/source/1a37da73abb60ad06b7e33983ca51b266be5910e:src/app/main.cpp#L13-189
// taken from utils/fileutils.cpp. We can not use utils here since that depends app_version.h.
bool CBUtils::copyRecursively(const QString &srcFilePath,
                            const QString &tgtFilePath)
{
    QFileInfo srcFileInfo(srcFilePath);
    if (srcFileInfo.isDir()) {
        QDir targetDir(tgtFilePath);
        targetDir.cdUp();
        if (!targetDir.mkdir(QFileInfo(tgtFilePath).fileName()))
            return false;
        QDir sourceDir(srcFilePath);
        QStringList fileNames = sourceDir.entryList(QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot | QDir::Hidden | QDir::System);
        foreach (const QString &fileName, fileNames) {
            const QString newSrcFilePath
                    = srcFilePath + QLatin1Char('/') + fileName;
            const QString newTgtFilePath
                    = tgtFilePath + QLatin1Char('/') + fileName;
            if (!copyRecursively(newSrcFilePath, newTgtFilePath))
                return false;
        }
    } else {
        // drop thumbnail images
        QString fileName = "/" + QFileInfo(srcFilePath).fileName();
        qDebug() << CBAttachmentsProvider::kMainThumb;
        if (fileName == CBAttachmentsProvider::kMainThumb || fileName.startsWith(CBAttachmentsProvider::kThumbPrefix)){
            return true;
        }
        if (!QFile::copy(srcFilePath, tgtFilePath)){
            //qDebug() << QFile::error();
            qDebug() << srcFilePath;
            qDebug() << tgtFilePath;
            return false;
        }
    }
    return true;
}
