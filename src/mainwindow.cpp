#include "mainwindow.h"
#include "CVBSqlRelationalTableModel.h"
#include "delegatedtableview.h"

//#define QTableViewUsing

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    //qmlRegisterType<ListModel>("ListModel",1,0,"ListModel");

    stackedWidget=new QStackedWidget();
    this->setCentralWidget(stackedWidget);
    //FIXME need show only that button, that can be used on this form i.e. not show edit at list form or back in first form

    navBar=new QToolBar(this);

#if defined(Q_OS_ANDROID)
    navBar->setMinimumHeight(100);
    navBar->setIconSize(QSize(100,100));
#endif

    this->addToolBar(navBar);

    QString basePath;
    QSettings settings("settings.ini",QSettings::IniFormat);
    settings.setIniCodec("windows-1251");
    basePath=settings.value("global/base","").toString();

    if (basePath.isEmpty()){
#if defined(Q_OS_ANDROID)
        basePath="/sdcard/CoinsBase.base/base.sqlite";  //FIXME QFileDialog doesn't working good in necessitas alpha 4.1
#else
        QFileDialog *dialog=new QFileDialog(parent,tr("Select file"),QString(),tr("sqlite databases files (*.sqlite)"));
        if (dialog->exec()){
            QStringList filenames=dialog->selectedFiles();
            if (filenames.count()!=0){
                basePath=filenames.at(0);
                settings.setValue("global/base",basePath);
            }
        }
#endif
    }
    //TODO check that something was selected
    baseProvider=new CVBBaseProvider(basePath,this);

    this->connect(baseProvider,SIGNAL(removeCurrentWidget()),this,SLOT(removeWidgetFromStack()));
    this->connect(baseProvider,SIGNAL(newTableWidget()),this,SLOT(newTableWidget()));
    this->connect(baseProvider,SIGNAL(getError(QString)),this,SLOT(showError(QString)));

    imageProvider= new CVBImageProvider(QDeclarativeImageProvider::Pixmap);
    imageProvider->imageFolder=baseProvider->basePath+"images/";

    baseProvider->startLevel();
    this->initShortcuts();
    addNavBar();
}

MainWindow::~MainWindow()
{

}

bool MainWindow::isFirstWidget(){
    return stackedWidget->count()==0;
}

//Показ ошибок

void MainWindow::showError(QString str){
    QMessageBox::warning(this,"Attention",str, QMessageBox::Yes);
}

// Общие действия при загрузке-выгрузке страниц

void MainWindow::addNavBar(){
    //FIXME nen yflj crhsdfnm
    navBar->clear();
    QAction *action=navBar->addAction(QIcon(":///icons/back.png"),tr(kBACK_BUTTON));
    action->setObjectName(kBACK_BUTTON);
    connect(action,SIGNAL(triggered()),this,SLOT(buttonPressed()));
#if !defined(Q_OS_ANDROID)
    action=navBar->addAction(QIcon(":///icons/edit.png"),tr(kEDIT_BUTTON));
    action->setObjectName(kEDIT_BUTTON);
    connect(action,SIGNAL(triggered()),this,SLOT(buttonPressed()));

    action=navBar->addAction(QIcon(":///icons/add.png"),tr(kNEW_BUTTON));
    action->setObjectName(kNEW_BUTTON);
    connect(action,SIGNAL(triggered()),this,SLOT(buttonPressed()));

    action=navBar->addAction(QIcon(":///icons/delete.png"),tr(kDELETE_BUTTON));
    action->setObjectName(kDELETE_BUTTON);
    connect(action,SIGNAL(triggered()),this,SLOT(buttonPressed()));

    QMenu *menu = new QMenu();

    for (int i=0; i<baseProvider->systemTables.count(); ++i){
        action=new QAction(baseProvider->systemTables.at(i),this);
        //FIXME Надо бы убрать жесткую связку через строку, да и вообще этот кусок грязноват
        action->setObjectName(baseProvider->systemTables.at(i));
        connect(action,SIGNAL(triggered()),this,SLOT(buttonPressed()));
        menu->addAction(action);
    }

    QToolButton* toolButton = new QToolButton();
    toolButton->setIcon(QIcon(":///icons/Database.png"));
    toolButton->setMenu(menu);
    toolButton->setPopupMode(QToolButton::InstantPopup);
    navBar->addWidget(toolButton);

#endif
    //navBar->setVisible(stackedWidget->count()>1);
}

