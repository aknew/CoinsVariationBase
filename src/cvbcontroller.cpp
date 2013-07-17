#include "CVBController.h"
 #include <QQmlContext>

void CVBController::start(){
    QString basePath;
    QSettings settings("settings.ini",QSettings::IniFormat);
    settings.setIniCodec("windows-1251");

#if defined(Q_OS_ANDROID)
    useMobileForms=settings.value("global/useMobileForms","true").toBool();
#else
    useMobileForms=settings.value("global/useMobileForms","false").toBool();
#endif

    basePath=settings.value("global/base","").toString();

    if (basePath.isEmpty()){
        QMetaObject::invokeMethod(this->applicationWindow,
                                  "openBase"
                                  );
    }
    else {
        this->openBase(basePath);
    }

}

void CVBController::openBase(QString basePath){


    QSettings settings("settings.ini",QSettings::IniFormat);
    settings.setIniCodec("windows-1251");
    //TODO: Extract settings keys as string constant
    settings.setValue("global/base",QVariant(basePath));

    if (baseProvider) {
        /*
         This will be dropping any base specifics, but now we can't load another base so this if is empty
         */

        delete baseProvider;
    }

    baseProvider=new CVBBaseProvider(basePath,this);

    this->connect(baseProvider,SIGNAL(removeCurrentWidget()),this,SLOT(removeWidgetFromStack()));
    this->connect(baseProvider,SIGNAL(newTableWidget()),this,SLOT(newTableWidget()));
    this->connect(baseProvider,SIGNAL(getError(QString)),this,SLOT(showError(QString)));

    imageProvider= new CVBImageProvider(QQuickImageProvider::Pixmap);
    imageProvider->imageFolder=baseProvider->basePath+"images/";

    baseProvider->startLevel();
    this->initShortcuts();
}

void CVBController::showError(QString str){

}

void CVBController::addViewToStack(const QQuickView* view){
    QVariant newItem =QVariant::fromValue(qobject_cast<QQuickItem *>(view->rootObject()));

    QMetaObject::invokeMethod(this->stackView,
                              "push",
                              Q_ARG(QVariant,newItem)
                              );
}

void CVBController::removeWidgetFromStack(){
    QMetaObject::invokeMethod(this->stackView,
                              "pop"
                              );
    currentWidgetType.pop();
}

//Загрузка различных страниц

QVariant CVBController::listForName(const QString& name){
    return QVariant(baseProvider->listForID(name));
}

void CVBController::newTableWidget(){
#ifndef QTableViewUsing

    QString str=baseProvider->basePath+(useMobileForms?"mobile-forms/":"forms/");

    if (baseProvider->currentNode()->listFormName.isEmpty()){
        //в xml не было указания на конкретную форму, пробуем собрать ее на месте
        str=str+baseProvider->currentNode()->model->tableName()+".qml";
    }
    else {
        str=str+baseProvider->currentNode()->listFormName+".qml";
    }

    if (QFile::exists(str)){

        QQuickView *w=newDeclarativeView();
        w->setResizeMode(QQuickView::SizeRootObjectToView);
        w->rootContext()->setContextProperty("myModel", baseProvider->currentNode()->model);
        w->setSource(QUrl::fromLocalFile(str));

        this->addViewToStack(w);
        currentWidgetType.push(QMLListWithoutEditing);
    }
    else
#endif
    {
        /*
        //файла с формой нет, будет задействованна стандартная табличка
        DelegatedTableView *newTableView= new DelegatedTableView();
        newTableView->setBaseProvider(baseProvider);
        this->addViewToStack(newTableView);
        currentWidgetType.push(TableForm);
        QObject::connect(newTableView->model(),SIGNAL(dataChanged(QModelIndex,QModelIndex)),this,SLOT(dataChanged()));
        */
    }
}

void CVBController::fullInfo(int index){

    //_currentIndex.push(index);

    CVBSqlRelationalTableModel *listModel=baseProvider->currentNode()->model;
    listModel->selectedRow=index;

    QString str=baseProvider->basePath+(useMobileForms?"mobile-forms/":"forms/");

    if (baseProvider->currentNode()->fullFormName.isEmpty()){
        //в xml не было указания на конкретную форму, пробуем собрать ее на месте
        str=str+baseProvider->currentNode()->model->tableName()+"FullInfo.qml";
    }
    else {
        str=str+baseProvider->currentNode()->fullFormName+".qml";
    }

    if (QFile::exists(str)){

        QQuickView *w=newDeclarativeView();

        w->setResizeMode(QQuickView::SizeRootObjectToView);
        w->rootContext()->setContextProperty("myModel", listModel);
        w->rootContext()->setContextProperty("nextLevelList", QVariant::fromValue(baseProvider->buttonIDs()));

        w->rootContext()->setContextProperty("selectedItem",listModel->selectedItem());

        w->setSource(QUrl::fromLocalFile(str));

        this->addViewToStack(w);
        currentWidgetType.push(FullForm);
    }
    else {
        qDebug()<<QString::fromUtf8("файла с формой полной информации нет, потом здесь будет загрузка диалога выбора следующего уровня");
        return;
    }
}

