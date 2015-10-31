import QtQuick 2.0
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
        var imID = image.source.toString().split('/').pop();
        var returnedMap = {
            id: imID,
            source: sourceLabel.value,
            comment: commentLabel.value,
            ParentID: imageInfo.ParentID
        };
        CBApi.baseProvider.saveImageInfo(returnedMap);
    }
}
