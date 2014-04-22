#ifndef TESTBASECLASS_H
#define TESTBASECLASS_H

#include <QObject>
#include <QTest>

class TestBaseClass : public QObject
{
    Q_OBJECT
public:
    explicit TestBaseClass(QObject *parent = 0);
    
private slots:
    void testBase();
    void initTestCase();
    
};

#endif // TESTBASECLASS_H
