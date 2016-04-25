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

void CBBaseProviderTester::clonningTest(){
    m_current_node->selectItemWithIndex(2);
    QVariantMap default_item = m_current_node->selectedItem();
    m_current_node->cloneItem();
    QVariantMap clonned_item = m_current_node->selectedItem();
    for (auto iter: default_item.keys()){
        if (iter == "id"){
            QVERIFY(clonned_item[iter]!=default_item[iter]);
        }
        else{
            QVERIFY(clonned_item[iter]==default_item[iter]);
        }
    }

    clonned_item["nominal"]=QVariant("Test insert");

    m_current_node->applyChanges(clonned_item);

    // check that selected item was not changed after appliing changes
    QVariantMap clonned_item_after_saving = m_current_node->selectedItem();
    QVERIFY(clonned_item["id"]!=clonned_item_after_saving["id"]);

}


void CBBaseProviderTester::goToSubnode(){
    QVERIFY(baseWasOpened);
}
