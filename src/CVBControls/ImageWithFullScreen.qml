import QtQuick 2.1
import QtQuick.Dialogs 1.0
import QtQuick.Controls 1.0
import CVB.api 1.0

Image {

    FileDialog {
        id: imageDialog
        property bool isOpenDialog: true;
        modality: Qt.WindowModal
        title: isOpenDialog?"Choose an image":"Where to save"
        selectExisting: isOpenDialog
        onAccepted: {
            console.log("Accepted: " + fileUrls[0])
            if (!isOpenDialog){
                CVBApi.saveImage(img.pict,fileUrls[0]);
                return;
            }

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
            onTriggered: {
                imageDialog.isOpenDialog = true;
                imageDialog.open();
            }
        }

        MenuItem {
            text: "Paste"
            onTriggered: {
                var newID = CVBApi.loadNewImage(null)
                if (newID !== "-1") {
                    console.log("new image paste - SUCCESS")
                    img.pict = newID
                }
            }
        }
    }

    Menu {
        id: saveMenu
        title: "saveMenu"

        MenuItem {
            text: "Save to file"
            onTriggered: {
                imageDialog.isOpenDialog = false;
                imageDialog.open();
            }
        }

        MenuItem {
            text: "Copy to clipboard"
            onTriggered: {
                CVBApi.saveImage(img.pict,null)
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
                    imageDialog.isOpenDialog = true;
                    imageDialog.open();
                }
            } else {
                if (mouse.button === Qt.RightButton) {
                    saveMenu.popup()
                } else
                    window.showFullScreenImage(img.source)
            }
        }
    }
}
