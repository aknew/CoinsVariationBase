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
        try {
            this->openBase(basePath);
        }
        catch (...) {
            QMetaObject::invokeMethod(this->applicationWindow,
                                      "openBaseAlert"
                                      );
        }
    }
    else{
        //call createAndPush("CBControls/BasesList.qml")
        QMetaObject::invokeMethod(this->applicationWindow,
                                  "openBaseList"
                                  );
    }
}

void CBController::openBase(QString basePath){

    CBUtils::FromQmlFilePath(&basePath);

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
                                  "openBaseList"
                                  );
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
    QString about = tr("Build date: ") +QString(__DATE__) +" " + QString(__TIME__);
    return about;
}
