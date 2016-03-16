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

    if (basePath.isEmpty()){
        QMetaObject::invokeMethod(this->applicationWindow,
                                  "openBase"
                                  );
    }
    else {
        try {
            this->openBase(basePath);
        }
        catch (...) {
            QMetaObject::invokeMethod(this->applicationWindow,
                                      "openBaseAlert"
                                      );
        }
    }

}

void CBController::openBase(QString basePath){

    CBUtils::FromQmlFilePath(&basePath);
    CBSettings *settings = CBSettings::settingsInstance();

    bool needCollect = settings->needCollect;

    this->applicationWindow->setProperty("needCollect", QVariant(needCollect));

    if (m_baseProvider) {
        engine->removeImageProvider(QLatin1String("imageProvider"));
        engine->removeImageProvider(QLatin1String("mainProvider"));
        delete m_baseProvider;
    }

    m_baseProvider=new CBBaseProvider();
    this->connect(m_baseProvider,SIGNAL(readyToWork()),this,SLOT(providerReadyToWork()));
    m_baseProvider->startWithPath(basePath);
}

void CBController::providerReadyToWork(){
    engine->addImageProvider(QLatin1String("imageProvider"),m_baseProvider->imageProvider);
    engine->addImageProvider(QLatin1String("mainProvider"),m_baseProvider->mainProvider);
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
