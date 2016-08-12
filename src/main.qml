import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQml 2.2
import QtQuick.Dialogs 1.2

import CB.api 1.0
import "FormCreator.js" as FormCreator

//HOTFIX: I don't find how load it another way
import "qrc:/CBControls"

ApplicationWindow {
    id: mainWindow
    title: qsTr("Open a base")

    height: 500
    width: 1000
    property bool isInsertingNew: false

    header: ToolBar {
        // TODO: make shortcuts workable
        id: windowToolbar
        height: GUIStyle.barHeight

        states: [
            State {
                name: "editing"
                PropertyChanges {
                    target: defaultLayout
                    visible: false
                }
                PropertyChanges {
                    target: editingLayout
                    visible: true
                }
            }
        ]
        Item {
            id: defaultLayout
            anchors.fill: parent
            ToolButton {
                anchors.left: parent.left
                anchors.leftMargin: 5
                height: parent.height
                width: parent.height
                visible: tablesStack.depth > 2
                contentItem: Image {
                    source: "/back"
                    fillMode: Image.Pad
                }
                //shortcut: Qt.BackButton
                onClicked: {
                    if (tablesStack.depth > 2) {
                        var currentItem = tablesStack.currentItem
                        if (currentItem.formType === CBApi.FilterDialog) {
                            currentItem.applyFilters()
                        }
                        if (currentItem.state === "editing") {
                            goBackDialog.open()
                        } else {
                            if (currentItem.formType === CBApi.FullForm
                                    && currentItem.node.usesUUIDs) {
                                CBApi.baseProvider.deselectCurrentId()
                            }
                            if (currentItem.formType === CBApi.ListForm) {
                                tablesStack.currentItem.node.dropFilter()
                            }

                            tablesStack.pop()
                        }
                    }
                }
            }
            RowLayout {
                visible: tablesStack.currentItem.formType !== CBApi.OpenBaseForm
                height: parent.height
                anchors.right: parent.right
                anchors.rightMargin: 5
                ToolButton {
                    height: parent.height
                    width: parent.height
                    contentItem: Image {
                        source: "/work_with_data"
                        fillMode: Image.Pad
                        horizontalAlignment: Image.AlignHCenter
                        verticalAlignment: Image.AlignVCenter
                    }
                    onClicked: menuWorkingWithData.open()
                    Menu {
                        id: menuWorkingWithData
                        MenuItem {
                            text: qsTr("Record comparation")
                            onTriggered: tablesStack.currentItem.compareMode = true
                            visible: tablesStack.currentItem.formType === CBApi.ListForm
                        }
                        MenuItem {
                            text: qsTr("Export to json")
                            onTriggered: {
                                tablesStack.currentItem.node.exportListToFile(
                                            "export")
                            }
                            visible: tablesStack.currentItem.formType === CBApi.ListForm
                        }
                        MenuItem {
                            //shortcut: "Ctrl+E"
                            contentItem: LabeledIcon {
                                iconSource: "/edit"
                                text: qsTr("Edit record")
                            }
                            onTriggered: {
                                windowToolbar.state = "editing"
                                tablesStack.currentItem.state = "editing"
                            }
                            visible: tablesStack.currentItem.formType === CBApi.FullForm
                                     || tablesStack.currentItem.formType === CBApi.AttachForm
                        }
                        MenuItem {

                            contentItem: LabeledIcon {
                                iconSource: "/add"
                                text: qsTr("Add new")
                            }
                            //shortcut: "Ctrl+N"
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
                            visible: tablesStack.currentItem.formType === CBApi.ListForm
                                     || tablesStack.currentItem.formType === CBApi.FullForm
                        }
                        MenuItem {
                            visible: tablesStack.currentItem.formType === CBApi.FullForm

                            contentItem: LabeledIcon {
                                iconSource: "/delete"
                                text: qsTr("Delete")
                            }
                            onTriggered: {
                                deleteRowDialog.open()
                            }
                        }
                        MenuItem {
                            contentItem: LabeledIcon {
                                iconSource: "/clone"
                                text: qsTr("Clone")
                            }
                            onTriggered: {
                                var currentItem = tablesStack.currentItem
                                currentItem.node.cloneItem()
                                //HOTFIX: to update data after clonning
                                currentItem.node = currentItem.node
                                windowToolbar.state = "editing"
                                currentItem.state = "editing"
                                isInsertingNew = true
                            }
                            visible: tablesStack.currentItem.formType === CBApi.FullForm
                        }
                    }
                }
                ToolButton {
                    height: parent.height
                    width: parent.height
                    contentItem: Image {
                        source: "/filter"
                        fillMode: Image.Pad
                        horizontalAlignment: Image.AlignHCenter
                        verticalAlignment: Image.AlignVCenter
                    }
                    visible: tablesStack.currentItem.formType === CBApi.ListForm
                    onClicked: menuFilters.open()

                    Menu {
                        id: menuFilters
                        MenuItem {
                            contentItem: LabeledIcon {
                                iconSource: "/edit"
                                text: qsTr("Set/edit filters")
                            }
                            onTriggered: {
                                var component = Qt.createComponent(
                                            "CBControls/FilterDialog.qml")
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
                        MenuItem {
                            contentItem: LabeledIcon {
                                iconSource: "/delete"
                                text: qsTr("Drop filters")
                            }
                            onTriggered: {
                                tablesStack.currentItem.node.dropFilter()
                            }
                        }
                        MenuItem {
                            text: qsTr("Predefined filters")
                            visible: tablesStack.currentItem.node!= null && tablesStack.currentItem.node.predefinedFiltesList.length > 0
                            onTriggered: {
                                menuPredefinedFilters.open()
                            }
                        }
                    }
                    Menu {
                        id: menuPredefinedFilters
                        Instantiator {
                            model: tablesStack.currentItem.node?
                                       tablesStack.currentItem.node.predefinedFiltesList:
                                       null

                            MenuItem {
                                text: modelData
                                onTriggered: {
                                    tablesStack.currentItem.node.applyPredefinedFilter(
                                                modelData)
                                }
                            }
                            onObjectAdded: menuPredefinedFilters.insertItem(
                                               index, object)
                            onObjectRemoved: menuPredefinedFilters.removeItem(
                                                 object)
                        }
                    }
                }
                ToolButton {
                    height: parent.height
                    width: parent.height
                    contentItem: Image {
                        source: "/open"
                        fillMode: Image.Pad
                        horizontalAlignment: Image.AlignHCenter
                        verticalAlignment: Image.AlignVCenter
                    }
                    onClicked: tablesStack.pop(tablesStack.initialItem)
                    //shortcut: "Ctrl+O"
                }

                ToolButton {
                    height: parent.height
                    width: parent.height
                    contentItem: Image {
                        source: "/help"
                        fillMode: Image.Pad
                        horizontalAlignment: Image.AlignHCenter
                        verticalAlignment: Image.AlignVCenter
                    }
                    onClicked: menuHelp.open()

                    Menu {
                        id: menuHelp
                        MenuItem {
                            text: qsTr("About base")
                            onTriggered: {
                                aboutDialog.aboutHtml = CBApi.baseProvider.getAbout()
                                aboutDialog.open()
                            }
                        }
                        MenuItem {
                            text: qsTr("How have I came here?") // Mean what item have I selected before current form
                            onTriggered: {
                                aboutDialog.aboutHtml = CBApi.baseProvider.getSelectedWay()
                                aboutDialog.open()
                            }
                        }
                    }
                }
            }
        }
        Item {
            anchors.fill: parent
            id: editingLayout
            visible: false

            ToolButton {
                height: parent.height
                width: parent.height
                anchors.left: parent.left
                anchors.leftMargin: 5
                contentItem: Image {
                    source: "/apply"
                    fillMode: Image.Pad
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                }

                //            shortcut: "Ctrl+S"
                onClicked: {
                    windowToolbar.state = ""
                    tablesStack.currentItem.state = ""
                    tablesStack.currentItem.collectData()
                }
            }
            ToolButton {
                height: parent.height
                width: parent.height
                anchors.right: parent.right
                anchors.rightMargin: 5
                contentItem: Image {
                    source: "/undo"
                    fillMode: Image.Pad
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                }
                onClicked: {
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
        }

    }
    property bool needCollect: false

    StackView {
        id: tablesStack
        anchors.fill: parent
        objectName: "tablesStack"
        initialItem: BasesList {
        }

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
        //tablesStack.push({item: view, destroyOnPop: true})
        tablesStack.push(view)
    }

    function showDifference(node, index1, index2) {
        var diff = node.recordDifference(index1, index2)
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
            if (currentItem.formType === CBApi.FullForm
                    && currentItem.node.usesUUIDs) {
                CBApi.baseProvider.deselectCurrentId()
            }
            tablesStack.pop()
        }
    }

    Dialog {
        id: aboutDialog
        property alias aboutHtml: aboutView.text
        contentItem: Rectangle {
            color: "white"
            implicitHeight: mainWindow.height - 100
            implicitWidth: mainWindow.width - 100
            Keys.onBackPressed: aboutDialog.close()
            Flickable {
                clip: true
                anchors.fill: parent
                contentHeight: aboutView.height
                Text {
                    id: aboutView
                    width: parent.width
                    wrapMode: Text.Wrap
                    onLinkActivated: Qt.openUrlExternally(link)
                }
            }
        }
    }
}