void MainWindow::addWidgetToStack(QWidget* wgt){
    stackedWidget->addWidget(wgt);
    stackedWidget->setCurrentWidget(wgt);
    /*
    if (stackedWidget->count()>1)
        navBar->setVisible(true);
        */
}

void MainWindow::removeWidgetFromStack(){
    QWidget *wgt=stackedWidget->currentWidget();
    stackedWidget->removeWidget(wgt);
    //delete wgt; //FIXME падает при кнопке назад, пришлось закомментить
    currentWidgetType.pop();
    /*
    if (!isFullInfo.top()){
        _currentIndex.pop();
    }
    */
    /*
    if (stackedWidget->count()==1)
        navBar->setVisible(false);
        */
}

//Загрузка различных страниц

QVariant MainWindow::listForName(const QString& name){
    return QVariant(baseProvider->listForID(name));
}

void MainWindow::newTableWidget(){
#ifndef QTableViewUsing

#if defined(Q_OS_ANDROID)
    QString str=baseProvider->basePath+"mobile-forms/";
#else
    QString str=baseProvider->basePath+"forms/";
#endif

    if (baseProvider->currentNode()->listFormName.isEmpty()){
        //в xml не было указания на конкретную форму, пробуем собрать ее на месте
        str=str+baseProvider->currentNode()->model->tableName()+".qml";
    }
    else {
        str=str+baseProvider->currentNode()->listFormName+".qml";
    }

    if (QFile::exists(str)){

        QDeclarativeView *w=newDeclarativeView();
        w->setResizeMode(QDeclarativeView::SizeRootObjectToView);
        w->rootContext()->setContextProperty("myModel", baseProvider->currentNode()->model);
        w->setSource(QUrl::fromLocalFile(str));

        this->addWidgetToStack(w);
        currentWidgetType.push(QMLListWithoutEditing);
    }
    else
#endif
    {
        //файла с формой нет, будет задействованна стандартная табличка
        DelegatedTableView *newTableView= new DelegatedTableView();
        newTableView->setBaseProvider(baseProvider);
        this->addWidgetToStack(newTableView);
        currentWidgetType.push(TableForm);
        QObject::connect(newTableView->model(),SIGNAL(dataChanged(QModelIndex,QModelIndex)),this,SLOT(dataChanged()));
    }
}

void MainWindow::fullInfo(int index){

    //_currentIndex.push(index);

    CVBSqlRelationalTableModel *listModel=baseProvider->currentNode()->model;
    listModel->selectedRow=index;

#if defined(Q_OS_ANDROID)
    QString str=baseProvider->basePath+"mobile-forms/";
#else
    QString str=baseProvider->basePath+"forms/";
#endif

    if (baseProvider->currentNode()->fullFormName.isEmpty()){
        //в xml не было указания на конкретную форму, пробуем собрать ее на месте
        str=str+baseProvider->currentNode()->model->tableName()+"FullInfo.qml";
    }
    else {
        str=str+baseProvider->currentNode()->fullFormName+".qml";
    }

    if (QFile::exists(str)){

        QDeclarativeView *w=newDeclarativeView();

        w->setResizeMode(QDeclarativeView::SizeRootObjectToView);
        w->rootContext()->setContextProperty("myModel", listModel);
        w->rootContext()->setContextProperty("nextLevelList", QVariant::fromValue(baseProvider->buttonIDs()));

        w->rootContext()->setContextProperty("selectedItem",listModel->selectedItem());

        w->setSource(QUrl::fromLocalFile(str));

        this->addWidgetToStack(w);
        currentWidgetType.push(FullForm);
    }
    else {
        qDebug()<<QString::fromUtf8("файла с формой полной информации нет, потом здесь будет загрузка диалога выбора следующего уровня");
        return;
    }
}

void MainWindow::showFullScreenImage(QString imgSource){

    QDeclarativeView *w=newDeclarativeView();
    w->rootContext()->setContextProperty("imgSource",imgSource);
    w->setSource(QUrl::fromLocalFile(baseProvider->basePath+"forms/BigImage.qml"));

    this->addWidgetToStack(w);
    currentWidgetType.push(FullScreenImage);
}

