#include "CBBaseProviderTester.h"
#include "../src/CBBaseProvider.h"
#include <QTest>

void CBBaseProviderTester::openningBaseTest(){

    m_baseProvider=new CBBaseProvider();
    this->connect(m_baseProvider,SIGNAL(readyToWork()),this,SLOT(checkOpenedBase()));
    m_baseProvider->startWithPath(  QString("TestBase"));
}

void CBBaseProviderTester::checkOpenedBase(){
    baseWasOpened = true;

    m_current_node = m_baseProvider->getStartNode();
}

void CBBaseProviderTester::wrongSubNodes(){
    // try to get node which does not exist
    CBNode *wrongSubNode = m_baseProvider->getNode("Wrong subnode",m_current_node);
    QVERIFY(wrongSubNode == NULL);

    // try to get node which exists, but not subnode of start node
    wrongSubNode = m_baseProvider->getNode("ConcreteCoins",m_current_node);
    QVERIFY(wrongSubNode == NULL);
}


void CBBaseProviderTester::goToSubnode(){
    QVERIFY(baseWasOpened);
}
