import QtQuick 2.3

FocusScope {
    width: parent.width
    height:titleLabel.height + input.height
    signal
    accepted
    property alias value: input.text
    property alias title: titleLabel.text
    enabled: false;
    property bool editing: false;
    onEditingChanged: {
        enabled = editing;
        editingBackgrouns.visible = editing;
    }
    Text {
        id: titleLabel
        text: ""
        font.pixelSize: 16
        font.bold: true
    }
    Rectangle {
        id: editingBackgrouns
        border.color: "black"
        radius: 1
        visible: false
        width: parent.width
        height: input.height
        anchors.top: titleLabel.bottom
    }
    TextEdit {
        id: input
        font.pixelSize: 16
        width: parent.width
        anchors.top: titleLabel.bottom
        wrapMode: Text.Wrap
    }
}
