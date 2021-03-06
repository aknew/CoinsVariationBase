#include "CBBaseProviderTestSet.h"
#include "../src/CBBaseProvider.h"
#include <QTest>

void CBBaseProviderTestSet::openningBaseTest(){

    m_baseProvider=new CBBaseProvider();
    this->connect(m_baseProvider,SIGNAL(readyToWork()),this,SLOT(checkOpenedBase()));
    m_baseProvider->startWithPath(  QString("TestBase"));
}

void CBBaseProviderTestSet::checkOpenedBase(){
    baseWasOpened = true;

    m_current_node = m_baseProvider->getStartNode();
}

void CBBaseProviderTestSet::wrongSubNodes(){
    // try to get node which does not exist
    CBNode *wrongSubNode = m_baseProvider->getNode("Wrong subnode",m_current_node);
    QVERIFY(wrongSubNode == NULL);

    // try to get node which exists, but not subnode of start node
    wrongSubNode = m_baseProvider->getNode("ConcreteCoins",m_current_node);
    QVERIFY(wrongSubNode == NULL);

    // TODO: add test to check what will happend if I try to get subnode with relation but without selection item on current node
}

void CBBaseProviderTestSet::clonningTest(){
    QAbstractItemModel * listModel = (QAbstractItemModel *)m_current_node->listModel();
    int recordCount = listModel->rowCount();
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
    clonned_item["firstYear"]=QVariant(1000);

    m_current_node->applyChanges(clonned_item);

    // check that selected item was not changed after appliing changes
    QVariantMap clonned_item_after_saving = m_current_node->selectedItem();
    QVERIFY(clonned_item["id"]==clonned_item_after_saving["id"]);

    // check that we have recordCount + 1

    QCOMPARE(recordCount+1,listModel->rowCount());

}

void CBBaseProviderTestSet::jsonFromNode(){

    // I especially use Varieties because this node contains both listModel and model
    m_current_node->selectItemWithIndex(2);
    CBNode *subNode = m_baseProvider->getNode("Varieties",m_current_node);

    subNode->exportListToFile("export");

    //TODO: need write this test after
    QFAIL("This test is not implementad yet");

}

void CBBaseProviderTestSet::selectedItemTest(){
    QVariantMap etalon;
    etalon["avers"]=QVariant("Вензель императора Павла I и императорская корона над ним");
    etalon["edge"]= QVariant("Шнуровидный");
    etalon["firstYear"]= QVariant(1797);
    etalon["id"]= QVariant( "d1452c7b-b80f-4b76-b06a-1aed6de23f84");
    etalon["issue"]= QVariant("Регулярный общегосударственный");
    etalon["lastYear"]= QVariant(1801);
    etalon["metal"]= QVariant("медь");
    etalon["nominal"]= QVariant("Копейка");
    etalon["revers"]= QVariant("Надпись в 2 строки \"1| КОПЕЙКА\" под ней черта и год и монетный двор в 2 строки");
    etalon["weigth"]= QVariant(10.24);


    m_current_node->selectItemWithIndex(2);

    QVariantMap map = m_current_node->selectedItem();

    for (auto iter: etalon.keys()){
        QVERIFY(etalon[iter]==map[iter]);
    }
}
