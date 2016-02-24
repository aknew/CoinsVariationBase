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
    CBSettings.cpp \
    CBAttachmentsProvider.cpp \
    CBBaseIconProvider.cpp

DISTFILES += \
    main.qml \
    CBControls/qmldir \
    CBControls/BackgroundRect.qml \
    CBControls/FilterDialog.qml \
    CBControls/LabeledComboBoxInput.qml \
    CBControls/LabeledLongText.qml \
    CBControls/LabeledTextInput.qml \
    CBControls/NextLevelList.qml \
    CBControls/LabeledDateInput.qml \
    CBControls/AttachmentsList.qml \
    CBControls/AttachmentFullInfo.qml \
    FormCreator.js \
    ../translations/ru_RU.json \
    CBControls/BasesList.qml \
    DesktopMenu.qml  \
    AndroidMenu.qml

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
    CBSettings.h \
    CBAttachmentsProvider.h \
    CBBaseIconProvider.h

CONFIG += c++11
