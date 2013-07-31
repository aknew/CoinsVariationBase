import QtQuick 2.1
import QtQuick.Dialogs 1.0
import QtQuick.Controls 1.0
import CVB.api 1.0

Image {

    FileDialog {
        id: openImageDialog
        modality: Qt.WindowModal
        title: "Choose an image"
        selectExisting: true
        onAccepted: {
            console.log("Accepted: " + fileUrls[0])
            var newID = CVBApi.loadNewImage(fileUrls[0])
            if (newID !== "-1") {
                console.log("new image load - SUCCESS")
                img.pict = newID
            }
        }
        onRejected: {
            console.log("Rejected")
        }
    }

    Menu {
        id: insertMenu
        title: "InsertMenu"

        MenuItem {
            text: "Open"
            shortcut: "Ctrl+O"
            onTriggered: {
                openImageDialog.open();
            }
        }

        MenuItem {
            text: "Paste"
            shortcut: "Ctrl+V"
            onTriggered: {
                var newID = CVBApi.loadNewImage(null)
                if (newID !== "-1") {
                    console.log("new image paste - SUCCESS")
                    img.pict = newID
                }
            }
        }
    }

    property string pict: ""
    property bool editing: false //чтобы не дать переходить в полноэкранный режим при редактировании
    id: img
    width: Math.min(parent.width, 600)
    height: img.width / 2.0
    fillMode: Image.PreserveAspectFit
    source: "image://imageProvider/" + pict
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
                         | Qt.RightButton //editing?Qt.RightButton:Qt.LeftButton | Qt.RightButton
        onClicked: {
            console.log("image clicked")
            if (editing) {
                var newID
                if (mouse.button === Qt.RightButton) {
                    insertMenu.popup()
                } else {
                    openImageDialog.open();
                }
            } else {
                if (mouse.button === Qt.RightButton) {
                    window.imageRightClick(pict, mouse.x + img.x,
                                           mouse.y + img.y, editing)
                } else
                    window.showFullScreenImage(img.source)
            }
        }
    }
}
