QT       += core gui sql qml quick widgets

SOURCES += \
    main.cpp \
    CBController.cpp \
    CBTranslator.cpp \
    CBUtils.cpp \
    CBBaseProvider.cpp \
    CBNode.cpp \
    CBSqlRelationalTableModel.cpp \
    CBImageProvider.cpp \
    CBSettings.cpp

DISTFILES += \
    main.qml \
    CBControls/qmldir \
    CBControls/BackgroundRect.qml \
    CBControls/FullImageInfo.qml \
    CBControls/FilterDialog.qml \
    CBControls/LabeledComboBoxInput.qml \
    CBControls/LabeledTextInput.qml \
    CBControls/NextLevelList.qml \
    CBControls/StyledText.qml

RESOURCES += \
    resources.qrc

HEADERS += \
    CBController.h \
    CBTranslator.h \
    CBUtils.h \
    CBBaseProvider.h \
    CBNode.h \
    CBSqlRelationalTableModel.h \
    CBImageProvider.h \
    CBSettings.h

CONFIG += c++11
