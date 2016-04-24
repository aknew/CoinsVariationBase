import QtQuick 2.5
import "." // QTBUG-34418, singletons require explicit import to load qmldir file


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
        height: Math.min(contentHeight, GUIStyle.isMobile ? 200 : 120) // i.e. nextLevelDelegate.height *3
        interactive: false
    }
    Component {
        id: nextLevelDelegate
        Item {
            width: parent.width
            height: GUIStyle.isMobile ? 100 : 40
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
