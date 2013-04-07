import QtQuick 1.1

Image {
    property string pict: ""
    property bool editing: false //чтобы не дать переходить в полноэкранный режим при редактировании
    id: img
    width: Math.min(parent.width, 600)
    height: img.width / 2.0
    fillMode: Image.PreserveAspectFit
    source: "image://imageProvider/" + pict
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton //editing?Qt.RightButton:Qt.LeftButton | Qt.RightButton
        onClicked: {
            console.log("image clicked")
            if (editing){
                var newID;
                if (mouse.button === Qt.RightButton) {
                    newID=window.imageRightClick(pict,mouse.x+img.x,mouse.y+img.y,editing);
                }
                else
                    newID=window.loadNewImage();
                console.log(newID);
                if (newID!=="-1"){
                    console.log("new image load - SUCCESS");
                    img.pict=newID;
                }
            }
            else{
                if (mouse.button === Qt.RightButton) {
                    window.imageRightClick(pict,mouse.x+img.x,mouse.y+img.y,editing);
                }
                else
                    window.showFullScreenImage(img.source);
            }
        }
    }
}
