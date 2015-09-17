#ifndef CBCONTROLLER_H
#define CBCONTROLLER_H

#include <QObject>
#include <QtQml>
#include <QQuickWindow>

#include "CBBaseProvider.h"

class CBController : public QObject
/*!
          \brief Bridge between c++ and qml

*/
{
    Q_OBJECT

    Q_PROPERTY(CBBaseProvider *baseProvider MEMBER m_baseProvider FINAL)

public:
    explicit CBController(QObject *parent = 0);
    void start(); ///< starts all actions, runs once from main

    QQuickWindow *applicationWindow; ///< needs for invoking some actions like "need show message" or "need save generated qml"
    QQmlApplicationEngine *engine; ///< needs for set imageProvider

    Q_INVOKABLE void openBase(QString basePath); ///< open base with path, is usualy called from qml openDialog and from start method

private:
    CBBaseProvider *m_baseProvider;

public slots:
    void providerReadyToWork();

};

#endif // CBCONTROLLER_H