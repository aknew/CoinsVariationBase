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

    Q_PROPERTY(CBBaseProvider *baseProvider MEMBER m_baseProvider CONSTANT)

public:
    explicit CBController(QObject *parent = 0);
    void start(); ///< starts all actions, runs once from main

    QQuickWindow *applicationWindow; ///< needs for invoking some actions like "need show message" or "need save generated qml"
    QQmlApplicationEngine *engine; ///< needs for set imageProvider

    Q_INVOKABLE void openBase(QString basePath); ///< open base with path, is usualy called from qml openDialog and from start method
    Q_INVOKABLE void openRecentBase(QString baseName); ///< try to open recent base by name, its path will be got from settings

    Q_INVOKABLE void saveForm(const QString& qmlString, const QString& formName);
    Q_INVOKABLE QString getAbout();
    // HOTFIX: Using Qt.createQmlObject with StackView will cause memory leek in qt 5.7. It is known qt bug that was fixed (by adding signal) in qt5.8, see https://stackoverflow.com/questions/39063235/qtquick-controls-2-stackview-and-destroyonpop
    Q_INVOKABLE bool stackViewOnRemoved();

    enum FormType{
        ListForm,
        FullForm,
        FilterDialog,
        AttachForm,
        OpenBaseForm
    };
    Q_ENUM(FormType)

private:
    CBBaseProvider *m_baseProvider;

public slots:
    void providerReadyToWork();
    void appWillTerminate();

};

#endif // CBCONTROLLER_H
