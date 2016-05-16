import QtQuick 2.5
import QtQuick.Controls 1.4

Rectangle{

    property var itemDifference;
    onItemDifferenceChanged: {
        if (typeof(itemDifference) != "undefined"){
            listView.model = itemDifference.diffFieldsModel
            image1.source="image://imageProvider/" + itemDifference.id1 + "/Main.jpg"
            image2.source="image://imageProvider/" + itemDifference.id2 + "/Main.jpg"
        }
    }

    Image {
        id: image1
        width: parent.width/2 -15
        height: width/2
        fillMode: Image.PreserveAspectFit
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.top: parent.top
        anchors.topMargin: 5
    }
    Image {
        id: image2
        width: parent.width/2 -15
        height: width/2
        fillMode: Image.PreserveAspectFit
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.top: parent.top
        anchors.topMargin: 5
    }
    ComboBox {
        id: diffMode
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.top: image1.bottom
        anchors.topMargin: 5
        model: [qsTr("Show different fields"),qsTr("Show all fields")]
        onCurrentIndexChanged: {
            if (typeof(itemDifference) == "undefined"){
                return;
            }
            if(currentIndex == 0){
                listView.model =  itemDifference.diffFieldsModel
            }
            else{
                listView.model = itemDifference.allFieldsModel
            }
        }
    }

    ListView {
        id: listView
        clip: true
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.top: diffMode.bottom
        anchors.topMargin: 5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        delegate: delegate
        Component {
             id: delegate;
            Item {
                id: delegateItem;
                width: listView.width;
                height: rectName.height + Math.max(lbl1.height,lbl2.height) + 15
                Rectangle{
                    id: rectName
                    color: "lightgray"
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.right: parent.right
                    height: lblName.height + 10
                    Text{
                        id: lblName
                        text: qsTr(modelData.name)+":"
                        font.bold: true
                        anchors.centerIn: parent
                    }
                }
                Text{
                    id: lbl1
                    text: modelData.highlightedFirst
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.top: rectName.bottom
                    anchors.topMargin: 5
                    width: parent.width/2 - 10
                    wrapMode: Text.Wrap
                }
                Text{
                    id: lbl2
                    text: modelData.highlightedSecond
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.top: rectName.bottom
                    anchors.topMargin: 5
                    width: parent.width/2 - 10
                    wrapMode: Text.Wrap
                }
            }
        }

    }
}


