#include "CVBController.h"
#include "CVBUtils.h"
#include "CVBTranslator.h"
#include <QQmlContext>
#include <QtWidgets/QApplication>
#include <QtWidgets/QMessageBox>
#include <QClipboard>


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

    CVBFromQmlFilePath(&basePath);
    basePath=basePath.append("/");
    baseProvider=new CVBBaseProvider(basePath,this);

    this->connect(baseProvider,SIGNAL(removeCurrentWidget()),this,SLOT(removeWidgetFromStack()));
    this->connect(baseProvider,SIGNAL(newTableWidget()),this,SLOT(newTableWidget()));
    this->connect(baseProvider,SIGNAL(getError(QString)),this,SLOT(showError(QString)));
    this->connect(baseProvider,SIGNAL(currentNodeWasChanged()),this,SLOT(currentNodeWasChanged()));

    imageProvider= new CVBImageProvider(QQuickImageProvider::Pixmap);
    imageProvider->imageFolder=baseProvider->basePath+"images/";

    engine->addImageProvider(QLatin1String("imageProvider"),imageProvider);

    engine->rootContext()->setContextProperty("window",this);

    QString locale = QLocale::system().name();
    QString filename = QString("languages/") + locale+".json";

    static CVBTranslator translator;
    if( translator.load(filename, basePath) ){
        QApplication::instance()->installTranslator(&translator);
        //QTextCodec::setCodecForTr(QTextCodec::codecForName("utf8"));
        qDebug() << "Translation file loaded" << filename;
    } else
        qDebug() << "Translation file not loaded:" << filename << "  dir:"<<basePath;

    baseProvider->startLevel();
}

void CVBController::currentNodeWasChanged(){
    this->engine->rootContext()->setContextProperty("currentModel", baseProvider->currentNode()->model);
}

void CVBController::showError(QString str){
    QMessageBox::critical(NULL, "", str);
}

void CVBController::addViewToStack(const QQuickView* view){
    QVariant newItem =QVariant::fromValue(qobject_cast<QQuickItem *>(view->rootObject()));

    QMetaObject::invokeMethod(this->stackView,
                              "push",
                              Q_ARG(QVariant,newItem)
                              );
}

void CVBController::removeWidgetFromStack(){

    int previousItemNumber = this->stackView->childItems().count()-2;

    QQuickItem *previousItem = this->stackView->childItems().at(previousItemNumber);

    QMetaObject::invokeMethod(this->stackView,
                              "pop",
                              Q_ARG(QVariant,QVariant::fromValue(previousItem))
                              );
    currentWidgetType.pop();
}

QQuickItem * CVBController::currentItem(){

    QVariant returnedValue=this->stackView->property("currentItem");

    return returnedValue.value<QQuickItem *>();
}

//Загрузка различных страниц

QVariant CVBController::listForName(const QString& name){
    return QVariant(baseProvider->listForID(name));
}

QVariant CVBController::fieldsForListView(){
    return baseProvider->currentNode()->getListViewFields();
}

QObject *CVBController::currentModel() {
    return baseProvider->currentNode()->model;
}

QObject* CVBController::getModelWithName(const QString& name){
    return baseProvider->getModelWithName(name);
}

QVariant CVBController::fullFormFields(){
    return baseProvider->currentNode()->fullFormFields;
}

QVariantMap CVBController::selectedItem(){
    //FIXME: need rename
    return baseProvider->currentNode()->model->selectedItem();
}

QStringList CVBController::nextLevelList(){
    return baseProvider->buttonIDs();
}

void CVBController::newTableWidget(){
    QString str=baseProvider->basePath+(useMobileForms?"mobile-forms/":"forms/");

    if (baseProvider->currentNode()->listFormName.isEmpty()){
        //в xml не было указания на конкретную форму, пробуем собрать ее на месте
        str=str+baseProvider->currentNode()->model->tableName()+".qml";
    }
    else {
        str=str+baseProvider->currentNode()->listFormName+".qml";
    }

    if (QFile::exists(str)){
        str = QString("file:///%1").arg(str);
        QMetaObject::invokeMethod(this->applicationWindow,
                                  "loadForm",
                                  Q_ARG(QVariant,str)
                                  );
    }
    else
    {
        QMetaObject::invokeMethod(this->applicationWindow,
                                  "createListForm"
                                  );
    }

    currentWidgetType.push(QMLListWithoutEditing);
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

        str = QString("file:///%1").arg(str);

        engine->rootContext()->setContextProperty("myModel", listModel);
        engine->rootContext()->setContextProperty("nextLevelList", QVariant::fromValue(baseProvider->buttonIDs()));
        engine->rootContext()->setContextProperty("selectedItem",listModel->selectedItem());

        QMetaObject::invokeMethod(this->applicationWindow,
                                  "loadForm",
                                  Q_ARG(QVariant,str)
                                  );
    }
    else {
        QMetaObject::invokeMethod(this->applicationWindow,
                                  "createFullInfoForm"
                                  );
    }
    currentWidgetType.push(FullForm);
}

