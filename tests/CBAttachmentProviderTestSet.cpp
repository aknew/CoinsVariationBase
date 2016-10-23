#include "CBAttachmentProviderTestSet.h"
#include "../src/CBAttachmentsProvider.h"
#include <QTemporaryDir>
#include <QTest>
#include <QUuid>


CBAttachmentProviderTestSet::CBAttachmentProviderTestSet(QObject *parent) : QObject(parent)
{

}

void CBAttachmentProviderTestSet::mergeAttachTest(){

    QTemporaryDir tempDir;
    if (!tempDir.isValid()) {
        QFAIL("can't create tempoary dir");
        // dir.path() returns the unique directory path
    }
    QString rootPath = tempDir.path() +"/";
    QString filePath = rootPath + "file.jpg";
    QFile file(filePath);
    file.open(QIODevice::WriteOnly);
    file.close();
    CBAttachmentsProvider ap(rootPath);

    QString attach1 = QUuid::createUuid().toString();

    ap.selectID(attach1);
    ap.insertNewAttach(filePath);

    QString attach2 = QUuid::createUuid().toString();
    ap.selectID(attach2);
    ap.insertNewAttach(filePath);

    qDebug() << rootPath;
    QString diff = "moc diff";
    ap.mergeAttachments(attach2,attach1,diff);

    QDir dir(rootPath +"/attachments/" + attach2);

    QVERIFY(!dir.exists());

    dir = QDir (rootPath +"/attachments/" + attach1);

    QVERIFY(dir.exists());
    QVERIFY(dir.count()==3);
}
