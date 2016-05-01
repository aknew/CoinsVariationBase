QT += testlib core gui sql qml quick widgets

CONFIG += c++11

TARGET = CoinsBaseTests
CONFIG += console testcase
CONFIG -= app_bundle

TEMPLATE = app

SOURCES += main.cpp \
    CBBaseProviderTester.cpp \
    ../src/CBAttachmentsProvider.cpp \
    ../src/CBBaseProvider.cpp \
    ../src/CBImageProvider.cpp \
    ../src/CBNode.cpp \
    ../src/CBTranslator.cpp \
    ../src/CBUtils.cpp \
    ../src/CBSettings.cpp \
    ../src/CBSqlRelationalTableModel.cpp \
    CBUTilsTestSet.cpp

HEADERS += \
    CBBaseProviderTester.h \
    ../src/CBAttachmentsProvider.h \
    ../src/CBBaseProvider.h \
    ../src/CBImageProvider.h \
    ../src/CBNode.h \
    ../src/CBTranslator.h \
    ../src/CBUtils.h \
    ../src/CBSettings.h \
    ../src/CBSqlRelationalTableModel.h \
    CBUTilsTestSet.h
