import QtQuick 2.5
import QtQuick.Controls

FocusScope {
    id: container
    width: parent.width
    height: input.height
    property alias model: input.model

    function getValue(){
        return input.editText
    }
    function setValue(val){
        var index = model.indexOf(val)
        // HOTFIX: val==="" was added because ComboBox actually don't want to set "" as curretnText from code
        // I also create a bug in their bugtracker https://bugreports.qt.io/browse/QTBUG-51698
        if (index === -1 || val === ""){
            input.editText = val
        }
        else{
            input.currentIndex = index
        }
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
        color: "black"
        anchors.left: parent.left
        anchors.leftMargin: 5
        height: parent.height
        verticalAlignment : Text.AlignVCenter
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
