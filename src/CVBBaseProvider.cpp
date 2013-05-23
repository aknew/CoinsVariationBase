#include "CVBBaseProvider.h"
#include <QMessageBox>
#include <QtXml>

CVBBaseProvider::CVBBaseProvider(QString pathPath, QObject *parent) :
    QObject(parent)
{
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(pathPath);
    basePath=pathPath.section('/',0,-2)+"/";
    qDebug()<<basePath;
    if (!db.open()) {
        qDebug() << "Cannot open database:" << db.lastError();
    }

    this->parse();
}

CVBBaseProvider::~CVBBaseProvider(){
    db.close();
}

QStringList CVBBaseProvider::listForID(const QString &name){

    QStringList list;

    qDebug()<<name;
    //qDebug()<<"comboBoxes.keys()="<<comboBoxes.keys();

    ComboBoxDescription desc=comboBoxes[name];

    QSqlQuery query;
    QString str=desc.query;

    if (desc.params.count()!=0){
        /*
         *здесь мы добавляем значения в запрос, теоретически должно работать для любого числа,
         *но пока больше одного мне не нужно было и не проверлось
         */
        for (int i=0;i<desc.params.count();++i){
            QStringList params=desc.params.at(i).split(".");
            qDebug()<<params;
            if (params.count()!=2){
                QVariantMap map=currentNode()->model->selectedItem();
                str=str.arg(map[desc.params.at(i)].toString());
                continue;

            }
            QVariantMap map=nodeMap.value(params[0])->model->selectedItem();
            str=str.arg(map[params[1]].toString());
        }
    }
    qDebug()<<str;
    query.exec(str);

    while (query.next()) {
        list<<query.value(0).toString();
    }

    return list;

}

void CVBBaseProvider::previousLevel(){
    if (nodeStack.count()<=1)
        return;
    //FIXME хак для удаления параметров для внешних ключей - весь механизм работы с ними не верен
    qDebug()<<"Before:\n"<<ids;
    QString buttonID=currentNode()->tableName;
    nodeStack.pop();
    QString str=currentNode()->childNodes.value(buttonID);
    if (str!=""){
        ids.remove(str);
    }
    qDebug()<<"After:\n"<<ids;
    emit removeCurrentWidget();
}

void CVBBaseProvider::startLevel(){
    CVBSqlNode *node=nodeMap.value(startTable);
    if (node){
        node->model->select();
        nodeStack.push(node);
        emit newTableWidget();
    }
}

void CVBBaseProvider::loadSystemTables(const QString &name){
    CVBSqlNode *node=nodeMap.value(name);
    if (node){
        node->model->select();
        nodeStack.push(node);
        emit newTableWidget();
    }
}

QStringList CVBBaseProvider::buttonIDs(){
    QStringList buttonIDs=currentNode()->childNodes.keys();
    buttonIDs.append(currentNode()->childNodes2.keys());

    return buttonIDs;
}

void CVBBaseProvider::pressedButton(int index){


    CVBSqlNode *currentNode=nodeStack.top();
    int rowIndex = currentNode->model->selectedRow;
    QString buttonID=buttonIDs().at(index);
    CVBSqlNode *node=nodeMap.value(buttonID);
    if (node){
        QString str=currentNode->childNodes.value(buttonID);
        if (str!=""){
            QSqlRecord record=currentNode->model->record(rowIndex);
            QSqlField id=record.field("id");
            QString str1="%1=%2";
            node->model->setFilter(str1.arg(str).arg(id.value().toString()));
            ids.insert(str,id.value().toString());
        }
        else{
           QPair <QString, QString > relation=currentNode->childNodes2.value(buttonID);
           if (relation.first!=""){
               QSqlRecord record=currentNode->model->record(rowIndex);
               QSqlField id=record.field(relation.first);
               QString str1="\"%1\"=\"%2\"";
               node->model->setFilter(str1.arg(relation.second).arg(id.value().toString().replace("\"","\"\"")));//Экранируем кавычки
           }
        }
        node->model->select();
        qDebug()<<node->model->filter();
        qDebug()<<node->model->rowCount();
        nodeStack.push(node);
        emit newTableWidget();
    }
}

void CVBBaseProvider::insertNewRow(){
     CVBSqlNode *currentNode=nodeStack.top();
     CVBSqlRelationalTableModel *model=nodeStack.top()->model;
     qDebug()<<model->rowCount();
     bool flag=model->insertRow(model->rowCount());
     if (!flag){

         qDebug()<<model->lastError();
     }
     QSqlRecord record=model->record(model->rowCount()-1);
     for (int i=0;i<currentNode->rowParamNames.count();++i){
         QString str=ids.value(currentNode->rowParamNames.at(i));
         record.setValue(currentNode->rowParamNames.at(i),str);
     }
     qDebug()<<record;
     model->setRecord(model->rowCount()-1,record);
     model->selectedRow=model->rowCount()-1;
     qDebug()<<model->selectedRow<<model->rowCount()-1;
     qDebug()<<model->rowCount();
}

void CVBBaseProvider::addForeignKeyToMap(QVariantMap &map){
    qDebug()<<map;
    CVBSqlNode *currentNode=nodeStack.top();
    for (int i=0;i<currentNode->rowParamNames.count();++i){
        QString str=ids.value(currentNode->rowParamNames.at(i));
        map[currentNode->rowParamNames.at(i)]=str;
    }
    qDebug()<<"after addForeignKeyToMap "<<map;
}



