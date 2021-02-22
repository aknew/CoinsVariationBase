import QtQuick 2.5
import Qt.labs.platform 1.1
import QtQuick.Controls

FocusScope {
    id: container
    width: parent.width
    height: textInput.height
    property alias value: textInput.value
    property alias title: textInput.title
    property bool editing: false
    onEditingChanged: {
        textInput.editing = editing
        mouseArea.enabled = editing
    }
    LabeledTextInput {
        id: textInput
        anchors.fill: parent
        editing: false
        MouseArea{
            id:mouseArea
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 5
            height: parent.height
            width: parent.height
            onClicked: {
                var timestamp = Date.parse(textInput.value)
                var d = new Date()
                if (isNaN(timestamp) === false) {
                    d = new Date(timestamp)
                }

                dialog.selectedDate = d
                dialog.open()
            }
            Text{
                visible: editing
                text: "📅"
                anchors.centerIn: parent
                height: parent.height/2
                width: parent.width/2
            }
        }
    }

    Popup {
        id: dialog
        title: qsTr("Select date: ")
        property alias selectedDate: calendar.selectedDate

        contentItem: Calendar {
            id: calendar
            onDoubleClicked: {
                textInput.value = Qt.formatDate(date, "yyyy-MM-dd")
                dialog.close()
            }
        }
    }
}