QDeclarativeView *MainWindow::newDeclarativeView(){

    QDeclarativeView *w=new QDeclarativeView();
    w->setResizeMode(QDeclarativeView::SizeRootObjectToView);
    w->engine()->addImageProvider(QLatin1String("imageProvider"),imageProvider);
    w->rootContext()->setContextProperty("window",this);
    return w;
}


//Работа с кнопками

void MainWindow::initShortcuts(){
/*
    //Новая запись
    QShortcut *shotcutNewType=new QShortcut(this);
    shotcutNewType->setKey(QKeySequence("Ctrl+N"));
    shotcutNewType->setObjectName("newRow");
    this->connect(shotcutNewType,SIGNAL(activated()),this,SLOT(buttonPressed()));

    shotcutNewType=new QShortcut(this);
    shotcutNewType->setKey(QKeySequence("Ctrl+S"));
    shotcutNewType->setObjectName("save");
    this->connect(shotcutNewType,SIGNAL(activated()),this,SLOT(buttonPressed()));


    //Вернуться на предыдущий уровень
    QShortcut *shotcutPreviousLevel=new QShortcut(this);
    shotcutPreviousLevel->setKey(QKeySequence("Ctrl+Backspace"));
    shotcutPreviousLevel->setObjectName("back");
    this->connect(shotcutPreviousLevel,SIGNAL(activated()),this,SLOT(buttonPressed()));
    */
}

void MainWindow::buttonPressed(){
    QString senderName=QObject::sender()->objectName();
    int buttonIndex=INT_MIN;
    if (senderName==kBACK_BUTTON)
        buttonIndex=backButtonIndex;
    else if (senderName==kNEW_BUTTON)
        buttonIndex=newButtonIndex;
    else if (senderName==kEDIT_BUTTON)
        buttonIndex=editButtonIndex;
    else if (senderName==kAPPLY_CHANGES_BUTTON)
        buttonIndex=applyButtonIndex;
    else if (senderName==kUNDO_CHANGES_BUTTON)
        buttonIndex=undoButtonIndex;
    else if (senderName==kDELETE_BUTTON)
        buttonIndex=deleteButtonIndex;
    else{
        //FIXME Надо бы убрать жесткую связку через строку, да и вообще этот кусок грязноват
        baseProvider->loadSystemTables(senderName);
        return;
    }
    qDebug()<<senderName<<" "<<buttonIndex;
    this->buttonPressed(buttonIndex);
    qDebug()<<senderName<<" "<<buttonIndex;
}

