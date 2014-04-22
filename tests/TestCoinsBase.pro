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
    testbaseclass.cpp

HEADERS += \
    testbaseclass.h

OTHER_FILES +=

## Define what files are 'extra_libs' and where to put them
sqlStruct.files = "../sql/struct.sql"

sqlStruct.path = "$$OUT_PWD"

## Tell qmake to add the moving of them to the 'install' target
INSTALLS += sqlStruct
