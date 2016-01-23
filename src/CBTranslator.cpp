#include "CBTranslator.h"
#include <QFile>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>

//HOTFIX: I don't know how to solve passing 'const QVariant' as 'this' argument of 'QVariant& QVariant::operator=(const QVariant&)' discards qualifiers [-fpermissive]
QVariantMap strings;

CBTranslator::CBTranslator(QObject *parent) :
    QTranslator(parent)
{
    m_needCollect = false;
}


bool CBTranslator::load(const QString &filename, const QString &directory, const QString &search_delimiters, const QString &suffix){
    Q_UNUSED(search_delimiters);
    Q_UNUSED(suffix);
    QString fullFilename = directory + filename;

    if (m_needCollect){
        m_fullFileName = fullFilename;
    }

    QFile file(fullFilename);
    if (!file.open(QIODevice::ReadOnly)){
        qDebug() << "Cannot open translation";
        return m_needCollect;
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
    if (translation.isEmpty()){
        translation = original;
        if (m_needCollect){
            strings[original] = QVariant(original);
            this->save();
        }
    }
    return translation;
}

void CBTranslator::save() const {
    QFile saveFile(m_fullFileName);
    if (!saveFile.open(QIODevice::WriteOnly)) {
            qWarning("Couldn't open save file.");
    }
    QJsonDocument saveDoc(QJsonObject::fromVariantMap(strings));
    saveFile.write(saveDoc.toJson());
}
