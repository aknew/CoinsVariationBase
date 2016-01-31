import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4

FocusScope {
    id: container
    width: parent.width
    height: input.height
    property alias model: input.model
    function getValue(){
        return input.editText
    }
    function setValue(val){
        input.currentIndex = model.indexOf(val)
    }
    property alias title: titleLabel.text
    //property alias color: input.
    property bool editing: false
    onEditingChanged: {
        input.enabled = editing
    }
    Label {
        id: titleLabel
        text: ""
        //font.pixelSize: 32
        font.bold: true
        anchors.left: parent.left
        anchors.leftMargin: 5
    }
    ComboBox {
        id: input
        anchors.left: titleLabel.right
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        editable: true
        enabled: false
        //readOnly: true
    }
}
