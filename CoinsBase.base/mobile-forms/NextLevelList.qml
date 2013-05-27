import QtQuick 1.1

Rectangle {
    width: parent.width
    height: 300
    ListView {
        clip: true
        id: listView1
        anchors.fill: parent
        delegate: nextLevelDelegate
        model: nextLevelList
    }
    Component {
        id: nextLevelDelegate
        Item {
            width: parent.width
            height: 100
            Rectangle {
                id: background2
                x: 2
                y: 2
                width: parent.width - x * 2
                height: parent.height - y * 2
                color: (index % 2) ? "lightgray" : "white"
                border.color: "gray"
                radius: 5
            }
            Text {
                id: nextLevelButton
                anchors.fill: parent
                text: modelData
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            MouseArea {
                anchors.fill: parent
                id: mouseArea
                onClicked: {
                    window.buttonPressed(index)
                }
            }
        }
    }
}
