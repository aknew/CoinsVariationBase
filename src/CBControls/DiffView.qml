import QtQuick 2.0

ListView {
    id: listView
    delegate: delegate
    Component {
         id: delegate;
        Item {
            id: delegateItem;
            width: listView.width;
            height: lblName.height + Math.max(lbl1.height,lbl2.height) + 15
            Text{
                id: lblName
                text: qsTr(modelData.name)+":"
                font.bold: true
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.top: parent.top
                anchors.topMargin: 5
                width: parent.width - 10
                horizontalAlignment: Text.AlignHCenter
            }
            Text{
                id: lbl1
                text: modelData.highlightedFirst
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.top: lblName.bottom
                anchors.topMargin: 5
                width: parent.width/2 - 10
                wrapMode: Text.Wrap
            }
            Text{
                id: lbl2
                text: modelData.highlightedSecond
                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.top: lblName.bottom
                anchors.topMargin: 5
                width: parent.width/2 - 10
                wrapMode: Text.Wrap
            }
        }
    }

}
