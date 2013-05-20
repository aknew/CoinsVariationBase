#include <QCoreApplication>
#include "testbaseclass.h"

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    TestBaseClass testBase;

    QTest::qExec(&testBase, argc, argv);
    
    return a.exec();
}
