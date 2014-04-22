#ifndef TESTBASECLASS_H
#define TESTBASECLASS_H

#include <QObject>
#include <QTest>
#include <QtSql>

class TestBaseClass : public QObject
{
    Q_OBJECT
public:
    explicit TestBaseClass(QObject *parent = 0);
    
private slots:
    void testTypeInsertion();
    void testVariantInsertion();
    void testVarianDeletion();
    void testTypeDeletion();
    void initTestCase();

private:
    bool flag;

    QSqlQuery query;

    QSqlDatabase db;
    
};

#endif // TESTBASECLASS_H
