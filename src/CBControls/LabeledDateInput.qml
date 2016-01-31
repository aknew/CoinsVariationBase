import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4

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
    }
    MouseArea {
        id: mouseArea
        enabled: false
        anchors.fill: parent
        onClicked: {

            var timestamp = Date.parse(textInput.value)
            var d = new Date()
            if (isNaN(timestamp) === false) {
                d = new Date(timestamp)
            }

            dialog.selectedDate = d
            dialog.open()
        }
    }

    Dialog {
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
