import QtQuick 2.5
import QtQuick.Controls 1.4

FocusScope {
    width: parent.width
    height: input.height
    signal accepted
    property alias value: input.text
    property alias title: titleLabel.text
    property alias color: input.textColor
    property bool editing: false
    onEditingChanged: {
        input.readOnly = !editing
    }
    Label {
        id: titleLabel
        text: ""
        //font.pixelSize: 32
        font.bold: true
        anchors.left: parent.left
        anchors.leftMargin: 5
        height: parent.height
        verticalAlignment : Text.AlignVCenter
    }
    TextField {
        id: input
        anchors.left: titleLabel.right
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        readOnly: true
    }
}