void MainWindow::buttonPressed(int index){

    qDebug()<<index;
    if(index<0){
        //что- то из предопредопределенных кнопок
        switch (index) {
        case backButtonIndex:{
            if (currentWidgetType.top()==FullForm||currentWidgetType.top()==FullScreenImage)
                this->removeWidgetFromStack();
            else {
                baseProvider->previousLevel();
                if (currentWidgetType.top()!=TableForm){
                    QWidget *wgt=stackedWidget->currentWidget();
                    QDeclarativeView *w=qobject_cast<QDeclarativeView*>(wgt);
                    w->setSource(w->source());
                }
            }
            break;
        case newButtonIndex:{
                newRowInsertion=true;
                if (currentWidgetType.top()==TableForm){
                    baseProvider->insertNewRow();
                    QWidget *wgt=stackedWidget->currentWidget();
                    DelegatedTableView *w=qobject_cast<DelegatedTableView*>(wgt);
                    if (w) {
                        w->selectRow(w->model()->rowCount()-1);
                        dataChanged();
                    }
                    return;
                }

                CVBSqlRelationalTableModel *model = baseProvider->currentNode()->model;
                model->selectedRow=model->rowCount();
                if (currentWidgetType.top()==QMLListWithoutEditing){
                    this->fullInfo(model->selectedRow);
                    QWidget *wgt=stackedWidget->currentWidget();
                    QDeclarativeView *w=qobject_cast<QDeclarativeView*>(wgt);
                    w->rootObject()->setProperty("state","editable");
                }
                else{
                    QWidget *wgt=stackedWidget->currentWidget();
                    QDeclarativeView *w=qobject_cast<QDeclarativeView*>(wgt);
                    w->rootContext()->setContextProperty("selectedItem",model->selectedItem());
                    w->setSource(w->source());
                    w->rootObject()->setProperty("state","editable");
                }
                dataChanged();
                break;

            }
        case editButtonIndex:{
                QWidget *wgt=stackedWidget->currentWidget();
                QDeclarativeView *w=qobject_cast<QDeclarativeView*>(wgt);
                w->rootObject()->setProperty("state","editable");
                dataChanged();
                break;
            }
        case applyButtonIndex:{

                if (currentWidgetType.top()==TableForm){
                    baseProvider->submitNewRow();
                    this->addNavBar();
                    newRowInsertion=false;
                    return;
                }

                QWidget *wgt=stackedWidget->currentWidget();
                QDeclarativeView *w=qobject_cast<QDeclarativeView*>(wgt);
                if (w){
                    qDebug()<<"try get property from qml \n";
                    QVariant returnedValue;

                    QMetaObject::invokeMethod(w->rootObject(), "collectData",
                                Q_RETURN_ARG(QVariant, returnedValue));

                    QVariantMap returnedMap=returnedValue.toMap();

                    if (!returnedMap.isEmpty()) {

                        qDebug()<<returnedMap;

                        if (newRowInsertion){
                            baseProvider->addForeignKeyToMap(returnedMap);
                        }

                        baseProvider->currentNode()->model->setSelectedItem(returnedMap);
                    }
                    w->rootObject()->setProperty("state","");
                    this->addNavBar();
                }
                newRowInsertion=false;
                break;

            }
            case undoButtonIndex:{
                if (currentWidgetType.top()==TableForm){
                    baseProvider->currentNode()->model->revertAll();
                    this->addNavBar();
                    return;
                }

                if (newRowInsertion){
                    this->removeWidgetFromStack();
                }
                else{
                        QWidget *wgt=stackedWidget->currentWidget();
                        QDeclarativeView *w=qobject_cast<QDeclarativeView*>(wgt);
                        w->rootObject()->setProperty("state","");
                        w->setSource(w->source());//FIXME drop changes - looks wrong
                }
                baseProvider->currentNode()->model->revertAll();
                newRowInsertion=false;
                this->addNavBar();
                break;

                }
        }
        case deleteButtonIndex:{
            if (currentWidgetType.top()==TableForm){
                QWidget *wgt=stackedWidget->currentWidget();
                DelegatedTableView *w=qobject_cast<DelegatedTableView*>(wgt);
                if (w) {
                    CVBSqlRelationalTableModel *model=baseProvider->currentNode()->model;
                    QModelIndexList list=w->selectionModel()->selectedRows();
                    if (list.isEmpty()){
                        this->showError(tr("Selection need"));
                        break;
                    }
                    qDebug()<<list;
                    model->removeRows(list.at(0).row(),list.count());
                    model->submitAll();
                }
            }
            else {
                baseProvider->deleteCurrentRow();
                this->removeWidgetFromStack();
            }
            break;
        }
        default:
            this->showError(tr("Not imlemented yet"));
        }
        return;
    }
    baseProvider->pressedButton(index);
}

QVariant MainWindow::loadNewImage(){
    QString str=QFileDialog::getOpenFileName(0,tr("Switch picture"),QString());//,"*.jpg");
    if (!str.isEmpty()){
        QFile file(str);

        if (file.open(QIODevice::ReadOnly)){

            QByteArray byteArray = file.readAll();

            return QVariant(baseProvider->idForAttach(byteArray));
        }
    }

    return QVariant(-1);
}

//Всплывающие меню

