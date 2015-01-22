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
    void testRowInsertion();
    void initTestCase();

private:
    
};

#endif // TESTBASECLASS_H
