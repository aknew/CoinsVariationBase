#ifndef MAINWINDOW_H
#define MAINWINDOW_H
#ifdef HAVE_QT5

#include <QtWidgets/QMainWindow>

#else

#include <QtGui/QMainWindow>

#endif

#include <QStackedWidget>
#include <QtDeclarative>
#include "CVBBaseProvider.h"
#include "CVBImageProvider.h"

//TODO потом переделать все это в QDeclarativeEngine

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


class MainWindow : public QMainWindow
{
    Q_OBJECT
    //TODO QML PageStack Element - использовать его после того как выйдет 5.0 с включенным в основную поставку qtComponents
    QStackedWidget *stackedWidget;
    CVBBaseProvider *baseProvider;
    CVBImageProvider *imageProvider;
    void initShortcuts();
    void addNavBar();
    //QStack<int> _currentIndex;
    QStack<kCurrentWidget> currentWidgetType;
    QToolBar *navBar;
    bool newRowInsertion;
    bool useMobileForms;

public:

    enum ScreenOrientation {
        ScreenOrientationLockPortrait,
        ScreenOrientationLockLandscape,
        ScreenOrientationAuto
    };

    MainWindow(QWidget *parent = 0);
    ~MainWindow();
    bool isFirstWidget();

    //void setOrientation(ScreenOrientation orientation); //FIXME - qt 5.0.0 error
    void showExpanded();
    void addWidgetToStack(QWidget* wgt);
    QDeclarativeView *newDeclarativeView();

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
};

#endif // MAINWINDOW_H
