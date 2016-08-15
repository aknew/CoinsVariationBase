#ifndef CBBASEPROVIDERTESTER_H
#define CBBASEPROVIDERTESTER_H

#include <QObject>

class CBBaseProvider;
class CBNode;

/**
 * @brief The CBBaseProviderTestSet class needs to test both CBBaseProvider and CBNode
 * I know that this is not corect in unit tests, but I am considering a bunch of these
 * two classes as a single entity and noone except CBBaseProvider can create new CBNode
 */

class CBBaseProviderTestSet : public QObject
{
    Q_OBJECT
public:
    explicit CBBaseProviderTestSet(QObject *parent = 0):QObject(parent){}

public slots:
    void checkOpenedBase();


private:
    CBBaseProvider *m_baseProvider;
    CBNode *m_current_node;
    bool baseWasOpened = false; /// needs for check that checkOpenedBase realy was called

private slots:
    void openningBaseTest();
    void wrongSubNodes();
    void selectedItemTest();
    void jsonFromNode();
    void clonningTest();
};

#endif // CBBASEPROVIDERTESTER_H
