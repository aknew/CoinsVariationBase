import QtQuick 2.5
import Qt.labs.platform 1.1
import QtQuick.Controls 2.0
import "."

// QTBUG-34418, singletons require explicit import to load qmldir file
import CB.api 1.0

Rectangle {
    width: parent.width
    height: attachmentsListView.height + attachBar.height
    property bool editing: false
    Rectangle {
        id: attachBar
        width: parent.width
        height: GUIStyle.barHeight
        anchors.top: parent.top
        Button {
            id: btnAddFile
            contentItem: ToolbarContextItem{
                text: '➕'
            }
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5
            height: parent.height - 10
            width: parent.height - 10
            visible: !editing
            onClicked: {
                attachDialog.selectFolder = false
                attachDialog.selectMultiple = true
                attachDialog.open()
            }
        }
        Button {
            id: btnAddFolder
            contentItem: ToolbarContextItem{
                text: '📂'
            }
            anchors.left: btnAddFile.right
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5
            height: parent.height - 10
            width: parent.height - 10
            visible: !editing
            onClicked: {
                attachDialog.selectFolder = true
                attachDialog.open()
            }
        }
    }
    ListView {
        ScrollBar.vertical: ScrollBar {
        }
        id: attachmentsListView
        clip: true
        width: parent.width
        anchors.top: attachBar.bottom
        height: Math.min(contentHeight, 300)
        model: CBApi.baseProvider.attachmentsProvider.attributes
        delegate: Rectangle {

            property string currentID: CBApi.baseProvider.attachmentsProvider.currentId
            width: parent.width
            height: 190
            BackgroundRect {
            }

            Image {
                id: imgAttach
                anchors.topMargin: 5
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 5
                height: parent.height - 10
                width: height * 2
                sourceSize.height: height
                sourceSize.width: width
                source: "image://imageProvider/" + currentID + "/thumbnail." + modelData.file
                fillMode: Image.PreserveAspectFit
            }
            Text {
                anchors.topMargin: 5
                anchors.top: parent.top
                anchors.left: imgAttach.right
                anchors.leftMargin: 5
                anchors.right: editing ? btnRemove.left : parent.right
                anchors.rightMargin: 5
                text: {
                    if (modelData.about !== undefined) {
                        modelData.about
                    } else {
                        if (modelData[qsTr("about")] !== undefined) {
                            modelData[qsTr("about")]
                        } else {
                            modelData.file
                        }
                    }
                }
                wrapMode: Text.Wrap
            }
            MouseArea {
                anchors.fill: parent
                enabled: !editing
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button === Qt.RightButton) {
                        openMenu.file = modelData.file
                        openMenu.open()
                    } else {
                        mainWindow.createAndPush(
                                    "CBControls/AttachmentFullInfo.qml", {
                                        model: attachmentsListView.model,
                                        index: index
                                    })
                    }
                }
            }
            Button {
                id: btnRemove
                contentItem: ToolbarContextItem{
                    text: '✘'
                }
                visible: editing
                anchors.right: parent.right
                anchors.rightMargin: 5
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
        buttons: StandardButton.Ok | StandardButton.Cancel
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
        folder: CBSettings.attachSearchPath
        onAccepted: {
            for (var i = 0; i < fileUrls.length; ++i) {
                CBApi.baseProvider.attachmentsProvider.insertNewAttach(
                            fileUrls[i])
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
        MenuItem {
            text: qsTr("Make default image")
            onTriggered: {
                CBApi.baseProvider.attachmentsProvider.setMain(openMenu.file)
            }
        }
    }
}
