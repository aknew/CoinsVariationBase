import QtQuick 2.5
import QtQuick.Controls 2.0

FocusScope {
    width: parent.width
    height: titleLabel.height + input.height
    signal accepted
    property alias value: input.text
    property alias title: titleLabel.text
    property alias color: input.color
    property bool editing: false
    onEditingChanged: {
        input.readOnly = !editing
    }
    Label {
        id: titleLabel
        text: ""
        font.bold: true
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
    }
    TextArea {
        id: input
        anchors.top: titleLabel.bottom
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        readOnly: true
        wrapMode:TextEdit.Wrap
    }
}
