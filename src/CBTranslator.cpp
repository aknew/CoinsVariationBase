#include "CBTranslator.h"
#include <QFile>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>

#include "CBUtils.h"

CBTranslator::CBTranslator(QObject *parent) :
    QTranslator(parent)
{
    m_needCollect = false;
}


bool CBTranslator::load(const QString &filename, const QString &directory, const QString &search_delimiters, const QString &suffix){
    Q_UNUSED(search_delimiters);
    Q_UNUSED(suffix);
    Q_UNUSED(filename);

    QString locale = QLocale::system().name();
    QString fullFilename = directory + locale + ".json";
    if (!QFile::exists(fullFilename)){
        const QString default_lang = "ru_RU";
        qDebug() << "There is no translation for language " << locale <<", try to open default one - "<<default_lang;
        fullFilename = directory + default_lang + ".json";
    }

    QFile file(fullFilename);
    if (!file.open(QIODevice::ReadOnly)){
        qDebug() << "Cannot open translation from path " << fullFilename;
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

QString CBTranslator::translate(const char *context, const char *sourceText, const char *disambiguation, int n) const{
    Q_UNUSED(context);
    Q_UNUSED(disambiguation);
    Q_UNUSED(n);
    QString original = QString(sourceText);
    QString translation = strings[original].toString();
    if (translation.isEmpty()&& m_needCollect){
            CBUtils::collectTranslation(original);
    }
    return translation;
}

