#ifndef CBSETTINGS_H
#define CBSETTINGS_H

#include <QObject>
#include <QSettings>

class QQmlEngine;
class QJSEngine;

class CBSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList recentBases READ recentBases NOTIFY recentBasesChanged)
    Q_PROPERTY(QString defaultPath MEMBER m_defaultPath CONSTANT)
    Q_PROPERTY(QString attachSearchPath MEMBER m_attachSearchPath CONSTANT)
public:
    void saveSetting();

    QString lastBasePath;
    bool needCollect;

    void addRecentBase(const QString &name,const QString &path);
    QStringList recentBases();
    QString m_defaultPath;
    QString m_attachSearchPath = "";
    QString recentPathByName(const QString &name);


    static CBSettings *settingsInstance(){
        static CBSettings *settings = NULL;
        if (!settings){
            settings = new CBSettings();
        }
        return settings;
    }

signals:
    void recentBasesChanged();


private:
    //TODO: need add operator= and copyed constructor
    explicit CBSettings(QObject *parent = 0);
    QSettings settings;
    QMap<QString, QString> recentBasesMap;
};

#endif // CBSETTINGS_H
