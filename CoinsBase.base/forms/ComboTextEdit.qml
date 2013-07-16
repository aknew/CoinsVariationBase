import QtQuick 2.0

FocusScope {
    id: container
    width: 200
    height: comboBox.height+10
    property alias text: comboBox.text
    property alias model: popup.model
    Rectangle {
        border.color: container.enabled?"black":"white"
        anchors.fill: parent
        radius: 5
        border.width: 1
    }

    TextEdit {
        id: comboBox
        width: parent.width-10
        anchors.centerIn: parent
        font.pixelSize: 16
        color: "#151515"
        //selectionColor: "mediumseagreen"
        focus: true
        text: ""
        onActiveFocusChanged: container.state=activeFocus ? "dropDown" :""
        Keys.onPressed: {

        }

    }
    Rectangle{
        id: popupBack
        height: 0
        width:comboBox.width
        anchors.top: comboBox.bottom
        anchors.left: comboBox.left
        ListView{
            id:popup
            anchors.fill: parent
            clip: true
            delegate: comboBoxDelegate
        }
    }
    Component {
           id: comboBoxDelegate
           Item{
                       height: delegateText.height
                       width: parent.width
                       MouseArea{
                           anchors.fill: parent
                           onClicked: {
                               comboBox.text=delegateText.text;
                               //container.activeFocus=false;
                               container.state="";
                           }
                       }
                       Text{
                           id:delegateText
                           text:modelData
                           font.pixelSize: 16
                           color: "#151515"
                       }
                   }
    }

    states: State {
                    name: "dropDown";
                    PropertyChanges { target: popupBack; height:  Math.min(125,popup.contentHeight) }
                }

                transitions: Transition {
                    NumberAnimation { target: popupBack; properties: "height"; easing.type: Easing.OutExpo; duration: 300 }
                }
}
