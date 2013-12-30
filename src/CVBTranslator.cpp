#include "CVBTranslator.h"
#include <QFile>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>

CVBTranslator::CVBTranslator(QObject *parent) :
    QTranslator(parent)
{
}


bool CVBTranslator::load(const QString &filename, const QString &directory, const QString &search_delimiters, const QString &suffix){
    Q_UNUSED(search_delimiters);
    Q_UNUSED(suffix);
    QString fullFilename = directory + filename;
    QFile file(fullFilename);
    if (!file.open(QIODevice::ReadOnly)){
        qDebug() << "Cannot open translation";
        return false;
    }
    QString jsonData = file.readAll();
    file.close();

    QJsonDocument sd = QJsonDocument::fromJson(jsonData.toUtf8());

    if (sd.isNull()){
        qDebug() << "Wrong translation file format";
        return false;
    }
    strings =sd.object().toVariantMap();
    return true;
}

QString CVBTranslator::translate(const char *context, const char *sourceText, const char *disambiguation, int n) const{
    Q_UNUSED(context);
    Q_UNUSED(disambiguation);
    Q_UNUSED(n);
    QString original = QString(sourceText);
    QString translation = strings[original].toString();
    return translation.isEmpty()?original:translation;
}


