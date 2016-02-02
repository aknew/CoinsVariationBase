import QtQuick 2.5
import CB.api 1.0

GridView {
    model: CBSettings.recentBases
    cellHeight: 200
    cellWidth: 200
    delegate: Rectangle {
        height: 200
        width: 200
        MouseArea {
            anchors.fill: parent
            //TODO: opening base
        }
        Image {
            source: "image://baseIconProvider/" + modelData
            width: parent.width
            anchors.top: parent.top
            anchors.bottom: baseTitle.top
            anchors.bottomMargin: 5
            fillMode: Image.PreserveAspectFit
        }
        Text {
            id: baseTitle
            anchors.bottom: parent.bottom
            width: parent.width
            text: modelData
            wrapMode: Text.Wrap
        }
    }
}
