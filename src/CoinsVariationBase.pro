#-------------------------------------------------
#
# Project created by QtCreator 2011-10-08T16:34:20
#
#-------------------------------------------------

QT       += core gui sql qml quick widgets

TARGET = CoinsVariationBase
TEMPLATE = app


SOURCES += main.cpp\
    CVBImageProvider.cpp \
    CVBSqlNode.cpp \
    CVBSqlRelationalTableModel.cpp \
    CVBBaseProvider.cpp \
    CVBController.cpp \
    comboboxdescription.cpp \
    CVBUtils.cpp \
    CVBTranslator.cpp

HEADERS  += CVBImageProvider.h \
    CVBSqlNode.h \
    CVBBaseProvider.h \
    CVBSqlRelationalTableModel.h \
    CVBController.h \
    comboboxdescription.h \
    CVBUtils.h \
    CVBTranslator.h

OTHER_FILES += \
    MainWindow.qml \
    CVBControls/BigImage.qml \
    CVBControls/ComboBox.qml \
    CVBControls/ComboTextEdit.qml \
    CVBControls/ImageWithFullScreen.qml \
    CVBControls/Input.qml \
    CVBControls/NextLevelList.qml \
    CVBControls/StyledText.qml \
    CVBControls/StyledTextInput.qml \
    CVBControls/TitledInput.qml \
    CVBControls/qmldir

RESOURCES += \
    res.qrc

