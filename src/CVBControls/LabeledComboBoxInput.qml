import QtQuick 2.0
import QtQuick.Controls 1.2

FocusScope {
    id: container
    width: parent.width
    height: input.height
    property alias model: input.model
    property alias value: input.editText
    property alias title: titleText.text
    property alias editing: container.enabled
    Text {
        id: titleText
        text: ""
        font.pixelSize: 16
        font.bold: true
    }
    ComboBox{
        id: input
        width: parent.width-titleText.width
        anchors.left: titleText.right
        editable: true
        onAccepted: {
            if (find(currentText) === -1) {
                model.append({text: editText})
                currentIndex = find(editText)
            }
        }
    }
}
