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
    property bool linkable: false
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
        MouseArea{
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            height: parent.height
            width: parent.height
            visible: linkable
            onClicked: {
                Qt.openUrlExternally(input.text)
            }
            Image{
                source: "/right"
                anchors.centerIn: parent
                height: parent.height/2
                width: parent.width/2
            }
        }
    }
}
