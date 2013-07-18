import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.0
import CVB.api 1.0

ApplicationWindow {
    id:mainRectWindow
    toolBar: ToolBar {
        RowLayout {
            ToolButton {
                action:actionBack
            }
            ToolButton {
                action: actionEdit;
            }
            ToolButton {
                action: actionAdd
            }
            ToolButton {
                action: actionDelete
            }
            ToolButton {
                action: systemTables
            }
        }
    }

    StackView{
        id: tablesStack;
        objectName: "tablesStack"
        initialItem:
            Text{
            text:Qt.platform.os
        }
    }

    FileDialog {
        id: openBaseDialog
        modality: Qt.WindowModal
        title: "Choose a base's folder"
        selectExisting: true
        selectMultiple: false
        selectFolder: true
        onAccepted: {
            console.log("Accepted: " + fileUrls[0]);
            CVBApi.openBase(fileUrls[0]);
        }
        onRejected: { console.log("Rejected") }
    }

    function openBase(){
        openBaseDialog.open();
    }
/*
       enum kButtonI{
           backButtonIndex=-1,
           newButtonIndex=-2,
           deleteButtonIndex=-3,
           applyButtonIndex=-4,
           undoButtonIndex=-5,
           editButtonIndex=-6
       };
  */
    Action {
        id: actionBack
        iconName: "back"
        iconSource: "/icons/back.png";
        text: "back";
        onTriggered: CVBApi.buttonPressed(-1);
    }
    Action {
        id: actionEdit
        iconSource: "/icons/edit.png";
        text: "edit";
        onTriggered: CVBApi.buttonPressed(-6);
    }
    Action {
        id: actionAdd
        iconName: "add"
        iconSource: "/icons/add.png";
        text: "add";
        onTriggered: CVBApi.buttonPressed(-2);
    }
    Action {
        id: actionDelete
        iconSource: "/icons/delete.png";
        text: "delete";
        onTriggered: CVBApi.buttonPressed(-3);
    }
    Action {
        id: systemTables
        iconSource: "/icons/Database.png";
        text: "systemTables";
        //onTriggered: CVBApi.buttonPressed(-1);
    }

}
