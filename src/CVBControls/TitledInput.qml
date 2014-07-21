import QtQuick 2.0

FocusScope {
    id: container
    width: parent.width
    height: input.height
    property alias model: input.model
    property alias value: input.text
    property alias title: titleText.text
    property alias editing: container.enabled
    Text {
        id: titleText
        text: ""
        font.pixelSize: 16
        font.bold: true
    }
    ComboBox{
        id: input
        width: parent.width-titleText.width
        anchors.left: titleText.right
        text: ""
    }
}
