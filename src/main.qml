import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2

//import QtWebKit 3.0
import CB.api 1.0
import "FormCreator.js" as FormCreator
import "qrc:/CBControls" //HOTFIX: I don't find how load it another way

ApplicationWindow {
    id: mainWindow
    title: qsTr("Open a base")

    height: 500
    width: 1000
    property bool isInsertingNew: false

    menuBar: MenuBar {
        Menu {
            id: fileMenu
            title: qsTr("File")
            MenuItem {
                text: qsTr("Open...")
                shortcut: "Ctrl+O"
                onTriggered: tablesStack.pop(tablesStack.initialItem)
            }
        }
        Menu {
            title: qsTr("Filters")
            visible: tablesStack.currentItem.formType === CBApi.ListForm
            MenuItem {
                text: qsTr("Set filters")
                onTriggered: {
                    var component = Qt.createComponent("CBControls/FilterDialog.qml")
                    switch (component.status) {
                    case Component.Ready:
                        var form = component.createObject()
                        form.node = tablesStack.currentItem.node
                        tablesStack.push(form)
                        break
                    case Component.Error:
                        console.log(component.errorString())
                        break
                    }
                }
            }
            MenuItem {
                text: qsTr("Drop filters")
                onTriggered: {
                    tablesStack.currentItem.node.dropFilter()
                }
            }
        }
        Menu {
            title: qsTr("Work with data")
            visible: tablesStack.currentItem.formType !== CBApi.FilterDialog
            MenuItem {
                text: qsTr("Edit record")
                shortcut: "Ctrl+E"
                visible: tablesStack.currentItem.formType !== CBApi.ListForm
                iconSource: "/icons/edit.png"
                onTriggered: {
                    windowToolbar.state = "editing"
                    tablesStack.currentItem.state = "editing"
                }
            }
            MenuItem {
                text: qsTr("Add new")
                iconSource: "/icons/add.png"
                shortcut: "Ctrl+N"
                onTriggered: {

                    tablesStack.currentItem.node.prepareToNewItem()
                    if (tablesStack.currentItem.formType === CBApi.ListForm) {
                        showFullForm(tablesStack.currentItem.node)
                    } else {
                        //HOTFIX: to update data after dropping
                        tablesStack.currentItem.node = tablesStack.currentItem.node
                    }
                    windowToolbar.state = "editing"
                    tablesStack.currentItem.state = "editing"
                    isInsertingNew = true
                }
            }
            MenuItem {
                text: qsTr("Delete")
                iconSource: "/icons/delete.png"
                visible: tablesStack.currentItem.formType !== CBApi.ListForm
                onTriggered: {
                    deleteRowDialog.open()
                }
            }
            MenuItem {
                text: qsTr("Clone")
                //iconSource:  "/icons/delete.png"
                visible: tablesStack.currentItem.formType === CBApi.FullForm
                onTriggered: {
                    tablesStack.currentItem.node.cloneItem()
                    //HOTFIX: to update data after dropping
                    tablesStack.currentItem.node = tablesStack.currentItem.node
                    windowToolbar.state = "editing"
                    tablesStack.currentItem.state = "editing"
                    isInsertingNew = true
                }
            }
        }
        Menu {
            title: qsTr("About")
            MenuItem {
                text: qsTr("About base")
                onTriggered: {
                    aboutDialog.htmlPath = CBApi.baseProvider.getAbout()
                    aboutDialog.open()
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
            id: defaultToolbar
            ToolButton {
                id: backButton
                action: actionBack
                visible: tablesStack.depth > 2
            }
        }
        Row {
            id: editingToolbar
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
        text: qsTr("Apply")
        shortcut: "Ctrl+S"
        onTriggered: {
            windowToolbar.state = ""
            tablesStack.currentItem.state = ""
            tablesStack.currentItem.collectData()
        }
    }
    Action {
        id: actionUndo
        iconSource: "/icons/undo.png"
        text: qsTr("Undo")
        onTriggered: {
            windowToolbar.state = ""
            tablesStack.currentItem.state = ""
            tablesStack.currentItem.node.dropChanges()
            if (isInsertingNew) {
                tablesStack.pop()
                isInsertingNew = false
            } else {
                //HOTFIX: to update data after dropping
                tablesStack.currentItem.node = tablesStack.currentItem.node
            }
        }
    }
    Action {
        id: actionBack
        text: qsTr("Back")
        iconSource: "/icons/back.png"
        shortcut: Qt.BackButton
        onTriggered: {
            if (tablesStack.depth > 2) {
                var currentItem = tablesStack.currentItem;
                if (currentItem.formType === CBApi.FilterDialog) {
                    currentItem.applyFilters()
                }
                if (currentItem.state === "editing"){
                    goBackDialog.open();
                }
                else{
                    tablesStack.pop()
                }
            }
        }
    }

    property bool needCollect: false

    StackView {
        id: tablesStack
        anchors.fill: parent
        objectName: "tablesStack"
        initialItem: BasesList{}

        // Implements back key navigation
        focus: true
        Keys.onBackPressed: {
            actionBack.trigger()
        }
    }

    function providerReadyToWork() {
        title = CBApi.baseProvider.baseTitle
        var node = CBApi.baseProvider.getStartNode()
        var listForm = FormCreator.createListForm(node)
        tablesStack.push(listForm)
    }

    function showFullForm(node, index) {
        if (typeof index !== 'undefined') {
            node.selectItemWithIndex(index)
        }
        var fullForm = FormCreator.createFullForm(node)
        tablesStack.push(fullForm)
    }

    function showListForm(nodeName, currentNode) {
        var node = CBApi.baseProvider.getNode(nodeName, currentNode)
        var listForm = FormCreator.createListForm(node)

        tablesStack.push(listForm)
    }

    function pushToStackView(view) {
        tablesStack.push(view)
    }

    MessageDialog {
        id: deleteRowDialog
        text: qsTr("Do you realy want to delete this row?")
        icon: StandardIcon.Warning
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        modality: Qt.WindowModal
        onAccepted: {
            tablesStack.currentItem.node.deleteSelectedItem()
            actionBack.trigger()
        }
    }

    MessageDialog {
        id: goBackDialog
        text: qsTr("Do you realy want to go back and drop all changes?")
        icon: StandardIcon.Warning
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        modality: Qt.WindowModal
        onAccepted: {
            windowToolbar.state = ""
            tablesStack.currentItem.state = ""
            // TODO: move it to form because some form can  have state editing, but don't have node
            // For example it is AttachmentFullInfo and FilterDialog
            tablesStack.currentItem.node.dropChanges()
            isInsertingNew = false
            tablesStack.pop()
        }
    }

    //    Dialog {
    //        id: aboutDialog
    //        height: 500
    //        width: 800
    //        property alias htmlPath: aboutView.url
    //        contentItem: WebView{
    //            id: aboutView
    //            anchors.fill: parent
    //        }
    //    }
}
