import QtQuick 1.1

FocusScope {
    id: container
    width: parent.width
    height: input.height+titleText.height
    signal
    accepted
    property alias text: input.text
    property alias item: input //???
    property alias title: titleText.text
    Text {
        id: titleText
        text: ""
        font.pixelSize: 16
        font.bold: true
    }
    Text {
        id: input
        width: parent.width
        anchors.top: titleText.bottom
        font.pixelSize: 16
        color: "#151515"
        //selectionColor: "mediumseagreen"
        focus: true
        //onAccepted:{container.accepted()}
        text: ""
        //selectByMouse: true
        wrapMode: Text.Wrap
    }
}
