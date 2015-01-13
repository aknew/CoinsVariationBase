import QtQuick 2.3
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.3

FocusScope {
    id: container
    width: parent.width
    height: titleText.height+borderRect.height
    property alias model: valuelist.model
    property alias value: input.text
    property alias title: titleText.text
    property alias editing: container.enabled
    Text {
        id: titleText
        text: ""
        font.pixelSize: 16
        font.bold: true
    }
    // I use Dialog instead of ComboBox from QtQuick.Controls because ComboBox has bug - I cant type space in it.
    // https://bugreports.qt.io/browse/QTBUG-38612 Tested with Qt 5.4.0
    Rectangle{
        id: borderRect
        width: parent.width
        height: input.height+10
        anchors.top: titleText.bottom
        border.color: container.enabled?"black":"white"
        radius: 5
        border.width: 1
        Text{
            id: input
            x:5
            y:5
            width: parent.width-10
            font.pixelSize: 16
            color: "#151515"
            text: ""
            wrapMode: Text.Wrap
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                console.log("will open dialog")
                dialog.value = input.text
                dialog.open()
            }
        }
    }
    Dialog {
        id: dialog
        title: qsTr("Select value for field: ")+ container.title;
        property alias value: comboField.text

        contentItem: Rectangle {
            implicitWidth: 400
            implicitHeight: 500
            TextField {
                id: comboField
                width: parent.width - x * 2
                x: 5
                y: 5
            }
            ListView {
                id: valuelist
                clip: true
                width: parent.width - x * 2
                x: 5
                anchors.top: comboField.bottom
                height: parent.height - comboField.height -50
                delegate: Rectangle{
                    width: parent.width
                    height:40
                    Text{
                        id:delegateText
                        text:modelData
                        anchors.fill: parent
                    }
                    MouseArea{
                            anchors.fill: parent
                            onClicked: comboField.text = delegateText.text;
                    }
                }
            }
            Button{
                id: btnApply
                width: parent.width/2 - x * 2
                x: 5
                y: parent.height -45
                height:40
                text: qsTr("Apply")
                onClicked:{
                    input.text = comboField.text;
                    dialog.close();
                }
            }
            Button{
                width: parent.width/2 - 5 * 2
                x: btnApply.x*2 + btnApply.width
                y: parent.height -45
                height:40
                text: qsTr("Cancel")
                onClicked:{
                    dialog.close();
                }
            }
        }
    }
}
