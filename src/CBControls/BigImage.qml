import QtQuick 2.2

Image {
    id: bigImage
    anchors.fill: parent
    source: imgSource
    fillMode: Image.PreserveAspectFit
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            console.log("image clicked")
            if (mouse.button === Qt.RightButton) {
                console.log("right button")
                //window.rightClickWithString(pict,mouse.x,mouse.y);
            }
            else
                window.buttonPressed(-1);
        }
    }
}
