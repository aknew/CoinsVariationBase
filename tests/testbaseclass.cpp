#include "testbaseclass.h"
#include <QDebug>
#include <QString>
#include <QDir>
#include <QFile>
#include "../src/CVBBaseProvider.h"

const QString TestBaseFolder="testBase/";

QVariantMap testTypeMap(){
    QVariantMap returnedMap;
    returnedMap["avers"]="avers test description";
    returnedMap["edge"]="//////////";
    returnedMap["firstYear"]="1900";
    returnedMap["issue"]="test issue";
    returnedMap["lastYear"]="2000";
    returnedMap["metal"]="test metall";
    returnedMap["nominal"]="test nominal";
    returnedMap["revers"]="avers test description";
    returnedMap["weigth"]="0";
    return returnedMap;
}

TestBaseClass::TestBaseClass(QObject *parent) :
    QObject(parent)
{

}

void TestBaseClass::initTestCase(){

    QDir dir = QDir(TestBaseFolder);
    dir.removeRecursively();
    QDir().mkdir(TestBaseFolder);

    QFile::copy(":/base.sqlite",TestBaseFolder+"base.sqlite");
    QFile::copy(":/struct.json",TestBaseFolder+"struct.json");
}

void TestBaseClass::testRowInsertion(){
    CVBBaseProvider *baseProvider = new CVBBaseProvider(TestBaseFolder);
    baseProvider->startLevel();
    int before = baseProvider->currentNode()->model->rowCount();

    baseProvider->beginTransaction();
    baseProvider->currentNode()->selectItemWithIndex(CVBSqlNode::kNewRowIndex);


    QVariantMap returnedMap = testTypeMap();
    baseProvider->currentNode()->model->setSelectedItem(returnedMap);
    QCOMPARE(baseProvider->currentNode()->model->rowCount(),before+1);
    baseProvider->commit();
    delete baseProvider;
    baseProvider = new CVBBaseProvider(TestBaseFolder);
    baseProvider->startLevel();
    QCOMPARE(baseProvider->currentNode()->model->rowCount(),before+1);

    delete baseProvider;
}

void TestBaseClass::testRowInsertionNative(){
    QSqlDatabase *db = new QSqlDatabase(QSqlDatabase::addDatabase("QSQLITE"));
    db->setDatabaseName(TestBaseFolder+"base.sqlite");
    if (!db->open()) {
        qDebug() << "Cannot open database:" << db->lastError();
        QFAIL("Cannot open database");
    }

    CVBSqlRelationalTableModel *model = new CVBSqlRelationalTableModel(this,*db);
    model->setTable("Types");
    model->applyRoles();
    model->select();

    int before = model->rowCount();

    QVariantMap map = testTypeMap();
    int index = model->rowCount();
    model->insertRow(index);
    QSqlRecord record=model->record(index);
    QStringList keys=map.keys();
    for (int i=0;i<keys.count();++i){
        record.setValue(keys[i],map[keys[i]]);
    }

    model->insertRecord(index,record);
    model->submitAll();
    QCOMPARE(model->rowCount(),before+1);

    delete model;
    delete db;

    db = new QSqlDatabase(QSqlDatabase::addDatabase("QSQLITE"));
    db->setDatabaseName(TestBaseFolder+"base.sqlite");
    if (!db->open()) {
        qDebug() << "Cannot open database:" << db->lastError();
        QFAIL("Cannot open database");
    }

    model = new CVBSqlRelationalTableModel(this,*db);
    model->setTable("Types");
    model->applyRoles();
    model->select();

    QCOMPARE(model->rowCount(),before+1);

    delete model;
    delete db;
}
