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
                        if(tablesStack.currentItem.formType === CBApi.FilterDialog){
                            tablesStack.currentItem.applyFilters();
                        }

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

    function onRecentBasesChanged(){
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

