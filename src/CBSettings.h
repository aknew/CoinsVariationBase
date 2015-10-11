#ifndef CBSETTINGS_H
#define CBSETTINGS_H

#include <QObject>
#include <QSettings>

class QQmlEngine;
class QJSEngine;

class CBSettings : public QObject
{
    Q_OBJECT
public:
    void saveSetting();

    QString lastBasePath;
    bool needCollect;

    static CBSettings *settingsInstance(){
        static CBSettings *settings = NULL;
        if (!settings){
            settings = new CBSettings();
        }
        return settings;
    }


private:

    explicit CBSettings(QObject *parent = 0);
    QSettings settings;
};

#endif // CBSETTINGS_H
