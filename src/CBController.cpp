#include "CBController.h"

#include <QtWidgets/QApplication>

#include "CBSettings.h"
#include "CBUtils.h"

CBController::CBController(QObject *parent) : QObject(parent)
{
    m_baseProvider= NULL;
}


void CBController::start(){
    QString basePath;
    CBSettings *settings =  CBSettings::settingsInstance();

    basePath= settings->lastBasePath;

    bool needCollect = settings->needCollect;

    this->applicationWindow->setProperty("needCollect", QVariant(needCollect));

    if (!basePath.isEmpty()){
        bool canOpenBase = CBBaseProvider::baseExistsAtPath(basePath);
        if (canOpenBase) {
            this->openBase(basePath);
            return;
        } else {
            settings->removeRecentByPath(basePath);
        }
    }
    //call createAndPush("CBControls/BasesList.qml")
    QMetaObject::invokeMethod(this->applicationWindow,
                              "openBaseList"
                              );
}

void CBController::openBase(QString basePath){

    CBUtils::FromQmlFilePath(&basePath);

    // HOTFIX: temporary solution for WinXp - it can't select folder via FileDialog, so I just select some file into folder
    if (!CBBaseProvider::baseExistsAtPath(basePath)){
        basePath = QFileInfo(basePath).path();
    }

    if (m_baseProvider) {
        engine->removeImageProvider(QLatin1String("imageProvider"));
        delete m_baseProvider;
    }

    m_baseProvider=new CBBaseProvider();
    this->connect(m_baseProvider,SIGNAL(readyToWork()),this,SLOT(providerReadyToWork()));
    bool success = m_baseProvider->startWithPath(basePath);
    if (!success){
        //call createAndPush("CBControls/BasesList.qml")
        QMetaObject::invokeMethod(this->applicationWindow,
                                  "openBaseAlert"
                                  );
        CBSettings *settings =  CBSettings::settingsInstance();
        settings->removeRecentByPath(basePath);
    }
}

void CBController::providerReadyToWork(){
    engine->addImageProvider(QLatin1String("imageProvider"),m_baseProvider->imageProvider);
    QMetaObject::invokeMethod(this->applicationWindow,
                              "providerReadyToWork"
                              );
}

void CBController::openRecentBase(QString baseName){
    QString path = CBSettings::settingsInstance()->recentPathByName(baseName);
    if (path!=""){
        openBase(path);
    }
}

void CBController::appWillTerminate(){
    if (m_baseProvider) {
        delete m_baseProvider;
    }
}

void CBController::saveForm(const QString& qmlString, const QString& formName){
    const QString formRoot = "generatedForms/";
    if (!QDir(formRoot).exists()){
        QDir().mkdir(formRoot);
    }
    CBUtils::SaveStringToFile(qmlString,formRoot + formName);
}

QString CBController::getAbout(){
    QString about = "<html><body>";

    about += tr("Build date: ") +QString(__DATE__) +" " + QString(__TIME__)+"<br/>";
    about += QString("Git commit: %1").arg(GIT_CURRENT_SHA1)+"<br/>";
    const char *qt_version = qVersion();
    about += "Qt version: " + QString(qt_version) + "<br/>";
    about += tr("If you have some question, you can write to ") + "<a href=\"mailto:kazansky85@gmail.com\">kazansky85@gmail.com</a>";

    about += "</body></html>";
    return about;
}

bool CBController::stackViewOnRemoved(){
    const char *qt_version = qVersion();;
    return !QString(qt_version).startsWith("5.7");
}
