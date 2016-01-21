import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4

import CB.api 1.0

Rectangle {
    width: parent.width
    height: attachmentsListView.height+attachBar.height
    Rectangle {
        id: attachBar
        width: parent.width
        height: 100
        anchors.top: parent.top
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
                attachDialog.open()
            }
        }
    }
    ListView {
        id: attachmentsListView
        clip: true
        width: parent.width
        anchors.top: attachBar.bottom
        height: Math.min(contentHeight,300)
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
                anchors.right: editing? btnRemove.left : parent.right
                text: modelData.about === undefined ? modelData.file : modelData.about
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var component = Qt.createComponent("AttachmentFullInfo.qml")
                    switch (component.status) {
                    case Component.Ready:
                        var form = component.createObject()
                        form.attachmentInfo = modelData
                        mainWindow.pushToStackView(form)
                        break
                    case Component.Error:
                        console.log(component.errorString())
                        break
                    }
                }
            }
            Button {
                // TODO: add confirm dialog
                id: btnRemove
                iconSource: "/icons/delete.png"
                visible: editing
                anchors.right: parent.right
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                onClicked: CBApi.baseProvider.attachmentsProvider.deleteAttach(
                               modelData.file)
            }
        }
    }

    FileDialog {
        id: attachDialog
        modality: Qt.WindowModal
        title: qsTr("Choose a file to load as attach")
        selectMultiple: false
        onAccepted: {
            var modelData = CBApi.baseProvider.attachmentsProvider.insertNewAttach(
                        fileUrls[0])
            var component = Qt.createComponent("AttachmentFullInfo.qml")
            switch (component.status) {
            case Component.Ready:
                var form = component.createObject()
                form.attachmentInfo = modelData
                mainWindow.pushToStackView(form)
                break
            case Component.Error:
                console.log(component.errorString())
                break
            }
        }
    }
}
