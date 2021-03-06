QT += testlib core gui sql qml quick widgets

CONFIG += c++11

TARGET = CoinsBaseTests
CONFIG += console testcase no_batch
CONFIG -= app_bundle

TEMPLATE = app

SOURCES += main.cpp \
    ../src/CBAttachmentsProvider.cpp \
    ../src/CBBaseProvider.cpp \
    ../src/CBImageProvider.cpp \
    ../src/CBNode.cpp \
    ../src/CBTranslator.cpp \
    ../src/CBUtils.cpp \
    ../src/CBSettings.cpp \
    ../src/CBSqlRelationalTableModel.cpp \
    ../src/CBWordLCS.cpp \
    CBWordLCSTestSet.cpp \
    ../src/CBFieldDifference.cpp \
    ../src/CBItemDifference.cpp \
    CBBaseProviderTestSet.cpp \
    CBAttachmentProviderTestSet.cpp

HEADERS += \
    ../src/CBAttachmentsProvider.h \
    ../src/CBBaseProvider.h \
    ../src/CBImageProvider.h \
    ../src/CBNode.h \
    ../src/CBTranslator.h \
    ../src/CBUtils.h \
    ../src/CBSettings.h \
    ../src/CBSqlRelationalTableModel.h \
    ../src/CBWordLCS.h \
    CBWordLCSTestSet.h \
    ../src/CBFieldDifference.h \
    ../src/CBItemDifference.h \
    CBBaseProviderTestSet.h \
    CBAttachmentProviderTestSet.h
