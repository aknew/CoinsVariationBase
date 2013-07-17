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
                iconName: "back"
                iconSource: "/icons/back.png";
                text: "back";
            }
            ToolButton {
                iconSource: "/icons/edit.png";
                text: "edit";
            }
            ToolButton {
                iconName: "add"
                iconSource: "/icons/add.png";
                text: "add";
            }
            ToolButton {
                iconSource: "/icons/delete.png";
                text: "delete";
            }
            ToolButton {
                iconSource: "/icons/Database.png";
                text: "systemTables";
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
}
