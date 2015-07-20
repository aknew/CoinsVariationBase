#include "CBUtils.h"
#include <QFile>
#include <QTextStream>

void CBUtils::FromQmlFilePath(QString *str){
    if (str->startsWith("file:///")){
        str->remove("file:///");
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