void CVBBaseProvider::submitNewRow(){
    //FIXME can't insert new row in Qt 5.0.0
    CVBSqlNode *currentNode=nodeStack.top();
    QSqlRecord record=currentNode->model->record(currentNode->model->rowCount()-1);
    qDebug()<<record;
    if (!currentNode->model->submitAll())
        emit getError(currentNode->model->lastError().text());
}

void CVBBaseProvider::deleteCurrentRow(){
    CVBSqlNode *currentNode=nodeStack.top();
    currentNode->model->removeCurrentItem();
}

CVBSqlNode *CVBBaseProvider::currentNode(){
    return nodeStack.top();
}

QString CVBBaseProvider::idForAttach(QByteArray attach){

    QString md5=QCryptographicHash::hash(attach,QCryptographicHash::Md5).toHex();

    //TODO Сделать здесь проверку на наличие картинки в базе и только если нет переписывать
    QSqlQuery query;

    query.prepare("insert into attachStorage(attach) values(?)");
    query.bindValue(0,md5);
    if (!query.exec())
        qDebug()<<query.lastError();
    query.prepare("select id from attachStorage where attach=?");
    query.bindValue(0,md5);
    if (!query.exec())
        emit getError(query.lastError().text());
    if (query.next()){
            QString id=query.value(0).toString();
            QString str="%1images/%2";
            QFile file(str.arg(basePath).arg(id));

            if (!file.open(QIODevice::WriteOnly)) return "NULL";
            file.write(attach);
            return id;
    }
    else return "NULL";
}

QByteArray CVBBaseProvider::attachForId(QString id){
    QString str="%1images/%2";
    QFile file(str.arg(basePath).arg(id));

    if (!file.open(QIODevice::ReadOnly)) return NULL;
    QByteArray byteArray = file.readAll();
    return byteArray;
}

void CVBBaseProvider::parse(){

    QString filename=basePath+"/struct.xml";

    qDebug()<<"parser start - ok";

    QDomDocument doc("mydocument");
     QFile file(filename);
     if (!file.open(QIODevice::ReadOnly)){
         qDebug() << "Cannot open xml";
         exit(-1);
     }
     if (!doc.setContent(&file)) {
         qDebug() << "!doc.setContent(&file)";
         file.close();
         exit(-2);
     }
     file.close();

     // print out the element names of all elements that are direct children
     // of the outermost element.
     QDomElement docElem = doc.documentElement();
     startTable =docElem.attribute("startTable");
     QDomNode n = docElem.firstChild();
     while(!n.isNull()) {
         QDomElement e = n.toElement(); // try to convert the node to an element.
         if(!e.isNull() && e.tagName()=="node") {
             CVBSqlNode *node=new CVBSqlNode();
             node->tableName=e.attribute("name");
             //FIXME Cтоит создавать модели только тогда, когда они нужны и выгружать потом
             node->model=new CVBSqlRelationalTableModel(this,db);
             node->model->setTable(node->tableName);
             node->model->applyRoles();

             node->defaultSortColumn=e.attribute("defaultSortColumn","-1").toInt();

             bool isSystem=e.attribute("isSystem","0").toInt();

             if (isSystem){
                 systemTables.append(node->tableName);
             }

             QDomNode n1 = n.firstChild();
             while(!n1.isNull()) {
                 QDomElement e1 = n1.toElement(); // try to convert the node to an element.
                 if(!e1.isNull()) {
                     if (e1.tagName()=="mainChild"){
                         node->mainChild=e1.attribute("name");
                     }
                     else if (e1.tagName()=="childNode"){
                         node->childNodes.insert(e1.attribute("name"),e1.attribute("relation"));
                     }
                     else if (e1.tagName()=="childNode2"){
                         node->childNodes2.insert(e1.attribute("name"),QPair<QString, QString>(e1.attribute("relation1"),e1.attribute("relation2")));
                     }else if (e1.tagName()=="comboDelegate"){
                         node->comboDelegates.push_back(QPair <int, QString>(
                                                            e1.attribute("column","-1").toInt(),
                                                            e1.attribute("dict","-1")
                                                           ));
                     }else if (e1.tagName()=="rowParamNames"){
                         node->rowParamNames.push_back(e1.attribute("name"));
                     }else if (e1.tagName()=="pictDelegate"){
                         node->pictDelegate=e1.attribute("column","-1").toInt();
                     }else if (e1.tagName()=="widths"){

                         QStringList widths=e1.text().split(' ');

                         node->columnWidth=new QVector<float>;
                         for (int i=0;i<widths.count();++i){
                             node->columnWidth->push_back(widths.at(i).toFloat());
                         }

                     }else if (e1.tagName()=="height"){
                         node->height=e1.text().toFloat();
                     }else if (e1.tagName()=="fullForm"){
                         node->fullFormName = e1.attribute("name","");
                     }else if (e1.tagName()=="listForm"){
                         node->listFormName = e1.attribute("name","");
                     }
                 }
                 n1 = n1.nextSibling();
             }

             nodeMap.insert(node->tableName,node);
         }
         else {
             if(!e.isNull() && e.tagName()=="comboBoxes") {
                 QDomNode n1 = n.firstChild();
                 while(!n1.isNull()) {
                     QDomElement e1 = n1.toElement(); // try to convert the node to an element.
                     if(!e1.isNull()) {
                         ComboBoxDescription desc;
                         desc.query=e1.attribute("query","");

                         QString param=e1.attribute("param","");
                         if (!param.isEmpty())
                             desc.params.push_back(param);
                         comboBoxes[e1.attribute("name","")]=desc;
                     }
                     n1 = n1.nextSibling();
                 }

             }
         }
         n = n.nextSibling();
     }
     qDebug()<<nodeMap.keys();
     qDebug()<<"parser end - ok";
}
