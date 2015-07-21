#ifndef CBCONTROLLER_H
#define CBCONTROLLER_H

#include <QObject>
#include <QtQml>
#include <QQuickWindow>

class CBController : public QObject
/*!
          \brief This class is used as bridge between c++ and qml

*/
{
    Q_OBJECT
public:
    explicit CBController(QObject *parent = 0);
    void start(); ///< starts all actions, runs once from main

    QQuickWindow *applicationWindow; ///< needs for invoking some actions like "need show message" or "need save generated qml"
    QQmlApplicationEngine *engine; ///< needs for set imageProvider

signals:

public slots:

    Q_INVOKABLE void openBase(QString basePath); ///< open base with path, is usualy called from qml openDialog and from start method
};

#endif // CBCONTROLLER_H
