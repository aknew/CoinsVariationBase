import QtQuick 2.0

FocusScope {
    id: container
    height: input.height+10
    property alias text: input.text
    property alias maximumLength: input.maximumLength
    Rectangle {
        border.color: container.enabled?"black":"white"
        anchors.fill: parent
        radius: 5
        border.width: 1
    }

    TextInput {
        id: input
        width: parent.width-10
        anchors.centerIn: parent
        font.pixelSize: 16
        color: "#151515"
        //selectionColor: "mediumseagreen"
        focus: true
        text: ""
        horizontalAlignment: Text.AlignHCenter
    }
}
