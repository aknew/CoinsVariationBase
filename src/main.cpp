#include <QtQml>
#include <QtWidgets/QApplication>

#include "CBController.h"

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

int main(int argc, char *argv[])
{
    qSetMessagePattern("%{file}(%{line}): %{message}"); //show line and file in qDebug messages

    qmlRegisterSingletonType<CBController>("CB.api", 1, 0, "CBApi", cbApiObjectSingleton);
    qmlRegisterUncreatableType<CBBaseProvider>("CB.api", 1, 0, "CBBaseProvider", "The object of this class should be obtained from CBApi.baseProvider");
    qmlRegisterUncreatableType<CBNode>("CB.api", 1, 0, "CBNode", "The object of this class should be obtained from CBApi.baseProvider.getNode(name) or CBApi..baseProvider.getStartNode()");

    QApplication app(argc, argv);

    // Init GUI
    QQmlApplicationEngine engine(QUrl("qrc:/main.qml"));
    engine.addImportPath("qrc:/");
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

    cvbAPI->start();

    return app.exec();
}

