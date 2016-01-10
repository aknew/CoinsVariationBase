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

    ListModel {
        id: listModel
    }

    ListView {
        id: attachmentsInfoListView
        clip: true
        width: parent.width
        height: parent.height - 100
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
}
