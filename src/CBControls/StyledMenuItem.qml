import QtQuick 2.7

Item {
    height: 44
    width: label.width + label.x + 5
    property alias text: label.text
    Text {
        id: label
        height: parent.height
        anchors.left: parent.left
        anchors.leftMargin: 5
        verticalAlignment: Text.AlignVCenter
    }
}
