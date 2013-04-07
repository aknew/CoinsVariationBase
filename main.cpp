#ifdef HAVE_QT5

#include <QtWidgets/QApplication>

#else

#include <QtGui/QApplication>

#endif

#include <QtCore/QUrl>
#include "mainwindow.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    MainWindow mainWindow;
    //mainWindow.setOrientation(MainWindow::ScreenOrientationAuto); //FIXME - qt 5.0.0 error
    mainWindow.showExpanded();

    return a.exec();
}
