import QtQuick 2.2

Rectangle {
    property bool selected: false
    anchors.fill: parent
    color: selected ? "aqua" : ((index % 2) ? "lightgray" : "white")
    border.color: "gray"
    radius: 1
}
