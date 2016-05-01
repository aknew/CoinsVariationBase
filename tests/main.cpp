#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QTest>

#include "CBBaseProviderTester.h"
#include "CBUTilsTestSet.h"


int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    // remove old test base with unknown state

    QDir dir("TestBase");
    if (!dir.removeRecursively()){
        qWarning() << "Can't remove old base";
    }

    //extract testBase in known default state, I used 7zip because it always stays on my PCs

    system("\"c:\\Program Files\\7-Zip\\7z.exe\" x ../testData/TestBase.zip");

    qInfo() << "Base has been prepared, starting tests";

    QTest::qExec(new CBBaseProviderTester, argc, argv);
    QTest::qExec(new CBUTilsTestSet, argc, argv);

    return 0;
}
