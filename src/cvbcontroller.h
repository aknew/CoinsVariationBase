#ifndef CVBCONTROLLER_H
#define CVBCONTROLLER_H

#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickView>
#include "CVBBaseProvider.h"
#include "CVBImageProvider.h"

//  константы-кнопки, не входящие в список переходов (назад, новая запись, удалить и т.п.)
enum kButtonI{
    backButtonIndex=-1,
    newButtonIndex=-2,
    deleteButtonIndex=-3,
    applyButtonIndex=-4,
    undoButtonIndex=-5,
    editButtonIndex=-6
};
//строковые константы для QPushButton

#define kBACK_BUTTON "back"
#define kNEW_BUTTON "new"
#define kDELETE_BUTTON "delete"
#define kAPPLY_CHANGES_BUTTON "apply changes"
#define kUNDO_CHANGES_BUTTON "undo changes"
#define kEDIT_BUTTON "edit item"
#define kSYSTEM_TABLES_BUTTON "system tables"

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
    void initShortcuts();
    //QStack<int> _currentIndex;
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

       //Q_INVOKABLE int doSomething() { setSomeProperty(5); return m_someProperty; }

       void start();
       bool isFirstWidget();
       void showExpanded();
       void addViewToStack(const QQuickView *view);
       QQuickView *newDeclarativeView();
       QQuickItem *stackView;
       QQuickWindow *applicationWindow;

   public slots:
       //взаимодействие с baseProvider
       void newTableWidget();
       void removeWidgetFromStack();
       void showError(QString str);

       void buttonPressed();//для QPushButton и QShortcut

       //взаимодействие с qml
       Q_INVOKABLE void buttonPressed(int index);
       Q_INVOKABLE void fullInfo(int index);
       Q_INVOKABLE void showFullScreenImage(QString imgSource);
       Q_INVOKABLE QVariant imageRightClick(const QString& id, int x, int y, bool editable);
       Q_INVOKABLE void dataChanged();
       Q_INVOKABLE QVariant listForName(const QString& name);

       //попытка вызвать диалог и загрузить в нем новую картинку, если все хорошо - вернется ее ссылка, если нет - -1
       Q_INVOKABLE QVariant loadNewImage();

       Q_INVOKABLE void openBase(QString basePath);

};

#endif // CVBCONTROLLER_H
