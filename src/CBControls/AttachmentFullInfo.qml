import QtQuick 2.3
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

import CB.api 1.0

Rectangle {

    id: attachmentRootRect

    property bool editing: false
    states: State { name: "editing";
        PropertyChanges { target:attachmentRootRect;editing:true }
    }

    property var attachmentInfo

    onAttachmentInfoChanged: {
        for (var name in attachmentInfo) {
            addInfoField(name,attachmentInfo[name])
        }
    }

    function addInfoField(name, value) {
        var val ={'name':name,'value':value}
        listModel.append(val)
    }

    function cnangeInfoField(name, value, index) {
        var val ={'name':name,'value':value}
        listModel.set(index, val)
    }

    ListModel {
        id: listModel
    }

    ListView {
        id: attachmentsInfoListView
        clip: true
        width: parent.width
        height: editing?parent.height-bottomBar.height:parent.height
        model: listModel
        delegate: Rectangle{
            width: parent.width
            height: Math.max(rowText.height,btnEdit.height)
            Text {
                id: rowText
                text: "<b>" + name + ":</b> " + value
                anchors.left:parent.left
                anchors.right: editing?btnEdit.left:parent.right
                wrapMode: Text.Wrap
            }
            Button{
                id: btnEdit
                iconSource: "/icons/edit.png"
                visible: editing
                anchors.right: btnRemove.left
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    editRowDialog.index = index;
                    editRowDialog.name = name;
                    editRowDialog.value = value;
                    editRowDialog.open();
                }
            }
            Button{
                id:btnRemove
                iconSource: "/icons/delete.png"
                visible: editing
                anchors.right: parent.right
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    deleteRowDialog.index = index;
                    deleteRowDialog.open()
                }
            }
        }
    }

    Rectangle{
        id: bottomBar
        visible:editing
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 100
        Button{
            id: btnAddField
            iconSource: "/icons/add.png"
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top:parent.top
            anchors.topMargin: 5
            height:parent.height - 10
            width: parent.height - 10
            onClicked:{
                editRowDialog.index = -1;
                editRowDialog.name = "";
                editRowDialog.value = "";
                editRowDialog.open();
            }
        }
    }

    MessageDialog {
        id: deleteRowDialog
        text: qsTr("Do you realy want to delete this field?")
        icon: StandardIcon.Warning
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        property int index: -1
        modality: Qt.WindowModal
        onAccepted: {
           listModel.remove(index)
        }
    }

    Dialog {
        id: editRowDialog
        title: qsTr("Select value for field: ");
        property int index:-1
        property alias name:edtName.value
        property alias value:edtValue.value

        contentItem: Rectangle {
            implicitWidth: 400
            implicitHeight: 500
            LabeledTextInput{
                id:edtName
                title: qsTr("name")
                editing: true
            }
            LabeledTextInput{
                id:edtValue
                title:qsTr("value")
                editing: true
                anchors.topMargin: 5
                anchors.top: edtName.bottom
            }

            Button{
                id: btnApply
                width: (parent.width-15)/2
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.top:edtValue.bottom
                anchors.topMargin: 5
                height:40
                text: qsTr("Apply")
                onClicked:{
                    if (editRowDialog.index === -1){
                        addInfoField(edtName.value,edtValue.value)
                    }
                    else{
                        cnangeInfoField(edtName.value,edtValue.value, editRowDialog.index)
                    }

                    editRowDialog.close();
                }
            }
            Button{
                width: (parent.width-15)/2
                anchors.left: btnApply.right
                anchors.leftMargin: 5
                anchors.top:edtValue.bottom
                anchors.topMargin: 5
                height:40
                text: qsTr("Cancel")
                onClicked:{
                    editRowDialog.close();
                }
            }
        }
    }
}
