import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import QtQml 2.2

import CB.api 1.0
import "FormCreator.js" as FormCreator
import "qrc:/CBControls" //HOTFIX: I don't find how load it another way

ApplicationWindow {
    id: mainWindow
    title: qsTr("Open a base")

    height: 500
    width: 1000
    property bool isInsertingNew: false

    menuBar: FormCreator.createMenu()

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
        iconSource: "/apply"
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
        iconSource: "/undo"
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
        iconSource: "/back"
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
                    if (currentItem.formType === CBApi.FullForm && currentItem.node.usesUUIDs){
                        CBApi.baseProvider.deselectCurrentId();
                    }
                    if (currentItem.formType === CBApi.ListForm){
                        tablesStack.currentItem.node.dropFilter();
                    }

                    tablesStack.pop()
                }
            }
        }
    }

    Action {
        id: aboutDBAction
        text: qsTr("About base")
        onTriggered: {
            aboutDialog.aboutHtml = CBApi.baseProvider.getAbout()
            aboutDialog.open()
        }
    }
    Action {
        id: aboutCurrentSelectedItem
        text: qsTr("How have I came here?") // Mean what item have I selected before current form
        onTriggered: {
            aboutDialog.aboutHtml = CBApi.baseProvider.getSelectedWay()
            aboutDialog.open()
        }
    }
    Action {
        id: cloneAction
        text: qsTr("Clone")
        iconSource: "/clone"
        onTriggered: {
            var currentItem = tablesStack.currentItem;
            currentItem.node.cloneItem()
            //HOTFIX: to update data after clonning
            currentItem.node = currentItem.node
            windowToolbar.state = "editing"
            currentItem.state = "editing"
            isInsertingNew = true
        }
    }
    Action{
        id: editAction
        text: qsTr("Edit record")
        shortcut: "Ctrl+E"
        iconSource: "/edit"
        onTriggered: {
            windowToolbar.state = "editing"
            tablesStack.currentItem.state = "editing"
        }
    }
    Action{
        id: newRecordAction
        text: qsTr("Add new")
        iconSource: "/add"
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
    Action{
        id:deleteRowAction
        text: qsTr("Delete")
        iconSource: "/delete"
        onTriggered: {
            deleteRowDialog.open()
        }
    }
    Action{
        id: openAction
        text: qsTr("Open")
        shortcut: "Ctrl+O"
        onTriggered: tablesStack.pop(tablesStack.initialItem)
    }
    Action{
        id: setFiltersAction
        text: qsTr("Set/edit filters")
        iconSource: "/edit"
        onTriggered: {
            var component = Qt.createComponent("CBControls/FilterDialog.qml")
            switch (component.status) {
            case Component.Ready:
                var form = component.createObject()
                form.node = tablesStack.currentItem.node
                pushToStackView(form)
                break
            case Component.Error:
                console.log(component.errorString())
                break
            }
        }
    }
    Action{
        id: dropFiltersAction
        text: qsTr("Drop filters")
        iconSource: "/delete"
        onTriggered: {
            tablesStack.currentItem.node.dropFilter()
        }

    }
    Action{
        id: compareRecords
        text: qsTr("Record comparation")
        onTriggered: tablesStack.currentItem.compareMode = true;
    }
    Action{
        id: predefinedFiltersAction
        text: qsTr("Predefined filters")
        onTriggered: {
            predefinedContextMenu.popup()
        }
    }

    Menu {
            id: predefinedContextMenu

            Instantiator {
                model: tablesStack.currentItem.node.predefinedFiltesList

                MenuItem {
                    text: modelData
                    onTriggered: {
                        tablesStack.currentItem.node.applyPredefinedFilter(modelData)
                    }
                }
                onObjectAdded: predefinedContextMenu.insertItem(index, object)
                onObjectRemoved: predefinedContextMenu.removeItem(object)
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
        pushToStackView(listForm)
    }

    function showFullForm(node, index) {
        if (typeof index !== 'undefined') {
            node.selectItemWithIndex(index)
        }
        var fullForm = FormCreator.createFullForm(node)
        pushToStackView(fullForm)
    }

    function showListForm(nodeName, currentNode) {
        var node = CBApi.baseProvider.getNode(nodeName, currentNode)
        var listForm = FormCreator.createListForm(node)

        pushToStackView(listForm)
    }

    function pushToStackView(view) {
        tablesStack.push({item: view, destroyOnPop: true})
    }

    function showDifference(node, index1, index2){
        var diff = node.recordDifference(index1,index2);
        var component = Qt.createComponent("CBControls/DiffView.qml")
        switch (component.status) {
        case Component.Ready:
            var form = component.createObject()
            form.itemDifference = diff
            pushToStackView(form)
            break
        case Component.Error:
            console.log(component.errorString())
            break
        }
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
            if (currentItem.formType === CBApi.FullForm && currentItem.node.usesUUIDs){
                CBApi.baseProvider.deselectCurrentId();
            }
            tablesStack.pop()
        }
    }

        Dialog {
            id: aboutDialog
            property alias aboutHtml: aboutView.text
            contentItem:Rectangle{
                color: "white"
                implicitHeight: mainWindow.height-100
                implicitWidth: mainWindow.width-100
                Keys.onBackPressed: aboutDialog.close()
                Flickable{
                    clip: true
                    anchors.fill: parent
                    contentHeight: aboutView.height
                    Text{
                        id: aboutView
                        width: parent.width
                        wrapMode: Text.Wrap
                        onLinkActivated: Qt.openUrlExternally(link)
                    }
                }
            }
        }
}
