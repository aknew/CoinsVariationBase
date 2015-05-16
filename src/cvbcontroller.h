#ifndef CVBCONTROLLER_H
#define CVBCONTROLLER_H

#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickView>
#include <QtQml>
#include "CVBBaseProvider.h"
#include "CVBImageProvider.h"
#include "CVBSqlNode.h"

enum kCurrentWidget{
    QMLListWithoutEditing,
    FullForm,
    FullScreenImage
};

class CVBController : public QObject
{
    Q_OBJECT
    CVBBaseProvider *baseProvider;
    CVBImageProvider *imageProvider;
    QStack<kCurrentWidget> currentWidgetType;
    bool newRowInsertion;

   public:
       CVBController(QObject *parent = 0)
           : QObject(parent)
       {
           baseProvider = NULL;
       }

       ~CVBController() {}

       void start();
       void addViewToStack(const QQuickView *view);
       QQuickView *newDeclarativeView();
       QQuickItem *stackView;
       QQuickWindow *applicationWindow;
       QQuickItem *currentItem();

       QQmlApplicationEngine *engine;

   public slots:
       //взаимодействие с baseProvider
       void newTableWidget();
       void removeWidgetFromStack();
       void showError(QString str);

       //взаимодействие с qml
       Q_INVOKABLE void buttonPressed(int index);
       Q_INVOKABLE void fullInfo(int index);
       Q_INVOKABLE void showFullScreenImage(QString imgSource);
       Q_INVOKABLE QStringList listForName(const QString& name);
       Q_INVOKABLE CVBSqlNode* nodeWithName(const QString& name);
       Q_INVOKABLE CVBSqlNode* currentNode();

       Q_INVOKABLE void saveListForm(const QString& qmlString);
       Q_INVOKABLE void saveFullForm(const QString& qmlString);


       Q_INVOKABLE void needPopCurrentNode();
       Q_INVOKABLE void addNewRecord();
       Q_INVOKABLE void deleteCurrentRecord();
       Q_INVOKABLE void applyChanges();
       Q_INVOKABLE void dropChanges();
       Q_INVOKABLE void startEditRecord();

       //попытка вызвать диалог и загрузить в нем новую картинку, если все хорошо - вернется ее ссылка, если нет - -1
       //этот же метод вставит картикну из буфера обмена если ему передать imagePath=NULL (значение по умолчанию)
       Q_INVOKABLE QVariant loadNewImage(QString imagePath);
       Q_INVOKABLE void saveImage(QString imageId, QString imagePath);

       Q_INVOKABLE void openBase(QString basePath);

};

#endif // CVBCONTROLLER_H
