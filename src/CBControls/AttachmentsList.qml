import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4

import CB.api 1.0

Rectangle {
    width: parent.width
    height: attachmentsListView.height + attachBar.height
    property bool editing: false
    Rectangle {
        id: attachBar
        width: parent.width
        height: 100
        anchors.top: parent.top
        Button {
            id: btnAddField
            iconSource: "/add"
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5
            height: parent.height - 10
            width: parent.height - 10
            visible: !editing
            onClicked: {
                attachDialog.open()
            }
        }
    }
    ListView {
        id: attachmentsListView
        clip: true
        width: parent.width
        anchors.top: attachBar.bottom
        height: Math.min(contentHeight, 300)
        model: CBApi.baseProvider.attachmentsProvider.attributes
        delegate: Rectangle {
            width: parent.width
            height: 100
            BackgroundRect {
            }

            Image {
                id: imgAttach
                anchors.topMargin: 5
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 5
                width: 90
                height: 90
                source: "image://imageProvider/" + modelData.file
                fillMode: Image.PreserveAspectFit
            }
            Text {
                anchors.topMargin: 5
                anchors.top: parent.top
                anchors.left: imgAttach.right
                anchors.leftMargin: 5
                anchors.right: editing ? btnRemove.left : parent.right
                text: {
                    if (modelData.about !== undefined){
                        modelData.about
                    }
                    else{
                        if (modelData[qsTr("about")]!== undefined){
                           modelData[qsTr("about")]
                        }
                        else{
                            modelData.file
                        }
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button == Qt.RightButton) {
                        openMenu.file = modelData.file
                        openMenu.popup()
                    } else {
                        var component = Qt.createComponent(
                                    "AttachmentFullInfo.qml")
                        switch (component.status) {
                        case Component.Ready:
                            var form = component.createObject()
                            form.model = attachmentsListView.model
                            form.index = index
                            mainWindow.pushToStackView(form)
                            break
                        case Component.Error:
                            console.log(component.errorString())
                            break
                        }
                    }
                }
            }
            Button {
                id: btnRemove
                iconSource: "/delete"
                visible: editing
                anchors.right: parent.right
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    deleteDialog.attachID = modelData.file
                    deleteDialog.open()
                }
            }
        }
    }

    MessageDialog {
        id: deleteDialog
        text: qsTr("Do you realy want to delete this attach?")
        icon: StandardIcon.Warning
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        property string attachID: ""
        modality: Qt.WindowModal
        onAccepted: {
            CBApi.baseProvider.attachmentsProvider.deleteAttach(attachID)
        }
    }

    FileDialog {
        id: attachDialog
        modality: Qt.WindowModal
        title: qsTr("Choose a file to load as attach")
        selectMultiple: false
        folder: CBSettings.attachSearchPath
        onAccepted: {
            var modelData = CBApi.baseProvider.attachmentsProvider.insertNewAttach(
                        fileUrls[0])
            var component = Qt.createComponent("AttachmentFullInfo.qml")
            switch (component.status) {
            case Component.Ready:
                var form = component.createObject()
                form.model = attachmentsListView.model
                form.index = form.model.length -1
                mainWindow.pushToStackView(form)
                break
            case Component.Error:
                console.log(component.errorString())
                break
            }
        }
    }

    Menu {
        id: openMenu
        property string file: ""
        MenuItem {
            text: qsTr("Open file")
            onTriggered: {
                CBApi.baseProvider.attachmentsProvider.openAttach(openMenu.file)
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
