#include "CBController.h"

#include <QtWidgets/QApplication>

#include "CBUtils.h"
#include "CBTranslator.h"
#include "CBSettings.h"

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


    CBSettings *settings = CBSettings::settingsInstance();
    settings->lastBasePath = basePath;
    settings->saveSetting();

    bool needCollect = settings->needCollect; //FIXME: It should be not here

    this->applicationWindow->setProperty("needCollect", QVariant(needCollect));

    if (m_baseProvider) {
        delete m_baseProvider;
    }

    CBUtils::FromQmlFilePath(&basePath);

    // load translator for specific base termins (mostly fieldnames)
    // FIXME: Need 2 translator - one for base termins (this one) and one for system messages

    QString locale = QLocale::system().name();
    QString filename = QString("languages/") + locale+".json";
    static CBTranslator translator;
    translator.m_needCollect = needCollect;
    if( translator.load(filename, basePath) ){
        QApplication::instance()->installTranslator(&translator);
        //QTextCodec::setCodecForTr(QTextCodec::codecForName("utf8"));
        qDebug() << "Translation file loaded" << filename;
    } else
        qDebug() << "Translation file not loaded:" << filename << "  dir:"<<basePath;



    m_baseProvider=new CBBaseProvider();
    this->connect(m_baseProvider,SIGNAL(readyToWork()),this,SLOT(providerReadyToWork()));
    m_baseProvider->startWithPath(basePath);
}

void CBController::providerReadyToWork(){
    engine->addImageProvider(QLatin1String("imageProvider"),m_baseProvider->imageProvider);
    QMetaObject::invokeMethod(this->applicationWindow,
                              "providerReadyToWork"
                              );
}
