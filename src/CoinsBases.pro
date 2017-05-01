QT       += core gui sql qml quick widgets quickcontrols2

android{
    QT += androidextras
}

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
    CBBaseIconProvider.cpp \
    CBWordLCS.cpp \
    CBFieldDifference.cpp \
    CBItemDifference.cpp

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
    CBControls/GUIStyle.qml \
    CBControls/DiffView.qml \
    CBControls/LabeledIcon.qml

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
    CBBaseIconProvider.h \
    CBWordLCS.h \
    CBFieldDifference.h \
    CBItemDifference.h

ios{
  HEADERS += \
       iOSspecific/iOSHelper.h \
       iOSspecific/DocViewController.h

  SOURCES += \
       iOSspecific/iOSHelper.mm \
       iOSspecific/DocViewController.m

}

CONFIG += c++11
