#ifndef CBCONTROLLER_H
#define CBCONTROLLER_H

#include <QObject>
#include <QtQml>
#include <QQuickWindow>

class CBController : public QObject
/**

*/
{
    Q_OBJECT
public:
    explicit CBController(QObject *parent = 0);
    void start();

    QQuickWindow *applicationWindow;
    QQmlApplicationEngine *engine;

signals:

public slots:

    Q_INVOKABLE void openBase(QString basePath);
};

#endif // CBCONTROLLER_H
