import QtQuick 2.0
import CVB.api 1.0

Rectangle {
    width: parent.width
    height: listView1.height
    ListView {
        clip: true
        id: listView1
        delegate: nextLevelDelegate
        model: CVBApi.nextLevelList()
        width: parent.width
        height: 120//nextLevelList.count*40 //FIXME костыль, но без этого при попыткезадействовать contentHeight  получается binding loop и ничего невыводит
        interactive:false
    }
    Component {
        id: nextLevelDelegate
        Item {
            width: parent.width
            height: 40
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
                    CVBApi.buttonPressed(index)
                }
            }
        }
    }
}
