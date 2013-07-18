#include <QtGui/QGuiApplication>
#include <QtQml>
#include <QtQuick/QQuickView>
#include <QtCore/QString>
#include <QtCore/QUrl>
#include "CVBController.h"
#include <QtWidgets/QApplication>

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

    QApplication app(argc, argv);
    QQmlApplicationEngine engine(QUrl("qrc:/MainWindow.qml"));
    QObject *topLevel = engine.rootObjects().value(0);
    QQuickWindow *window = qobject_cast<QQuickWindow *>(topLevel);
    if ( !window ) {
        qWarning("Error: Your root item has to be a Window.");
        return -1;
    }
    window->show();

    CVBController *cvbAPI =qobject_cast<CVBController *>(cvbApiObjectSingleton(NULL, NULL));

    cvbAPI->applicationWindow = window;

    //TODO: may be rigth way is find by name (QObject *rect = object->findChild<QObject*>("rect");)
    QQuickItem *item = window->contentItem();
    item = item->childItems().first()->childItems().at(1); //ApplicationWindow content area
    item = item->childItems().first(); // StackView is single subitem of contentarea in my qml
    cvbAPI->stackView = item;

    cvbAPI->start();
    return app.exec();
}
