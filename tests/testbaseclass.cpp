#include "testbaseclass.h"
#include <QtSql>

#define TEST_BASE "testBase.sqlite"

TestBaseClass::TestBaseClass(QObject *parent) :
    QObject(parent)
{

}

void TestBaseClass::testBase(){
    //base structure and logic, there is no any C++ code tests here, only sql

    QFile::remove(TEST_BASE);

    //create new empty base, using sqlite3 console app from http://www.sqlite.org (or system in Mac or Ubuntu) cause qt driver can't execute multistatement query
    QString str=QString("sqlite3 %1 \".read struct.sql\"").arg(TEST_BASE);
    system(str.toAscii());

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(TEST_BASE);
    if (!db.open()) {
        qDebug() << "Cannot open database:" << db.lastError();
    }

    QSqlQuery query=QSqlQuery(db);

    bool flag;

    flag=query.exec("INSERT INTO TypesView  (nominal, metal, firstYear, lastYear, edge, issue, avers, revers, weigth,  comment)"
               "VALUES (\"1 rouble\", \"Silver\",\"1700\",\"1800\",\"Gladkij\",\"regular\",\"Double head eagle\","
               "\"Label 'ONE ROUBLE' in two strings fnd year as third string\",10.5,\"this is test record\");");

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    flag=query.exec("INSERT INTO SubtypesView  (typeID, year, mintmark, MintYard, mintage, edge, avers, revers, pict, price, comment )"
                    "VALUES (1,1700, \"MM\",\"Red yard< Moscow\",111334,\"Gladkij\",\"Type one -big eagle\",\"Big font\",10,122,\"this is test record\");");

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    flag=query.exec("INSERT INTO VariantsView (stID, pict,avers, revers, edge, MintYard, mintage, price, comment )"
                    "VALUES (1,11,\"Big central crown\",\"A like Л\",\"Gladkij\",\"Red yard< Moscow\",10000,122,\"this is test record\");");

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    flag=query.exec("INSERT INTO CurrentCoinsView (stID, varID, pict, condition, status, otherInfo)"
                    "VALUES (1,1,11,\"XF\",\"Collection\",\"sample comment\");");

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    flag=query.exec("INSERT INTO subtypeReferencesView(stID, reduction, number, rarity, \"comment\")"
                    "VALUES (1,\"Uzdenikov\",2233,\"-\",\"wrong picture of edge\");");

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    flag=query.exec("INSERT INTO variantReferencesView(varID, reduction, number, rarity, \"comment\")"
                    "VALUES (1,\"Uzdenikov\",2233,\"-\",\"wrong picture of edge\");");

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

    flag=query.exec("SELECT COUNT(*) FROM MintYard");  //RESULT==1

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    if (query.next()){
        QCOMPARE(query.value(0).toInt(),1);
    }

    //Check Cascade Deletion

    flag=query.exec("DELETE FROM TypesView WHERE ID=1;");

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    flag=query.exec("SELECT COUNT(*) FROM SubTypesView;");  //RESULT==0

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    if (query.next()){
        QCOMPARE(query.value(0).toInt(),0);
    }

    flag=query.exec("SELECT COUNT(*) FROM VariantsView;");  //RESULT==0

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    if (query.next()){
        QCOMPARE(query.value(0).toInt(),0);
    }

    flag=query.exec("SELECT COUNT(*) FROM CurrentCoinsView;");  //RESULT==0

    if(!flag){
        QFAIL(query.lastError().text().toLocal8Bit());
    }

    if (query.next()){
        QCOMPARE(query.value(0).toInt(),0);
    }
}
