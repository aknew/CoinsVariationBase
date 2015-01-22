#include "testbaseclass.h"
#include <QDebug>
#include <QString>
#include <QDir>
#include <QFile>
#include "../src/CVBBaseProvider.h"

const QString TestBaseFolder="testBase/";

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

    baseProvider->currentNode()->selectItemWithIndex(CVBSqlNode::kNewRowIndex);

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

    baseProvider->currentNode()->model->setSelectedItem(returnedMap);
    QCOMPARE(baseProvider->currentNode()->model->rowCount(),before+1);

    delete baseProvider;
    baseProvider = new CVBBaseProvider(TestBaseFolder);
    baseProvider->startLevel();
    QCOMPARE(baseProvider->currentNode()->model->rowCount(),before+1);
}
