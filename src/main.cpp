#include <QtQml>
#include <QGuiApplication>
#include <iostream>

#include "CBController.h"
#include "CBSettings.h"
#include "CBBaseIconProvider.h"
#include "CBFieldDifference.h"
#include "CBItemDifference.h"

void logHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{

    static QString logName = "CoinsBase" + QDateTime::currentDateTime().toString("yyyy-MM-dd-HH-mm") + ".log";
    QString txt = QString("%1:%2\t%3").arg(context.file)
            .arg(context.line)
            .arg(msg);

    switch (type) {
    case QtInfoMsg:
        txt = "Info:\t"+ txt;
        break;
    case QtDebugMsg:
        txt = "Debug:\t"+ txt;
        break;
    case QtWarningMsg:
        txt = "Warning:\t"+ txt;
    break;
    case QtCriticalMsg:
        txt = "Critical:\t"+ txt;
    break;
    case QtFatalMsg:
        txt = "Fatal:\t " + txt;
        break;
    }
    QFile outFile(logName);
    outFile.open(QIODevice::WriteOnly | QIODevice::Append);
    QTextStream ts(&outFile);
    ts << txt << endl;
    if (type == QtInfoMsg){
        std::cout << txt.toStdString() << std::endl;
    }
    else{
        std::cerr << txt.toStdString() << std::endl;
    }
}

static QObject *cbApiObjectSingleton(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    static CBController *api = NULL;

    if (api == NULL){
        api = new CBController();
    }

    return api;
}

static QObject *cbSettingsObjectSingleton(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return  CBSettings::settingsInstance();
}

int main(int argc, char *argv[])
{
#if defined(Q_OS_IOS) || defined(Q_OS_ANDROID)
    // I don't need log message on iOS and android
    qSetMessagePattern("%{file}(%{line}): %{message}"); //show line and file in qDebug messages
#else
    qInstallMessageHandler(logHandler);
#endif

    qmlRegisterSingletonType<CBController>("CB.api", 1, 0, "CBApi", cbApiObjectSingleton);
    qmlRegisterSingletonType<CBSettings>("CB.api", 1, 0, "CBSettings", cbSettingsObjectSingleton);
    qmlRegisterUncreatableType<CBBaseProvider>("CB.api", 1, 0, "CBBaseProvider", "The object of this class should be obtained from CBApi.baseProvider");
    qmlRegisterUncreatableType<CBNode>("CB.api", 1, 0, "CBNode", "The object of this class should be obtained from CBApi.baseProvider.getNode(name) or CBApi.baseProvider.getStartNode()");
    qmlRegisterUncreatableType<CBAttachmentsProvider>("CB.api", 1, 0, "CBAttachmentsProvider", "The object of this class should be obtained from CBApi.baseProvider.notesProvider");
    qmlRegisterType<CBFieldDifference>("CB.api", 1, 0, "CBFieldDifference");
    qmlRegisterUncreatableType<CBItemDifference>("CB.api", 1, 0, "CBItemDifference", "The object of this class should be obtained from CBNode recordDifference() method");

    QGuiApplication app(argc, argv);

    // load translator

    QString locale = QLocale::system().name();
    static CBTranslator translator;
    translator.m_needCollect = true;
    if( translator.load("", ":/") ){
        app.installTranslator(&translator);
    }

    // Init GUI
    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/");

    CBBaseIconProvider *baseIconProvider = new CBBaseIconProvider(QQuickImageProvider::Pixmap);

    engine.addImageProvider(QLatin1String("baseIconProvider"),baseIconProvider);
    engine.load(QUrl("qrc:/main.qml"));

    QObject *topLevel = engine.rootObjects().value(0);
    QQuickWindow *window = qobject_cast<QQuickWindow *>(topLevel);
    if ( !window ) {
        qWarning("Error: Your root item has to be a Window.");
        return -1;
    }
    window->show();


    // Init Controller
    CBController *cvbAPI =qobject_cast<CBController *>(cbApiObjectSingleton(NULL, NULL));

    cvbAPI->applicationWindow = window;
    cvbAPI->engine = &engine;

    QObject::connect(&app,&QGuiApplication::aboutToQuit,cvbAPI,&CBController::appWillTerminate);

    cvbAPI->start();

    return app.exec();
}

