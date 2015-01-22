#include "testbaseclass.h"
#include <QDebug>
#include <QString>
#include <QDir>
#include <QFile>


const QString TestBaseFolder="testBase";

TestBaseClass::TestBaseClass(QObject *parent) :
    QObject(parent)
{

}

void TestBaseClass::initTestCase(){

    QDir dir = QDir(TestBaseFolder);
    dir.removeRecursively();
    QDir().mkdir(TestBaseFolder);

    QFile::copy(":/base.sqlite",TestBaseFolder+"/base.sqlite");
    QFile::copy(":/struct.json",TestBaseFolder+"/struct.json");
}

void TestBaseClass::testRowInsertion(){
        //QCOMPARE(query.value(0).toInt(),1);
}