void CVBController::showFullScreenImage(QString imgSource){

    QQuickView *w=newDeclarativeView();
    w->rootContext()->setContextProperty("imgSource",imgSource);
    w->setSource(QUrl("qrc:/CVBControls/BigImage.qml"));

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

void CVBController::buttonPressed(int index){

    qDebug()<<index;
    if(index<0){
        //что- то из предопредопределенных кнопок
        switch (index) {
        case backButtonIndex:{
            if (currentWidgetType.top()==FullForm||currentWidgetType.top()==FullScreenImage)
                this->removeWidgetFromStack();
            //FIXME: need update table view - we can change it into FullForm, maybe rewrite this part with switch
            else {
                baseProvider->previousLevel();
            }
            break;

        case newButtonIndex:{
                newRowInsertion=true;
                CVBSqlRelationalTableModel *model = baseProvider->currentNode()->model;
                model->selectedRow=model->rowCount();
                if (currentWidgetType.top()==QMLListWithoutEditing){
                    this->fullInfo(model->selectedRow);
                }
                else{
                    QQuickItem *item = this->currentItem();
                    item->setProperty("selectedItem",model->selectedItem());
                }

                this->currentItem()->setProperty("state","editable");
                break;

            }
            case editButtonIndex:{
                this->currentItem()->setProperty("state","editable");
                break;
            }
            case applyButtonIndex:{
                qDebug()<<"try get property from qml \n";
                QVariant returnedValue;

                QMetaObject::invokeMethod(this->currentItem(), "collectData",
                                          Q_RETURN_ARG(QVariant, returnedValue));

                QVariantMap returnedMap=returnedValue.toMap();

                if (!returnedMap.isEmpty()) {

                    qDebug()<<returnedMap;

                    if (newRowInsertion){
                        baseProvider->addForeignKeyToMap(returnedMap);
                    }

                    baseProvider->currentNode()->model->setSelectedItem(returnedMap);
                }
                this->currentItem()->setProperty("state","");
                newRowInsertion=false;
                break;

            }
            case undoButtonIndex:{
                if (newRowInsertion){
                    this->removeWidgetFromStack();
                }
                else{
                    this->currentItem()->setProperty("state","");
                }
                baseProvider->currentNode()->model->revertAll();
                newRowInsertion=false;
                break;

            }
        }
        case deleteButtonIndex:{
            baseProvider->deleteCurrentRow();
            this->removeWidgetFromStack();
            break;
        }
        default:
            this->showError(tr("Not imlemented yet"));
        }
        return;
    }
    qDebug()<<"this is not predefined button";
    baseProvider->pressedButton(index);
}

QVariant CVBController::loadNewImage(QString imagePath = NULL){

    QVariant returnVar = QVariant("-1");
    if (!imagePath.isEmpty()){

        CVBFromQmlFilePath(&imagePath);

        QFile file(imagePath);

        if (file.open(QIODevice::ReadOnly)){

            QByteArray byteArray = file.readAll();

            returnVar = QVariant(baseProvider->idForAttach(byteArray));
        }
    }
    else {
        QClipboard *clipboard = QApplication::clipboard();
        QPixmap pix = clipboard->pixmap();
        if (!pix.isNull()){

            QByteArray bArray;
            QBuffer buffer( &bArray );
            buffer.open( QIODevice::WriteOnly );
            pix.save( &buffer, "JPG" );

            returnVar=QVariant(baseProvider->idForAttach(bArray));
        }
    }

    return returnVar;
}

void CVBController::saveImage(QString imageId, QString imagePath = NULL){

    QSize size=QSize();
    QImage img = imageProvider->requestImage(imageId,&size,size);

    if (!imagePath.isEmpty()){

        CVBFromQmlFilePath(&imagePath);

        bool flag = img.save(imagePath);

        if (!flag){
            //try add .jpg and save
            img.save(imagePath.append(".jpg"));
        }
    }
    else {
        QClipboard *clipboard = QApplication::clipboard();
        clipboard->setImage(img);
    }
}
