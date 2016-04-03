#include <QtQml>
#include <QtWidgets/QApplication>

#include "CBController.h"
#include "CBSettings.h"
#include "CBBaseIconProvider.h"

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
    qSetMessagePattern("%{file}(%{line}): %{message}"); //show line and file in qDebug messages

    qmlRegisterSingletonType<CBController>("CB.api", 1, 0, "CBApi", cbApiObjectSingleton);
    qmlRegisterSingletonType<CBSettings>("CB.api", 1, 0, "CBSettings", cbSettingsObjectSingleton);
    qmlRegisterUncreatableType<CBBaseProvider>("CB.api", 1, 0, "CBBaseProvider", "The object of this class should be obtained from CBApi.baseProvider");
    qmlRegisterUncreatableType<CBNode>("CB.api", 1, 0, "CBNode", "The object of this class should be obtained from CBApi.baseProvider.getNode(name) or CBApi.baseProvider.getStartNode()");
    qmlRegisterUncreatableType<CBAttachmentsProvider>("CB.api", 1, 0, "CBAttachmentsProvider", "The object of this class should be obtained from CBApi.baseProvider.notesProvider");

    QApplication app(argc, argv);

    // load translator

    QString locale = QLocale::system().name();
    QString filename = ":/"+locale+".json";
    static CBTranslator translator;
    translator.m_needCollect = true;
    if( translator.load(filename, "") ){
        app.installTranslator(&translator);
    } else
        qDebug() << "Translation file not loaded:" << filename << "  dir:"<< ".";

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

    QObject::connect(&app,&QApplication::aboutToQuit,cvbAPI,&CBController::appWillTerminate);

    cvbAPI->start();

    return app.exec();
}

