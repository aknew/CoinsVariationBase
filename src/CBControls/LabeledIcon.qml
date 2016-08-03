import QtQuick 2.7

Item {
    height: 50
    width: label.width+label.x+5
    property alias iconSource:image.source
    property alias text: label.text
    Image{
        id: image
        height: parent.height
        width:  parent.height
        anchors.left: parent.left
        anchors.leftMargin: 5
        fillMode: Image.Pad
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter
    }
    Text{
        id:label
        height: parent.height
        anchors.left: image.right
        anchors.leftMargin: 10
        verticalAlignment: Text.AlignVCenter
    }
}
