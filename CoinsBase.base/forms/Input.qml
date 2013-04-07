import QtQuick 1.1

FocusScope {
    id: container
    width: parent.width
    height: titleText.height+borderRect.height
    signal
    accepted
    property alias text: input.text
    property alias title: titleText.text
    Text {
        id: titleText
        text: ""
        font.pixelSize: 16
        font.bold: true
    }
    Rectangle{
        id: borderRect
        width: parent.width
        height: input.height+10
        anchors.top: titleText.bottom
        border.color: container.enabled?"black":"white"
        radius: 5
        border.width: 1

        TextEdit {
            id: input
            x:5
            y:5
            width: parent.width-10
            font.pixelSize: 16
            color: "#151515"
            //selectionColor: "mediumseagreen"
            focus: true
            text: ""
            selectByMouse: true
            wrapMode: Text.Wrap
        }
    }
}
