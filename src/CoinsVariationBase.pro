#-------------------------------------------------
#
# Project created by QtCreator 2011-10-08T16:34:20
#
#-------------------------------------------------

QT       += core gui sql xml qml quick widgets

TARGET = CoinsVariationBase
TEMPLATE = app


SOURCES += main.cpp\
    CVBImageProvider.cpp \
    CVBSqlNode.cpp \
    CVBSqlRelationalTableModel.cpp \
    CVBBaseProvider.cpp \
    CVBController.cpp \
    comboboxdescription.cpp \
    CVBUtils.cpp

HEADERS  += CVBImageProvider.h \
    CVBSqlNode.h \
    CVBBaseProvider.h \
    CVBSqlRelationalTableModel.h \
    CVBController.h \
    comboboxdescription.h \
    CVBUtils.h

FORMS +=

OTHER_FILES += \
    MainWindow.qml

RESOURCES += \
    res.qrc

