import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2

import CB.api 1.0
import "FormCreator.js" as FormCreator


ApplicationWindow {
    id: mainWindow
    title: "Open base"

    height:500;
    width:1000;

    menuBar:MenuBar{
        Menu {
                    title: "File"
                    MenuItem {
                        text: "Open..."
                        onTriggered: openBase();
                    }
                    MenuItem { text: "Recent" }
                }
    }

    toolBar: ToolBar {
        id: windowToolbar
        Row {
            id:defaultLayout
            MouseArea{
                Image {
                    source: "/icons/back.png"
                    anchors.fill: parent
                }
                height:25
                width:25
                onClicked:{
                    if (tablesStack.depth>2){
                        tablesStack.pop();
                    }
                }
                onPressAndHold: {
                    // TODO: show dialog all shown tables and pop to clicked
                    console.log("catch long tap")
                }
            }
            ToolButton {
                id: toolbuttonEdit
                action: actionEdit
                //visible:false
            }
        }
    }

    property bool needCollect: false;

    StackView {
        id: tablesStack
        anchors.fill: parent
        objectName: "tablesStack"
        initialItem: Text {
            text: "Running on: " + Qt.platform.os + "\n" +
                  "Open some base to start work";
        }
    }

    function providerReadyToWork(){
        tablesStack.pop(tablesStack.initialItem);
        title = CBApi.baseProvider.baseTitle;
        var node = CBApi.baseProvider.getStartNode();
        var listForm = FormCreator.createListForm(node);
        tablesStack.push(listForm);
    }

    function showFullForm(node, index){

        node.selectItemWithIndex(index);
        var fullForm = FormCreator.createFullForm(node);
        tablesStack.push(fullForm);
    }

    function showListForm(nodeName, currentNode){
        var node = CBApi.baseProvider.getNode(nodeName, currentNode);
        var listForm = FormCreator.createListForm(node);
        tablesStack.push(listForm);
    }

    // Dialogs

    FileDialog {
        id: openBaseDialog
        modality: Qt.WindowModal
        title: qsTr("Choose a base's folder")
        selectExisting: true
        selectMultiple: false
        selectFolder: true
        onAccepted: {
            CBApi.openBase(fileUrls[0])
        }
    }

    MessageDialog {
        id: messageDialog
        title: qsTr("Base open error")
        text: qsTr("Something wrong during opening base. Would you like to open another?")
        icon: StandardIcon.Warning
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        modality: Qt.WindowModal
        onAccepted: {
            openBase();
        }
    }

    function openBase() {
        openBaseDialog.open()
    }

    function openBaseAlert(){
        messageDialog.open();
    }

    Action {
        id: actionEdit
        iconSource: "/icons/edit.png"
        text: "edit"
        onTriggered: {
            //windowToolbar.state = "editing"
            tablesStack.currentItem.state = "editing"
        }
    }
}

