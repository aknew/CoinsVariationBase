import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.0

import CB.api 1.0
import "."

// QTBUG-34418, singletons require explicit import to load qmldir file
GridView {
    property int formType: CBApi.OpenBaseForm
    model: CBSettings.recentBases
    id: root
    // TODO: check on tablet
    cellHeight: GUIStyle.isMobile ? width / 2 : width / 4
    cellWidth: GUIStyle.isMobile ? width / 2 : width / 4
    delegate: Rectangle {
        color: "transparent"
        height: GUIStyle.isMobile ? root.width / 2 : root.width / 4
        width: GUIStyle.isMobile ? root.width / 2 : root.width / 4
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: {
                if (mouse.button === Qt.RightButton) {
                    baseMenu.file = modelData
                    baseMenu.open()
                } else {
                    //TODO: need use some constants instead string
                    if (modelData === qsTr("Open new base")) {
                        openBase()
                    } else {
                        CBApi.openRecentBase(modelData)
                    }
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
            sourceSize.height: height
            sourceSize.width: width
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
        folder: CBSettings.defaultPath
        onAccepted: {
            CBApi.openBase(fileUrls[0])
        }
    }

    function openBase() {
        openBaseDialog.open()
    }

    Menu {
        id: baseMenu
        property string file: ""
        MenuItem {
            text: qsTr("Remove base from recent")
            onTriggered: {
                // I don't ask user is he sure because is action just remove link to base, but not data from disk
                CBSettings.removeRecentWithName(baseMenu.file)
            }
        }
    }
}
