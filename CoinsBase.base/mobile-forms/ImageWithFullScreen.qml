import QtQuick 1.1

Image {
    id: img
    width: Math.min(parent.width, 600)
    height: img.width / 2.0
    fillMode: Image.PreserveAspectFit
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            console.log("image clicked")
            if (mouse.button === Qt.RightButton) {
                console.log("right button")
                window.rightClickWithString(pict,mouse.x+img.x,mouse.y+img.y);
            }
            else
                window.showFullScreenImage(img.source);
        }
    }
}
