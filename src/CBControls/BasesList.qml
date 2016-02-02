import QtQuick 2.5
import QtQuick.Dialogs 1.2

import CB.api 1.0

GridView {
    model: CBSettings.recentBases
    cellHeight: 200
    cellWidth: 200
    delegate: Rectangle {
        color: "transparent"
        height: 200
        width: 200
        MouseArea {
            anchors.fill: parent
            onClicked: {
                //TODO: need move use some constants instead string
                if (modelData === qsTr("Open new base")){
                    openBase()
                }
                else{
                   CBApi.openRecentBase(modelData)
                }
            }
        }
        Image {
            source: "image://baseIconProvider/" + modelData
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.bottom: baseTitle.top
            anchors.bottomMargin: 5
            fillMode: Image.PreserveAspectFit
        }
        Text {
            id: baseTitle
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.bottom: parent.bottom
            width: parent.width
            text: modelData
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // Dialogs
    FileDialog {
        id: openBaseDialog
        modality: Qt.WindowModal
        title: qsTr("Choose a base's folder")
        selectExisting: true
        selectMultiple: false
        selectFolder: true
        onAccepted: {
            CBApi.openBase(fileUrls[0])
        }
    }

    MessageDialog {
        id: messageDialog
        title: qsTr("Base open error")
        text: qsTr("Something wrong during opening base. Would you like to open another?")
        icon: StandardIcon.Warning
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        modality: Qt.WindowModal
        onAccepted: {
            openBase()
        }
    }

    function openBase() {
        openBaseDialog.open()
    }

    function openBaseAlert() {
        messageDialog.open()
    }
}
