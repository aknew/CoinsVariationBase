#-------------------------------------------------
#
# Project created by QtCreator 2013-05-04T23:16:57
#
#-------------------------------------------------

QT       += core testlib sql

QT       -= gui

TARGET = TestCoinsBase
CONFIG   += console
CONFIG   -= app_bundle

TEMPLATE = app


SOURCES += main.cpp \
    testbaseclass.cpp \
    ../src/CVBBaseProvider.cpp \
    ../src/CVBSqlNode.cpp \
    ../src/CVBSqlRelationalTableModel.cpp \
    ../src/comboboxdescription.cpp

HEADERS += \
    testbaseclass.h \
    ../src/CVBBaseProvider.h \
    ../src/CVBSqlNode.h \
    ../src/CVBSqlRelationalTableModel.h \
    ../src/comboboxdescription.h

RESOURCES += \
    res.qrc
