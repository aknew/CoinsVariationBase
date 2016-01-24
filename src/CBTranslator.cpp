#include "CBTranslator.h"
#include <QFile>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>

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
    if (translation.isEmpty()){
        translation = original;
        if (m_needCollect){
            this->append(original);
        }
    }
    return translation;
}

void CBTranslator::append(QString original) const{
    // XXX: All this method is hotfix: I can't change strings in load because it is constant method and I
    // can't do it not constant because when I try to do it this method wasn't call anymore
    QFile saveFile(m_fullFileName);
    if (!saveFile.open(QIODevice::ReadOnly)){
        qDebug() << "Cannot open translation file to read";
        return;
    }
    QString jsonData = saveFile.readAll();
    saveFile.close();

    QJsonDocument sd = QJsonDocument::fromJson(jsonData.toUtf8());

    if (sd.isNull()){
        qDebug() << "Wrong translation file format";
        return;
    }
    QVariantMap strings1 =sd.object().toVariantMap();
    if (!saveFile.open(QIODevice::WriteOnly)) {
            qWarning("Couldn't open translation file to right.");
    }
    strings1[original] = QVariant(original);
    QJsonDocument saveDoc(QJsonObject::fromVariantMap(strings1));
    saveFile.write(saveDoc.toJson());
}
