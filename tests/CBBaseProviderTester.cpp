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


void CBBaseProviderTester::goToSubnode(){
    QVERIFY(baseWasOpened);
}
