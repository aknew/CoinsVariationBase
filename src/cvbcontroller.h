#ifndef CVBCONTROLLER_H
#define CVBCONTROLLER_H

#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickView>
#include "CVBBaseProvider.h"
#include "CVBImageProvider.h"

enum kCurrentWidget{
    QMLListWithoutEditing,
    EditableQMLList,
    FullForm,
    TableForm,
    FullScreenImage
};

class CVBController : public QObject
{
    Q_OBJECT
    //Q_PROPERTY (int someProperty READ someProperty WRITE setSomeProperty NOTIFY somePropertyChanged)
    CVBBaseProvider *baseProvider;
    CVBImageProvider *imageProvider;
    QStack<kCurrentWidget> currentWidgetType;
    bool newRowInsertion;
    bool useMobileForms;

   public:
       CVBController(QObject *parent = 0)
           : QObject(parent)
       {
           baseProvider = NULL;
       }

       ~CVBController() {}

       void start();
       bool isFirstWidget();
       void showExpanded();
       void addViewToStack(const QQuickView *view);
       QQuickView *newDeclarativeView();
       QQuickItem *stackView;
       QQuickWindow *applicationWindow;
       QQuickItem *currentItem();

       //  константы-кнопки, не входящие в список переходов (назад, новая запись, удалить и т.п.)
       enum kButtonI{
           backButtonIndex=-1,
           newButtonIndex=-2,
           deleteButtonIndex=-3,
           applyButtonIndex=-4,
           undoButtonIndex=-5,
           editButtonIndex=-6
       };

   public slots:
       //взаимодействие с baseProvider
       void newTableWidget();
       void removeWidgetFromStack();
       void showError(QString str);

       //взаимодействие с qml
       Q_INVOKABLE void buttonPressed(int index);
       Q_INVOKABLE void fullInfo(int index);
       Q_INVOKABLE void showFullScreenImage(QString imgSource);
       Q_INVOKABLE void dataChanged();
       Q_INVOKABLE QVariant listForName(const QString& name);

       //попытка вызвать диалог и загрузить в нем новую картинку, если все хорошо - вернется ее ссылка, если нет - -1
       //этот же метод вставит картикну из буфера обмена если ему передать imagePath=NULL (значение по умолчанию)
       Q_INVOKABLE QVariant loadNewImage(QString imagePath);

       Q_INVOKABLE void openBase(QString basePath);

};

#endif // CVBCONTROLLER_H