void CVBController::showFullScreenImage(QString imgSource){

    QQuickView *w=newDeclarativeView();
    w->rootContext()->setContextProperty("imgSource",imgSource);
    w->setSource(QUrl::fromLocalFile(baseProvider->basePath+"forms/BigImage.qml"));

    this->addViewToStack(w);
    currentWidgetType.push(FullScreenImage);
}

QQuickView *CVBController::newDeclarativeView(){

    QQuickView *w=new QQuickView();
    w->setResizeMode(QQuickView::SizeRootObjectToView);
    w->engine()->addImageProvider(QLatin1String("imageProvider"),imageProvider);
    w->rootContext()->setContextProperty("window",this);
    return w;
}


//Работа с кнопками

void CVBController::initShortcuts(){
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

void CVBController::buttonPressed(){
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

void CVBController::buttonPressed(int index){

    qDebug()<<index;
//    if(index<0){
//        //что- то из предопредопределенных кнопок
//        switch (index) {
//        case backButtonIndex:{
//            if (currentWidgetType.top()==FullForm||currentWidgetType.top()==FullScreenImage)
//                this->removeWidgetFromStack();
//            else {
//                baseProvider->previousLevel();
//                if (currentWidgetType.top()!=TableForm){
//                    QWidget *wgt=stackedWidget->currentWidget();
//                    QQuickView *w=qobject_cast<QQuickView*>(wgt);
//                    w->setSource(w->source());
//                }
//            }
//            break;
//        case newButtonIndex:{
//                newRowInsertion=true;
//                if (currentWidgetType.top()==TableForm){
//                    baseProvider->insertNewRow();
//                    QWidget *wgt=stackedWidget->currentWidget();
//                    DelegatedTableView *w=qobject_cast<DelegatedTableView*>(wgt);
//                    if (w) {
//                        w->selectRow(w->model()->rowCount()-1);
//                        dataChanged();
//                    }
//                    return;
//                }

//                CVBSqlRelationalTableModel *model = baseProvider->currentNode()->model;
//                model->selectedRow=model->rowCount();
//                if (currentWidgetType.top()==QMLListWithoutEditing){
//                    this->fullInfo(model->selectedRow);
//                    QWidget *wgt=stackedWidget->currentWidget();
//                    QQuickView *w=qobject_cast<QQuickView*>(wgt);
//                    w->rootObject()->setProperty("state","editable");
//                }
//                else{
//                    QWidget *wgt=stackedWidget->currentWidget();
//                    QQuickView *w=qobject_cast<QQuickView*>(wgt);
//                    w->rootContext()->setContextProperty("selectedItem",model->selectedItem());
//                    w->setSource(w->source());
//                    w->rootObject()->setProperty("state","editable");
//                }
//                dataChanged();
//                break;

//            }
//        case editButtonIndex:{
//                QWidget *wgt=stackedWidget->currentWidget();
//                QQuickView *w=qobject_cast<QQuickView*>(wgt);
//                w->rootObject()->setProperty("state","editable");
//                dataChanged();
//                break;
//            }
//        case applyButtonIndex:{

//                if (currentWidgetType.top()==TableForm){
//                    baseProvider->submitNewRow();
//                    this->addNavBar();
//                    newRowInsertion=false;
//                    return;
//                }

//                QWidget *wgt=stackedWidget->currentWidget();
//                QQuickView *w=qobject_cast<QQuickView*>(wgt);
//                if (w){
//                    qDebug()<<"try get property from qml \n";
//                    QVariant returnedValue;

//                    QMetaObject::invokeMethod(w->rootObject(), "collectData",
//                                Q_RETURN_ARG(QVariant, returnedValue));

//                    QVariantMap returnedMap=returnedValue.toMap();

//                    if (!returnedMap.isEmpty()) {

//                        qDebug()<<returnedMap;

//                        if (newRowInsertion){
//                            baseProvider->addForeignKeyToMap(returnedMap);
//                        }

//                        baseProvider->currentNode()->model->setSelectedItem(returnedMap);
//                    }
//                    w->rootObject()->setProperty("state","");
//                    this->addNavBar();
//                }
//                newRowInsertion=false;
//                break;

//            }
//            case undoButtonIndex:{
//                if (currentWidgetType.top()==TableForm){
//                    baseProvider->currentNode()->model->revertAll();
//                    this->addNavBar();
//                    return;
//                }

//                if (newRowInsertion){
//                    this->removeWidgetFromStack();
//                }
//                else{
//                        QWidget *wgt=stackedWidget->currentWidget();
//                        QQuickView *w=qobject_cast<QQuickView*>(wgt);
//                        w->rootObject()->setProperty("state","");
//                        w->setSource(w->source());//FIXME drop changes - looks wrong
//                }
//                baseProvider->currentNode()->model->revertAll();
//                newRowInsertion=false;
//                this->addNavBar();
//                break;

//                }
//        }
//        case deleteButtonIndex:{
//            if (currentWidgetType.top()==TableForm){
//                QWidget *wgt=stackedWidget->currentWidget();
//                DelegatedTableView *w=qobject_cast<DelegatedTableView*>(wgt);
//                if (w) {
//                    CVBSqlRelationalTableModel *model=baseProvider->currentNode()->model;
//                    QModelIndexList list=w->selectionModel()->selectedRows();
//                    if (list.isEmpty()){
//                        this->showError(tr("Selection need"));
//                        break;
//                    }
//                    qDebug()<<list;
//                    model->removeRows(list.at(0).row(),list.count());
//                    model->submitAll();
//                }
//            }
//            else {
//                baseProvider->deleteCurrentRow();
//                this->removeWidgetFromStack();
//            }
//            break;
//        }
//        default:
//            this->showError(tr("Not imlemented yet"));
//        }
//        return;
//    }
    baseProvider->pressedButton(index);
}

QVariant CVBController::loadNewImage(){
//    QString str=QFileDialog::getOpenFileName(0,tr("Switch picture"),QString());//,"*.jpg");
//    if (!str.isEmpty()){
//        QFile file(str);

//        if (file.open(QIODevice::ReadOnly)){

//            QByteArray byteArray = file.readAll();

//            return QVariant(baseProvider->idForAttach(byteArray));
//        }
//    }

    return QVariant(-1);
}

//Всплывающие меню

QVariant CVBController::imageRightClick(const QString& id, int x, int y, bool editable=false){

    QVariant returnVar = QVariant("-1");
//    QMenu myMenu;
//    //FIXME make string constants
//    if (editable) {
//        myMenu.addAction(tr("Load image from disk"));
//        myMenu.addAction(tr("Paste image from clipboard"));
//    }
//    else {
//        myMenu.addAction(tr("Save image to disk"));
//        myMenu.addAction(tr("Copy image to clipboard"));
//    }

//    QAction* selectedItem = myMenu.exec(QPoint(x,y));
//    if (selectedItem)
//    {
//        if (selectedItem->text()==tr("Save image to disk")){
//            QString str=QFileDialog::getSaveFileName(0,tr("Switch place for saving"),QString(),"*.jpg");
//            if (!str.isEmpty()){

//                if ( !str.contains(".jpg", Qt::CaseInsensitive) )
//                    str.append(".jpg");

//                QPixmap pix=imageProvider->requestPixmap(id,NULL,QSize());
//                pix.save(str);
//            }
//        }
//        else if (selectedItem->text()==tr("Copy image to clipboard")) {
//            QClipboard *clipboard = QApplication::clipboard();
//            clipboard->setPixmap(imageProvider->requestPixmap(id,NULL,QSize()));
//        } else if (selectedItem->text()==tr("Load image from disk")){
//            returnVar=this->loadNewImage();
//        }
//        else if (selectedItem->text()==tr("Paste image from clipboard")){
//            QClipboard *clipboard = QApplication::clipboard();
//            QPixmap pix=clipboard->pixmap();
//            if (!pix.isNull()){

//                QByteArray bArray;
//                QBuffer buffer( &bArray );
//                buffer.open( QIODevice::WriteOnly );
//                pix.save( &buffer, "JPG" );

//                returnVar=QVariant(baseProvider->idForAttach(bArray));
//            }

//        }
//    }
    return returnVar;
}

//работа с сохранением данных

void CVBController::dataChanged(){

//    navBar->clear();
//    QAction *action=navBar->addAction(QIcon(":///icons/undo.png"),tr(kUNDO_CHANGES_BUTTON));
//    action->setObjectName(kUNDO_CHANGES_BUTTON);
//    connect(action,SIGNAL(triggered()),this,SLOT(buttonPressed()));

//    action=navBar->addAction(QIcon(":///icons/apply.png"),tr(kAPPLY_CHANGES_BUTTON));
//    action->setObjectName(kAPPLY_CHANGES_BUTTON);
//    connect(action,SIGNAL(triggered()),this,SLOT(buttonPressed()));

}
