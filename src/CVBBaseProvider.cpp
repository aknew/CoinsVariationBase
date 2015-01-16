#include "CVBBaseProvider.h"

CVBBaseProvider::CVBBaseProvider(QString pathPath, QObject *parent) :
    QObject(parent)
{
/*
    *FIXME: name basePath is legacy - in very old version it was only db file, all struct was hardcoded and tables were
    *shown into QTableView. pathPath is typo. There is no any reasons using it now

*/
    basePath = pathPath;
    pathPath.append("base.sqlite");

    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(pathPath);
    if (!db.open()) {
        qDebug() << "Cannot open database:" << db.lastError();
    }

    //enable foreign key
    QSqlQuery query=QSqlQuery(db);
    query.exec("PRAGMA foreign_keys = ON;");

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

void CVBBaseProvider::pressedButton(int index){


    CVBSqlNode *currentNode=nodeStack.top();
    int rowIndex = currentNode->model->selectedRow;
    QString buttonID=currentNode->getNextLevelList().at(index);
    CVBSqlNode *node=nodeMap.value(buttonID);
    if (node){
        QString str=currentNode->childNodes.value(buttonID);
        if (str!=""){
            QSqlRecord record=currentNode->model->record(rowIndex);
            QSqlField id=record.field("id");
            QPair<QString, QString> pair;
            // XXX: Need refactoring
            pair.first  = str;
            pair.second = id.value().toString();
            node->setFilter(pair);
        }
        if (node->listModel){
            node->listModel->select();
            qDebug()<<node->listModel->rowCount();
        }
        node->model->select();
        qDebug()<<node->model->filter();
        qDebug()<<node->model->rowCount();
        nodeStack.push(node);
        emit newTableWidget();
    }
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

CVBSqlNode *CVBBaseProvider::nodeWithName(const QString &name){
    return nodeMap.value(name);
}

void CVBBaseProvider::parse(){

    QString filename=basePath+"struct.json";

    qDebug()<<"parser start - ok";
     QFile file(filename);
     if (!file.open(QIODevice::ReadOnly)){
         qDebug() << "Cannot open json";
         exit(-1);
     }
     QString jsonData = file.readAll();
     file.close();

     QJsonDocument sd = QJsonDocument::fromJson(jsonData.toUtf8());

     if (sd.isNull()){
         qDebug() << "Wrong file format";
         exit(-1);
     }
     QJsonObject baseStruct = sd.object();
     qDebug() << baseStruct.value(QString("name"));

     startTable = baseStruct.value("startTable").toString();

     QJsonArray nodes = baseStruct.value("nodes").toArray();

     foreach (QJsonValue value1,nodes) {
         QJsonObject obj=value1.toObject();

         CVBSqlNode *node=new CVBSqlNode(obj,db, this);
         bool isSystem=obj.value("isSystem").toBool();

         if (isSystem){
             systemTables.append(node->tableName);
         }

         nodeMap.insert(node->tableName,node);
     }

     nodes = baseStruct.value("comboBoxes").toArray();

     foreach (QJsonValue value,nodes) {

         QJsonObject obj=value.toObject();

         ComboBoxDescription desc;

         desc.query=obj.value("query").toString();

         QString param=obj.value("param").toString();
         if (!param.isEmpty())
             desc.params.push_back(param);
         comboBoxes[obj.value("name").toString()]=desc;
     }
}

void CVBBaseProvider::beginTransaction(){
    db.transaction();
}

void CVBBaseProvider::commit(){
    db.commit();
}

void CVBBaseProvider::rollback(){
    db.rollback();
}
