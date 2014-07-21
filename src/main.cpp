#include <QtGui/QGuiApplication>
#include <QtQml>
#include <QtQuick/QQuickView>
#include <QtCore/QString>
#include <QtCore/QUrl>
#include "CVBController.h"
#include <QtWidgets/QApplication>
#include "CVBSqlNode.h"

static QObject *cvbApiObjectSingleton(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    static CVBController *api = NULL;

    if (api == NULL){
        api = new CVBController();
    }

    return api;
}

int main(int argc, char *argv[])
{
    qmlRegisterSingletonType<CVBController>("CVB.api", 1, 0, "CVBApi", cvbApiObjectSingleton);
    qmlRegisterUncreatableType<CVBSqlNode>("CVB.api", 1, 0, "CVBSqlNode", "This class should be obtained from CVBApi.nodeWithName()");

    QApplication app(argc, argv);
    QQmlApplicationEngine engine(QUrl("qrc:/MainWindow.qml"));
    engine.addImportPath("qrc:/");
    QObject *topLevel = engine.rootObjects().value(0);
    QQuickWindow *window = qobject_cast<QQuickWindow *>(topLevel);
    if ( !window ) {
        qWarning("Error: Your root item has to be a Window.");
        return -1;
    }
    window->show();

    CVBController *cvbAPI =qobject_cast<CVBController *>(cvbApiObjectSingleton(NULL, NULL));

    cvbAPI->applicationWindow = window;

    QQuickItem *item= window->findChild<QQuickItem*>("tablesStack");
    cvbAPI->stackView = item;

    cvbAPI->engine = &engine;

    cvbAPI->start();
    return app.exec();
}
