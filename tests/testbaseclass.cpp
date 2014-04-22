#include "testbaseclass.h"

#define TEST_BASE "testBase.sqlite"

TestBaseClass::TestBaseClass(QObject *parent) :
    QObject(parent)
{

}

void TestBaseClass::initTestCase(){

    QFile::remove(TEST_BASE);

    //create new empty base, using sqlite3 console app from http://www.sqlite.org (or system in Mac or Ubuntu) cause qt driver can't execute multistatement query
    //In windows you also can use cygwin sqlite3
    //QString str=QString("sqlite3 %1 \".read struct.sql\"").arg(TEST_BASE);
    //HOTFIX: I cant copy sql script during build, so I use this hotfix
    QString str=QString("sqlite3 %1 \".read ../sql/struct.sql\"").arg(TEST_BASE);
    int result = system(str.toLatin1());
    if (result != 0){
        QFAIL("SOmething wrong during create new db file with struct.sql");
    }

    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(TEST_BASE);
    if (!db.open()) {
        qDebug() << "Cannot open database:" << db.lastError();
        QFAIL("Cannot open database");
    }

    query=QSqlQuery(db);
}

void TestBaseClass::testTypeInsertion(){


    query.exec("PRAGMA foreign_keys = ON;");

    flag=query.exec("INSERT INTO TypesView  (nominal, metal, firstYear, lastYear, edge, issue, avers, revers, weigth)"
                    "VALUES (\"1 rouble\", \"Silver\",\"1700\",\"1800\",\"Gladkij\",\"regular\",\"Double head eagle\","
                    "\"Label 'ONE ROUBLE' in two strings fnd year as third string\",10.5);");

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    flag=query.exec("INSERT INTO TypesView  (nominal, metal, firstYear, lastYear, edge, issue, avers, revers, weigth)"
                    "VALUES (\"2 rouble\", \"Silver\",\"1700\",\"1800\",\"Gladkij\",\"regular\",\"Double head eagle\","
                    "\"Label 'ONE ROUBLE' in two strings fnd year as third string\",10.5);");

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    //Check dictionaryes

    flag=query.exec("SELECT COUNT(*) FROM EDGES;");  //RESULT==1

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    if (query.next()){
        QCOMPARE(query.value(0).toInt(),1);
    }
}

void TestBaseClass::testTypeDeletion(){

    //Check Cascade Deletion

    flag=query.exec("DELETE FROM TypesView WHERE ID=1;");

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    flag=query.exec("SELECT COUNT(*) FROM VariatiesView;");  //RESULT==0

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    if (query.next()){
        QCOMPARE(query.value(0).toInt(),0);
    }


    flag=query.exec("SELECT COUNT(*) FROM ConcreteCoinsView;");  //RESULT==0

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    if (query.next()){
        QCOMPARE(query.value(0).toInt(),0);
    }

}

void TestBaseClass::testVariantInsertion(){

    flag=query.exec("INSERT INTO VariatiesView  (typeID, year, mintmark, Mint, edge, price )"
                    "VALUES (1,1700, \"MM\",\"Red yard, Moscow\",\"Gladkij\",122);");

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    flag=query.exec("INSERT INTO ConcreteCoinsView (varID, condition, status)"
                    "VALUES (1,\"XF\",\"Collection\");");

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    flag=query.exec("INSERT INTO varReferencesView(varID, reduction, number, rarity, \"comment\")"
                    "VALUES (1,\"Uzdenikov\",2233,\"-\",\"wrong picture of edge\");");

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    flag=query.exec("SELECT COUNT(*) FROM Mint");  //RESULT==1

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    if (query.next()){
        QCOMPARE(query.value(0).toInt(),1);
    }
}

void TestBaseClass::testVarianDeletion(){

}

