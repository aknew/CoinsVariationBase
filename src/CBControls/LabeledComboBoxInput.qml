import QtQuick 2.3
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4

FocusScope {
    width: parent.width
    height: textInput.height
    property alias model: valuelist.model
    property alias value: textInput.value
    property alias title: textInput.title
    property alias editing: textInput.editing
    // I use Dialog instead of ComboBox from QtQuick.Controls because ComboBox has bug - I cant type space in it.
    // https://bugreports.qt.io/browse/QTBUG-38612 Tested with Qt 5.4.0
    LabeledTextInput{
        id:textInput
        anchors.fill: parent
    }
    MouseArea{
        anchors.fill: parent
        onClicked: {
            dialog.value = textInput.value
            dialog.open()
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
                    textInput.value = comboField.text;
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
