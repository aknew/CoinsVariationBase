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
    onImageInfoChanged: {
        image.source = "image://imageProvider/" + imageInfo.id
        sourceLabel.value = imageInfo.source
        commentLabel.value = imageInfo.comment
    }
    function applyContentHeight() {
        console.log(image.height)
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

    function currentImageID(){
        return image.source.toString().split('/').pop();
    }

    function collectData() {
        var returnedMap = {
            id: currentImageID(),
            source: sourceLabel.value,
            comment: commentLabel.value,
            ParentID: imageInfo.ParentID
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
                CBApi.baseProvider.copyImageToClipboard(currentImageID())
            }
        }
        MenuItem{
            text: qsTr("Load image")
            visible: imageInfoRect.editing
            onTriggered: {

            }
        }
        MenuItem{
            text: qsTr("Insert image from clipboard")
            visible: imageInfoRect.editing
            onTriggered: {

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

            }
            else{
                CBApi.baseProvider.saveImage(imageInfo.id,fileUrls[0])
            }
        }
    }

}
