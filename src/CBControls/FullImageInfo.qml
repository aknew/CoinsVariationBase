import QtQuick 2.3
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

import CBControls 1.0
import CB.api 1.0

Flickable {
    id: imageInfoRect
    clip: true
    property var imageInfo
    property var formType: CBApi.ImageFullForm
    property bool editing: false
    // FIXME: to const
    property string idToDelete: "NothingToDelete"
    onImageInfoChanged: {
        image.source = "image://imageProvider/" + imageInfo.id
        sourceLabel.value = imageInfo.source
        commentLabel.value = imageInfo.comment
    }
    function applyContentHeight() {
        contentHeight = commentLabel.height + commentLabel.y
    }

    Image {
        id: image
        fillMode: Image.PreserveAspectFit
        width: parent.width
        MouseArea{
            anchors.fill:parent
            acceptedButtons: Qt.RightButton
            onClicked: {
                imageMenu.popup()
            }
        }
    }
    LabeledTextInput {
        id: sourceLabel
        editing: false
        anchors.top: image.bottom
        title: qsTr("source")
    }
    LabeledTextInput {
        id: commentLabel
        editing: false
        anchors.top: sourceLabel.bottom
        title: qsTr("comment")
    }

    states: State { name: "editing";
        PropertyChanges { target:sourceLabel;editing:true }
        PropertyChanges { target:commentLabel;editing:true }
        PropertyChanges { target: imageInfoRect; editing: true}
    }

    function collectData() {
        var returnedMap = {
            id: imageInfo.id,
            source: sourceLabel.value,
            comment: commentLabel.value,
            ParentID: imageInfo.ParentID,
            idToDelete: imageInfoRect.idToDelete
        };
        CBApi.baseProvider.saveImageInfo(returnedMap);
    }

    Menu{
        id: imageMenu
        MenuItem{
            text: qsTr("Save image")
            onTriggered: fileDialog.open()
        }
        MenuItem{
            text: qsTr("Copy image to clipboard")
            onTriggered: {
                CBApi.baseProvider.copyImageToClipboard(imageInfo.id)
            }
        }
        MenuItem{
            text: qsTr("Load image")
            visible: imageInfoRect.editing
            onTriggered:  fileDialog.open()
        }
        MenuItem{
            text: qsTr("Insert image from clipboard")
            visible: imageInfoRect.editing
            onTriggered: {
                var newID = CBApi.baseProvider.importImageFromClipboard();
                reloadImage(newID);
            }
        }
    }

    FileDialog {
        id: fileDialog
        modality: Qt.WindowModal
        title: editing ? qsTr("Choose an image to load") : qsTr("Choose where to save")
        selectExisting: editing
        selectMultiple: false
        onAccepted: {
            if (editing){
                var newID = CBApi.baseProvider.loadImage(fileUrls[0]);
                reloadImage(newID);
            }
            else{
                CBApi.baseProvider.saveImage(imageInfo.id,fileUrls[0])
            }
        }
    }

    function reloadImage(newID){
        // FIXME: to const
        if (newID === "*error*"){
            return;
        }

        idToDelete = imageInfo.id;

        var returnedMap = {
            id: newID,
            source: sourceLabel.value,
            comment: commentLabel.value,
            ParentID: imageInfo.ParentID
        };

        imageInfoRect.imageInfo = returnedMap;
    }
}
