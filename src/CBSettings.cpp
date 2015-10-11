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

    int size = settings.beginReadArray(kRecent);
    for (int i = 0; i < size; ++i) {
        settings.setArrayIndex(i);
        QString name = settings.value(kBaseName).toString();
        QString path = settings.value(kBasePath).toString();
        recentBasesMap[name] = path;
    }
    settings.endArray();

}

void CBSettings::saveSetting(){
    settings.setValue(kLastBasePath,QVariant(lastBasePath));

    settings.beginWriteArray(kRecent);
    auto base = recentBasesMap.begin();
    for (int i = 0; i < recentBasesMap.size(); ++i) {
        settings.setArrayIndex(i);
        settings.setValue(kBaseName, base.key());
        settings.setValue(kBasePath, base.value());
        ++base;
    }
    settings.endArray();
}


void CBSettings::addRecentBase(const QString &name,const QString &path){

    QString existsPath = recentBasesMap[name];

    if (existsPath == path){
        //already exists
        return;
    }

    if (existsPath == ""){
        recentBasesMap[name] = path;
    }
    else{
        recentBasesMap[name + ": " + path] = path;
    }
    saveSetting();
    emit recentBasesChanged();
}

QStringList CBSettings::recentBases(){
    QStringList bases;
    for (auto base = recentBasesMap.begin(); base!= recentBasesMap.end(); ++base){
        bases.append(base.value());
    }
    return bases;

}

QString CBSettings::recentPathByName(const QString &name){
    return recentBasesMap[name];
}
