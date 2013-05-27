import QtQuick 1.1

Rectangle {
    id: mainRect
    width: 400
    height: 500
    ListView {
        id: listView
        clip: true
        anchors.fill:parent
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
            height: Math.max(100,description_txt.height+10)

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    window.fullInfo(index)
                }
            }

            Rectangle {
                id: background
                anchors.fill: parent
                color: (index % 2) ? "lightgray" : "white"
                border.color: "gray"
                radius: 5
                Text{
                    id: description_txt
                    width:parent.width
                    anchors.centerIn: parent
                    text:description
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                }
            }
         }
    }
}
