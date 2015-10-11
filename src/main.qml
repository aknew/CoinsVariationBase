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
                    id: fileMenu;
                    title: "File"
                    MenuItem {
                        text: "Open..."
                        onTriggered: openBase();
                    }
                    MenuSeparator{}
                }
        Menu {
                    title: "Filters"
                    visible: tablesStack.currentItem.formType === CBApi.ListForm;
                    MenuItem {
                        text: "Set filters"
                        onTriggered: {
                            var component = Qt.createComponent("CBControls/FilterDialog.qml")
                            if (component.status === Component.Ready) {
                                var form = component.createObject();
                                form.node = tablesStack.currentItem.node;
                                tablesStack.push(form);
                            }
                        }
                    }
                    MenuItem {
                        text: "Drop filters"
                        onTriggered: {
                            tablesStack.currentItem.node.dropFilter();
                        }
                    }
                }
        Menu{
            title: "Change data"
            visible: tablesStack.currentItem.formType !== CBApi.FilterDialog;
            MenuItem{
                text: "Edit record"
                visible: tablesStack.currentItem.formType !== CBApi.ListForm;
                iconSource: "/icons/edit.png"
                onTriggered: {
                    windowToolbar.state = "editing"
                    tablesStack.currentItem.state = "editing"
                }
            }
            MenuItem{
                text: "Add new"
            }
            MenuItem{
                text: "Delete"
                visible: tablesStack.currentItem.formType !== CBApi.ListForm;
                onTriggered: {
                    deleteRowDialog.open();
                }
            }
        }
    }

    toolBar: ToolBar {
        id: windowToolbar
        states: [
            State {
                name: "editing"
                PropertyChanges {
                    target: defaultToolbar
                    visible: false
                }
                PropertyChanges {
                    target: editingToolbar
                    visible: true
                }
            }
        ]
        Row {
            id:defaultToolbar
            MouseArea{
                Image {
                    source: "/icons/back.png"
                    anchors.fill: parent
                }
                height:25
                width:25
                onClicked:actionBack.trigger();
                onPressAndHold: {
                    // TODO: show dialog all shown tables and pop to clicked
                    console.log("catch long tap")
                }
            }
        }
        Row {
            id:editingToolbar
            visible: false
            ToolButton {
                id: toolbuttonApply
                action: actionApply
            }
            ToolButton {
                id: toolbuttonUndo
                action: actionUndo
            }
        }
    }

    Action {
        id: actionApply
        iconSource: "/icons/apply.png"
        text: "apply"
        onTriggered: {
            windowToolbar.state = ""
            tablesStack.currentItem.state = ""
            tablesStack.currentItem.collectData();
        }
    }
    Action {
        id: actionUndo
        iconSource: "/icons/undo.png"
        text: "undo"
        onTriggered: {
            windowToolbar.state = ""
            tablesStack.currentItem.state = ""
            tablesStack.currentItem.node.dropChanges();
             //HOTFIX: to update data after dropping
            tablesStack.currentItem.node = tablesStack.currentItem.node;
        }
    }
    Action{
        id: actionBack
        text: "back"
        onTriggered: {
            if (tablesStack.depth>2){
                if(tablesStack.currentItem.formType === CBApi.FilterDialog){
                    tablesStack.currentItem.applyFilters();
                }

                tablesStack.pop();
            }
        }
    }

    property bool needCollect: false;

    StackView {
        id: tablesStack
        anchors.fill: parent
        objectName: "tablesStack"
        initialItem: Text {
            property bool isListView: false
            text: "Running on: " + Qt.platform.os + "\n" +
                  "Open some base to start work";
        }
    }

    function providerReadyToWork(){
        tablesStack.pop(tablesStack.initialItem);
        title = CBApi.baseProvider.baseTitle;
        var node = CBApi.baseProvider.getStartNode();
        //var listForm = FormCreator.createListForm(node);
        var listForm = FormCreator.createTable(node);
        tablesStack.push(listForm);
    }

    function showFullForm(node, index){

        node.selectItemWithIndex(index);
        var fullForm = FormCreator.createFullForm(node);
        tablesStack.push(fullForm);
    }

    function showListForm(nodeName, currentNode){
        var node = CBApi.baseProvider.getNode(nodeName, currentNode);
        //var listForm = FormCreator.createListForm(node);
        var listForm = FormCreator.createTable(node);
        tablesStack.push(listForm);
    }

    function showFullImageInfo(index){
        var component = Qt.createComponent("CBControls/FullImageInfo.qml")
        if (component.status === Component.Ready) {
            var form = component.createObject();
            form.imageInfo = CBApi.baseProvider.imageFullInfo(index)
            tablesStack.push(form);
            form.applyContentHeight(); //HOTFIX: I have to apply contentHeight after some delay
        }
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

    MessageDialog {
        id: deleteRowDialog
        text: qsTr("Do you realy want to delete this row?")
        icon: StandardIcon.Warning
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        modality: Qt.WindowModal
        onAccepted: {
            tablesStack.currentItem.node.deleteSelectedItem();
            actionBack.trigger();
        }
    }

    function openBase() {
        //HOTFIX: for android
        if (Qt.platform.os == "android"){
            CBApi.openBase("/storage/sdcard0/VariationBase")
        }

        openBaseDialog.open()
    }

    function openBaseAlert(){
        messageDialog.open();
    }
    Connections {
        target: CBSettings
        onRecentBasesChanged:{
                var count = fileMenu.items.length;
                for (var i = count; i>2; --i){
                    fileMenu.removeItem(i);
                }


                var recentBases = CBSettings.recentBases;
                for ( var i = 0; i< recentBases.length; ++i){
                    var base = recentBases[i];
                    var qmlString = "import QtQuick 2.2\nimport QtQuick.Controls 1.2\nimport CB.api 1.0\n";
                    qmlString += "MenuItem {text:\"" + base + "\"; ";
                    qmlString += "onTriggered: CBApi.openRecentBase(\"" + base + "\")}";
                    var component = Qt.createQmlObject(qmlString,tablesStack, "menuItem");
                    fileMenu.insertItem(fileMenu.items.length,component);
                }
            }
    }
}

