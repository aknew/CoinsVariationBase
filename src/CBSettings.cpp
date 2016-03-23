#include "CBSettings.h"
#include <QStandardPaths>
#include <QDebug>

#ifdef  Q_OS_ANDROID
#include <QtAndroidExtras/QAndroidJniObject>
#include <QtAndroidExtras/QAndroidJniEnvironment>
#endif

const QString kLastBasePath="base"; //! path to last used base
const QString kNeedCollect="needCollect"; //! determines need application collect forms and translations or not
const QString kRecent = "recent"; //! list of previosly openned bases
const QString kBaseName = "baseName"; //!Base name for recent, this name is shown in GUI
const QString kBasePath = "basePath"; //!Base path for recent
const QString kIsFirstRan = "isFirstRan"; ///< hack to init settings if we ran app first time
const QString kDefaultPath = "defaultPath"; ///< default path where will be file dialog when we want to open new base
const QString kAttachSearchPath = "attachSearchPath"; ///< default path where we try to find attach

CBSettings::CBSettings(QObject *parent) : QObject(parent),
    settings("settings.ini",QSettings::IniFormat)
{
    settings.setIniCodec("windows-1251");

    if (settings.value(kIsFirstRan,true).toBool()){
        // we have never use settings before,let's init them
        settings.setValue(kIsFirstRan,false);
        settings.setValue(kNeedCollect,true);
#if defined(Q_OS_WIN32) || defined(Q_OS_MAC) || defined(Q_OS_IOS)
        QStringList paths = QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation);
        if (!paths.empty()){
            settings.setValue(kDefaultPath,"file:///"+paths.at(0)+"/Bases/");
        }
        paths = QStandardPaths::standardLocations(QStandardPaths::DownloadLocation);
        if (!paths.empty()){
            settings.setValue(kAttachSearchPath,"file:///"+paths.at(0)+"/");
        }
#endif

#ifdef  Q_OS_ANDROID

        QAndroidJniObject mediaDir = QAndroidJniObject::callStaticObjectMethod("android/os/Environment", "getExternalStorageDirectory", "()Ljava/io/File;");
        QAndroidJniObject mediaPath = mediaDir.callObjectMethod( "getAbsolutePath", "()Ljava/lang/String;" );
        QString dataAbsPath = "file://" + mediaPath.toString();
        settings.setValue(kDefaultPath,dataAbsPath +"/Bases/");
        settings.setValue(kAttachSearchPath,dataAbsPath+"/Downloads/");
        QAndroidJniEnvironment env;
        if (env->ExceptionCheck()) {
                // Handle exception here.
                env->ExceptionClear();
        }
#endif
    }

    lastBasePath = settings.value(kLastBasePath,"").toString();
    needCollect = settings.value(kNeedCollect,false).toBool();
    m_defaultPath = settings.value(kDefaultPath,"").toString();
    m_attachSearchPath = settings.value(kAttachSearchPath,"").toString();

    qDebug()<<"Bases path: "<<m_defaultPath;

    int size = settings.beginReadArray(kRecent);
    for (int i = 0; i < size; ++i) {
        settings.setArrayIndex(i);
        QString name = settings.value(kBaseName).toString();
        QString path = settings.value(kBasePath).toString();
        recentBasesMap[name] = path;
    }
    settings.endArray();
    emit recentBasesChanged();

}

void CBSettings::saveSetting(){
    settings.setValue(kLastBasePath,QVariant(lastBasePath));

    settings.beginWriteArray(kRecent);
    int i = 0;
    for (auto base = recentBasesMap.begin(); base!= recentBasesMap.end(); ++base){
        settings.setArrayIndex(i);
        settings.setValue(kBaseName, base.key());
        settings.setValue(kBasePath, base.value());
        ++i;
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
    emit recentBasesChanged();
}

QStringList CBSettings::recentBases(){
    QStringList bases;
    bases.append(recentBasesMap.keys());
    //TODO: need use some constants instead string
    bases.append(tr("Open new base"));
    return bases;
}

QString CBSettings::recentPathByName(const QString &name){
    return recentBasesMap.contains(name)?recentBasesMap[name]:"";
}
