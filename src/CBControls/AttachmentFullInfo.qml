import QtQuick 2.3
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

import CB.api 1.0

Rectangle {

    id: attachmentRootRect

    property bool editing: false
    states: State {
        name: "editing"
        PropertyChanges {
            target: attachmentRootRect
            editing: true
        }
    }

    property var model
    property int index: -1

    onIndexChanged: {
        attachmentInfo = model[index]
    }

    property var attachmentInfo

    onAttachmentInfoChanged: {
        attachImage.source = "image://imageProvider/" + attachmentInfo.file
        listModel.clear()
        for (var name in attachmentInfo) {
            if (name === "file") {
                continue
            }
            addInfoField(name, attachmentInfo[name])
        }
    }

    function addInfoField(name, value) {
        var val = {
            name: name,
            value: value
        }
        listModel.append(val)
    }

    function cnangeInfoField(name, value, index) {
        var val = {
            name: name,
            value: value
        }
        listModel.set(index, val)
    }

    function collectData() {
        var map = {

        }
        for (var i = 0; i < listModel.count; ++i) {
            var element = listModel.get(i)
            map[element.name] = element.value
        }
        map.file = attachmentInfo.file
        CBApi.baseProvider.attachmentsProvider.updateAttributes(map)
    }

    ListModel {
        id: listModel
    }

    Flickable {
        clip: true
        width: parent.width
        height: editing ? parent.height - bottomBar.height : parent.height
        contentHeight: attachImage.height + attachImage.y
        ListView {
            width: parent.width
            height: Math.min(contentHeight, 300)
            id: attachmentsInfoListView
            clip: true
            model: listModel
            delegate: Rectangle {
                width: parent.width
                height: Math.max(rowText.height, btnEdit.height)
                Text {
                    id: rowText
                    text: "<b>" + name + ":</b> " + value
                    anchors.left: parent.left
                    anchors.right: editing ? btnEdit.left : parent.right
                    wrapMode: Text.Wrap
                }
                Button {
                    id: btnEdit
                    iconSource: "/icons/edit.png"
                    visible: editing
                    anchors.right: btnRemove.left
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        editRowDialog.index = index
                        editRowDialog.name = name
                        editRowDialog.value = value
                        editRowDialog.open()
                    }
                }
                Button {
                    id: btnRemove
                    iconSource: "/icons/delete.png"
                    visible: editing
                    anchors.right: parent.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        deleteRowDialog.index = index
                        deleteRowDialog.open()
                    }
                }
            }
        }

        Image {
            id: attachImage
            anchors.top: attachmentsInfoListView.bottom
            width: parent.width
            fillMode: Image.PreserveAspectFit
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button == Qt.RightButton) {
                        openMenu.popup()
                    } else {
                        CBApi.baseProvider.attachmentsProvider.openAttach(
                                    attachmentInfo.file)
                    }
                }
            }
            MouseArea{
                height: 128
                width:128
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 5
                visible:!editing && index>0
                onClicked: {
                    index = index -1
                }
                Image {
                    source: "/previous"
                }
            }
            MouseArea{
                height: 128
                width:128
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 5
                visible:!editing && index<model.length-1
                onClicked: {
                    index = index + 1
                }
                Image {
                    source: "/next"
                }
            }
        }
    }

    Rectangle {
        id: bottomBar
        visible: editing
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 100
        Button {
            id: btnAddField
            iconSource: "/icons/add.png"
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5
            height: parent.height - 10
            width: parent.height - 10
            onClicked: {
                editRowDialog.index = -1
                editRowDialog.name = ""
                editRowDialog.value = ""
                editRowDialog.open()
            }
        }
    }

    MessageDialog {
        id: deleteRowDialog
        text: qsTr("Do you realy want to delete this field?")
        icon: StandardIcon.Warning
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        property int index: -1
        modality: Qt.WindowModal
        onAccepted: {
            listModel.remove(index)
        }
    }

    Dialog {
        id: editRowDialog
        title: qsTr("Select value for field: ")
        property int index: -1
        property string name: ""
        onNameChanged: {
            edtName.setValue(name)
        }

        property alias value: edtValue.value

        contentItem: Rectangle {
            implicitWidth: 600
            implicitHeight:Qt.platform.os == "android" ? 285 :100
            LabeledComboBoxInput {
                id: edtName
                title: qsTr("Field name:")
                editing: true
                anchors.topMargin: 5
                anchors.top: parent.top
                model:[qsTr("source"), qsTr("about")]
            }
            LabeledTextInput {
                id: edtValue
                title: qsTr("Field value:")
                editing: true
                anchors.topMargin: 5
                anchors.top: edtName.bottom
            }

            Button {
                id: btnApply
                width: (parent.width - 15) / 2
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.top: edtValue.bottom
                anchors.topMargin: 5
                text: qsTr("Apply")
                onClicked: {
                    if (editRowDialog.index === -1) {
                        addInfoField(edtName.getValue(), edtValue.value)
                    } else {
                        cnangeInfoField(edtName.getValue(), edtValue.value,
                                        editRowDialog.index)
                    }

                    editRowDialog.close()
                }
            }
            Button {
                width: (parent.width - 15) / 2
                anchors.left: btnApply.right
                anchors.leftMargin: 5
                anchors.top: edtValue.bottom
                anchors.topMargin: 5
                text: qsTr("Cancel")
                onClicked: {
                    editRowDialog.close()
                }
            }
        }
    }

    Menu {
        id: openMenu
        MenuItem {
            text: qsTr("Open file")
            onTriggered: {
                CBApi.baseProvider.attachmentsProvider.openAttach(
                            attachmentInfo.file)
            }
        }
        MenuItem {
            text: qsTr("Open contains folder")
            onTriggered: {
                CBApi.baseProvider.attachmentsProvider.openFolder()
            }
        }
    }
}
