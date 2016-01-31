#include "CBUtils.h"
#include <QFile>
#include <QTextStream>

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