QVariant MainWindow::imageRightClick(const QString& id, int x, int y, bool editable=false){
    QMenu myMenu;
    QVariant returnVar = QVariant("-1");
    //FIXME make string constants
    if (editable) {
        myMenu.addAction(tr("Load image from disk"));
        myMenu.addAction(tr("Paste image from clipboard"));
    }
    else {
        myMenu.addAction(tr("Save image to disk"));
        myMenu.addAction(tr("Copy image to clipboard"));
    }

    QAction* selectedItem = myMenu.exec(QPoint(x,y));
    if (selectedItem)
    {
        if (selectedItem->text()==tr("Save image to disk")){
            QString str=QFileDialog::getSaveFileName(0,tr("Switch place for saving"),QString(),"*.jpg");
            if (!str.isEmpty()){

                if ( !str.contains(".jpg", Qt::CaseInsensitive) )
                    str.append(".jpg");

                QPixmap pix=imageProvider->requestPixmap(id,NULL,QSize());
                pix.save(str);
            }
        }
        else if (selectedItem->text()==tr("Copy image to clipboard")) {
            QClipboard *clipboard = QApplication::clipboard();
            clipboard->setPixmap(imageProvider->requestPixmap(id,NULL,QSize()));
        } else if (selectedItem->text()==tr("Load image from disk")){
            returnVar=this->loadNewImage();
        }
        else if (selectedItem->text()==tr("Paste image from clipboard")){
            QClipboard *clipboard = QApplication::clipboard();
            QPixmap pix=clipboard->pixmap();
            if (!pix.isNull()){

                QByteArray bArray;
                QBuffer buffer( &bArray );
                buffer.open( QIODevice::WriteOnly );
                pix.save( &buffer, "JPG" );

                returnVar=QVariant(baseProvider->idForAttach(bArray));
            }

        }
    }
    return returnVar;
}

//работа с сохранением данных

void MainWindow::dataChanged(){

    navBar->clear();
    QAction *action=navBar->addAction(QIcon(":///icons/undo.png"),tr(kUNDO_CHANGES_BUTTON));
    action->setObjectName(kUNDO_CHANGES_BUTTON);
    connect(action,SIGNAL(triggered()),this,SLOT(buttonPressed()));

    action=navBar->addAction(QIcon(":///icons/apply.png"),tr(kAPPLY_CHANGES_BUTTON));
    action->setObjectName(kAPPLY_CHANGES_BUTTON);
    connect(action,SIGNAL(triggered()),this,SLOT(buttonPressed()));

}


//Mobile devices fullscreen suport and rotation -copyed from standart necessitas template
/*
 //FIXME - qt 5.0.0 error
void MainWindow::setOrientation(ScreenOrientation orientation)
{
#if defined(Q_OS_SYMBIAN)
    // If the version of Qt on the device is < 4.7.2, that attribute won't work
    if (orientation != ScreenOrientationAuto) {
        const QStringList v = QString::fromAscii(qVersion()).split(QLatin1Char('.'));
        if (v.count() == 3 && (v.at(0).toInt() << 16 | v.at(1).toInt() << 8 | v.at(2).toInt()) < 0x040702) {
            qWarning("Screen orientation locking only supported with Qt 4.7.2 and above");
            return;
        }
    }
#endif // Q_OS_SYMBIAN

    Qt::WidgetAttribute attribute;
    switch (orientation) {
#if QT_VERSION < 0x040702
    // Qt < 4.7.2 does not yet have the Qt::WA_*Orientation attributes
    case ScreenOrientationLockPortrait:
        attribute = static_cast<Qt::WidgetAttribute>(128);
        break;
    case ScreenOrientationLockLandscape:
        attribute = static_cast<Qt::WidgetAttribute>(129);
        break;
    default:
    case ScreenOrientationAuto:
        attribute = static_cast<Qt::WidgetAttribute>(130);
        break;
#else // QT_VERSION < 0x040702
    case ScreenOrientationLockPortrait:
        attribute = Qt::WA_LockPortraitOrientation;
        break;
    case ScreenOrientationLockLandscape:
        attribute = Qt::WA_LockLandscapeOrientation;
        break;
    default:
    case ScreenOrientationAuto:
        attribute = Qt::WA_AutoOrientation;
        break;
#endif // QT_VERSION < 0x040702
    };
    setAttribute(attribute, true);
}
*/

void MainWindow::showExpanded()
{
#if defined(Q_OS_SYMBIAN) || defined(Q_WS_SIMULATOR)
    showFullScreen();
#elif defined(Q_WS_MAEMO_5)
    showMaximized();
#else
    this->resize(800,600);
    this->move(0,0);
    show();
#endif
}
