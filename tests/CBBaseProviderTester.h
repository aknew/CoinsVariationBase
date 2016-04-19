#ifndef CBBASEPROVIDERTESTER_H
#define CBBASEPROVIDERTESTER_H

#include <QObject>

class CBBaseProvider;
class CBNode;

class CBBaseProviderTester : public QObject
{
    Q_OBJECT
public:
    explicit CBBaseProviderTester(QObject *parent = 0):QObject(parent){}

public slots:
    void checkOpenedBase();


private:
    CBBaseProvider *m_baseProvider;
    CBNode *m_current_node;
    bool baseWasOpened = false; /// needs for check that checkOpenedBase realy was called

private slots:
    void initTestCase(){}
    void openningBaseTest();
    void goToSubnode();
    void cleanupTestCase(){}
};

#endif // CBBASEPROVIDERTESTER_H
