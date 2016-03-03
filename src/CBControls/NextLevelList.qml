import QtQuick 2.0

Rectangle {
    width: parent.width
    height: listView1.height
    property var model
    onModelChanged: {
        listView1.model = model
    }

    ListView {
        clip: true
        id: listView1
        delegate: nextLevelDelegate
        width: parent.width
        height: Qt.platform.os == "android" ? 200 : 120
        interactive: false
    }
    Component {
        id: nextLevelDelegate
        Item {
            width: parent.width
            height: Qt.platform.os == "android" ? 100 : 40
            BackgroundRect {
            }
            Text {
                id: nextLevelButton
                anchors.fill: parent
                text: qsTr(modelData)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            MouseArea {
                anchors.fill: parent
                id: mouseArea
                onClicked: {
                    mainWindow.showListForm(modelData, node)
                }
            }
        }
    }
}
