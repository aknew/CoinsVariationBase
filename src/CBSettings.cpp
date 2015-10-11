#include "CBSettings.h"

const QString kLastBasePath="global/base";
const QString kNeedCollect="global/needCollect";
const QString kRecent = "recent";
const QString kBaseName = "baseName";
const QString kBasePath = "basePath";
const QString kIsFirstRan = "isFirstRan"; ///< hack to init settings if we ran it first time

CBSettings::CBSettings(QObject *parent) : QObject(parent),
    settings("settings.ini",QSettings::IniFormat)
{
    settings.setIniCodec("windows-1251");

    if (settings.value(kIsFirstRan,true).toBool()){
        // we have never use settings before,let's init them
        settings.setValue(kIsFirstRan,false);
        settings.setValue(kNeedCollect,true);
    }

    lastBasePath = settings.value(kLastBasePath,"").toString();
    needCollect = settings.value(kNeedCollect,false).toBool();

}

void CBSettings::saveSetting(){
    settings.setValue(kLastBasePath,QVariant(lastBasePath));
}

