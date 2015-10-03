import QtQuick 2.0
import CBControls 1.0





    Flickable{
        clip: true;
        property var imageInfo;
        onImageInfoChanged: {
            image.source="image://imageProvider/"+imageInfo.id;
            sourceLabel.value = imageInfo.source;
            commentLabel.value = imageInfo.comment;
        }
        Image{
            id: image
            fillMode: Image.PreserveAspectFit
            width:parent.width
        }
        LabeledTextInput{
            id:sourceLabel
            anchors.top:image.bottom
            title:qsTr("source")
        }
        LabeledTextInput{
            id:commentLabel
            anchors.top:sourceLabel.bottom
            title:qsTr("comment")
        }
    }



