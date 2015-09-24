import QtQuick 2.2

Rectangle {
    x: 2
    y: 2
    width: parent.width - x * 2
    height: parent.height - y * 2
    color: (index % 2) ? "lightgray" : "white"
    border.color: "gray"
    radius: 5
}
