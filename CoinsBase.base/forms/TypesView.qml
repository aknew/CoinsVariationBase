import QtQuick 2.0
import CVBControls 1.0

Rectangle {
    id: mainRect
    width: 400
    height: 500

    ListView {
        id: listView
        anchors.fill: parent
        delegate: delegate
        model: myModel
    }

    Component {
        id: delegate
        Item {
            id: recipe

            // Create a property to contain the visibility of the details.
            // We can bind multiple element's opacity to this one property,
            // rather than having a "PropertyChanges" line for each element we
            // want to fade.
            property real detailsOpacity: 0

            width: listView.width
            height: topLayout.height+topLayout.y*2

            // A simple rounded rectangle for the background
            Rectangle {
                id: background
                x: 2
                y: 2
                width: parent.width - x * 2
                height: parent.height - y * 2
                color: (index % 2) ? "lightgray" : "white"
                border.color: "gray"
                radius: 5
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    window.fullInfo(index);
                }

            }
            Column {

                id: topLayout
                x: 10
                y: 10
                width: listView.width
                StyledText{
                    mainText: nominal + " обр. " + firstYear + " - " + lastYear
                    font.bold: true
                }
                StyledText{
                    title:  qsTr("Metal: ")
                    mainText: metal
                }
                StyledText{
                    title: qsTr("Issue: ")
                    mainText: issue
                }
            }
        }
    }
}
