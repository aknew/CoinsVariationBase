import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.0
import CVB.api 1.0

ApplicationWindow {
    id: mainWindow
    toolBar: ToolBar {
        id: windowToolbar
        states: State {
            name: "editable"
            PropertyChanges {
                target: toolbuttonBack
                visible: false
            }
            PropertyChanges {
                target: actionBack
                enabled: false
            }
            PropertyChanges {
                target: toolbuttonEdit
                visible: false
            }
            PropertyChanges {
                target: actionEdit
                enabled: false
            }
            PropertyChanges {
                target: toolbuttonAdd
                visible: false
            }
            PropertyChanges {
                target: actionAdd
                enabled: false
            }
            PropertyChanges {
                target: toolbuttonDelete
                visible: false
            }
            PropertyChanges {
                target: actionDelete
                enabled: false
            }
            PropertyChanges {
                target: toolbuttonSystemTables
                visible: false
            }
            PropertyChanges {
                target: systemTables
                enabled: false
            }
            PropertyChanges {
                target: toolbuttonUndo
                visible: true
            }
            PropertyChanges {
                target: actionUndo
                enabled: true
            }
            PropertyChanges {
                target: toolbuttonApply
                visible: true
            }
            PropertyChanges {
                target: actionApply
                enabled: true
            }
        }
        RowLayout {
            ToolButton {
                id: toolbuttonBack
                action: actionBack
            }
            ToolButton {
                id: toolbuttonEdit
                action: actionEdit
            }
            ToolButton {
                id: toolbuttonAdd
                action: actionAdd
            }
            ToolButton {
                id: toolbuttonDelete
                action: actionDelete
            }
            ToolButton {
                id: toolbuttonSystemTables
                action: systemTables
            }
            ToolButton {
                id: toolbuttonApply
                enabled: false
                visible: false
                action: actionApply
            }
            ToolButton {
                id: toolbuttonUndo
                enabled: false
                visible: false
                action: actionUndo
            }
        }
    }

    StackView {
        id: tablesStack
        objectName: "tablesStack"
        initialItem: Text {
            text: Qt.platform.os
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
            console.log("Accepted: " + fileUrls[0])
            CVBApi.openBase(fileUrls[0])
        }
        onRejected: {
            console.log("Rejected")
        }
    }

    function openBase() {
        openBaseDialog.open()
    }

    function createListForm() {
        var qmlString = "import QtQuick 2.0; import CVB.api 1.0; Rectangle { id: mainRect; ";
        qmlString += "ListView { id: listView; anchors.fill: parent; delegate: delegate; model: currentModel }";
        qmlString += "Component { id: delegate;";
        qmlString += "Item { id: recipe; width: listView.width; height: Math.max(100,topLayout.height+10);";
        qmlString += "Rectangle {x: 2; y: 2; width: parent.width - x * 2; height: parent.height - y * 2; color: (index % 2) ? \"lightgray\" : \"white\"; border.color: \"gray\"; radius: 5}";

        qmlString += "Column { id: topLayout; anchors.centerIn: parent; width: listView.width-10;";

        var fieldList=CVBApi.fieldsForListView();
        for (var i = 0; i < fieldList.length; ++i){

            var field=fieldList[i];
            qmlString +="Text { text: \"<b>\"+";
            qmlString += "\""+field+"\"";
            qmlString +="+\":</b>\"+";
            qmlString +=field+";";

            qmlString +=" width: parent.width; wrapMode: Text.Wrap; visible: text.length > 0;}";
        }

        qmlString += "}" //Column {
        qmlString += "}" //Item {
        qmlString += "}" //Component {
        qmlString += "}" // mainRect
        console.log(qmlString)
        var listForm = Qt.createQmlObject(qmlString, tablesStack, "dynamicList")
        tablesStack.push(listForm)
    }

    function createFullInfoForm() {
        var fullInfoForm = Qt.createQmlObject(
                    'import QtQuick 2.0; Rectangle {color: "blue"; width: 20; height: 20}',
                    tablesStack, "dynamicFullInfoForm")
        tablesStack.push(fullInfoForm)
    }

    //FIXME this file should contain all work with gui, calling CVBApi occurs because I deside don't mix migration to
    // QtQuick.Controls and refactoring in one stage
    Action {
        id: actionBack
        iconName: "back"
        iconSource: "/icons/back.png"
        text: "back"
        onTriggered: CVBApi.buttonPressed(-1)
        shortcut: "Ctrl+B"
    }
    Action {
        id: actionEdit
        iconSource: "/icons/edit.png"
        text: "edit"
        onTriggered: {
            windowToolbar.state = "editable"
            CVBApi.buttonPressed(-6)
        }
    }
    Action {
        id: actionAdd
        iconName: "add"
        iconSource: "/icons/add.png"
        text: "add"
        onTriggered: {
            windowToolbar.state = "editable"
            CVBApi.buttonPressed(-2)
        }
    }
    Action {
        id: actionDelete
        iconSource: "/icons/delete.png"
        text: "delete"
        onTriggered: CVBApi.buttonPressed(-3)
    }
    Action {
        id: systemTables
        iconSource: "/icons/Database.png"
        text: "systemTables"
        //onTriggered: CVBApi.buttonPressed(-1);
    }
    Action {
        id: actionApply
        iconSource: "/icons/apply.png"
        text: "apply"
        onTriggered: {
            windowToolbar.state = ""
            CVBApi.buttonPressed(-4)
        }
    }
    Action {
        id: actionUndo
        iconSource: "/icons/undo.png"
        text: "undo"
        onTriggered: {
            windowToolbar.state = ""
            CVBApi.buttonPressed(-5)
        }
    }
}