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

OTHER_FILES += \
    ../sql/struct.sql

## Define what files are 'extra_libs' and where to put them
sqlStruct.files = "../sql/struct.sql"

sqlStruct.path = "C:\Users\U940\Documents\GitHub\CoinsVariationBase\bin\TestCoinsBase-build-Desktop_4_8_4"

## Tell qmake to add the moving of them to the 'install' target
INSTALLS += sqlStruct
