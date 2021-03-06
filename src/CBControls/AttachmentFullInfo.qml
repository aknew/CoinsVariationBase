import QtQuick 2.7
import QtQuick.Controls
import Qt.labs.platform 1.1

import CB.api 1.0
import "."

// QTBUG-34418, singletons require explicit import to load qmldir file
Rectangle {

    id: attachmentRootRect

    property bool editing: false
    property bool editable: true
    property int formType: CBApi.AttachForm
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
        if (model) {
            attachmentInfo = model[index]
        }
    }
    onModelChanged: {
        if (index != -1) {
            attachmentInfo = model[index]
        }
    }

    property var attachmentInfo

    property string currentID: CBApi.baseProvider.attachmentsProvider.currentId

    onAttachmentInfoChanged: {
        attachImage.source = "image://imageProvider/" + currentID + "/" + attachmentInfo.file
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

    MouseArea {
        height: parent.height
        width: 64
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 5
        visible: !editing && index > 0
        onClicked: {
            index = index - 1
        }
        Text {
            text:"〈"
            font.pointSize: 36
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }
    MouseArea {
        height: parent.height
        width: 64
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 5
        visible: !editing && index < model.length - 1
        onClicked: {
            index = index + 1
        }
        Text {
            text:"〉"
            font.pointSize: 36
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Flickable {
        ScrollBar.vertical: ScrollBar {
        }
        clip: true
        width: parent.width - 64 * 2
        x: 64
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
                height: Math.max(rowText.height, btnRemove.height)
                Text {
                    id: rowText
                    text: "<b>" + name + ":</b> " + value
                    anchors.left: parent.left
                    anchors.right: editing ? btnRemove.left : parent.right
                    wrapMode: Text.Wrap
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: editing
                    onClicked: {
                        editRowDialog.index = index
                        editRowDialog.name = name
                        editRowDialog.value = value
                        editRowDialog.open()
                    }
                }
                Button {
                    id: btnRemove
                    contentItem: ToolbarContextItem{
                        text: '✘'
                    }
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
                    if (mouse.button === Qt.RightButton) {
                        openMenu.open()
                    } else {
                        CBApi.baseProvider.attachmentsProvider.openAttach(
                                    attachmentInfo.file)
                    }
                }
                propagateComposedEvents: GUIStyle.isMobile
                onPressAndHold: {
                    if (GUIStyle.isMobile) {
                        openMenu.open()
                    }
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
        height: GUIStyle.barHeight
        Button {
            id: btnAddField
            contentItem: ToolbarContextItem{
                text: '➕'
            }
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
        buttons: StandardButton.Ok | StandardButton.Cancel
        property int index: -1
        modality: Qt.WindowModal
        onAccepted: {
            listModel.remove(index)
        }
    }

    Popup {
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
            implicitHeight: GUIStyle.isMobile ? 285 : 120
            LabeledComboBoxInput {
                id: edtName
                title: qsTr("Field name:")
                editing: true
                anchors.topMargin: 5
                anchors.top: parent.top
                model: [qsTr("source"), qsTr("about")]
            }
            LabeledLongText {
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
        MenuItem {
            text: qsTr("Copy")
            onTriggered: {
                CBApi.baseProvider.attachmentsProvider.copyAttach(attachmentInfo.file)
            }
        }
    }
}
