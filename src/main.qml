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
                visible: tablesStack.depth > 1
                contentItem: Image {
                    source: "/back"
                    fillMode: Image.Pad
                }
                //shortcut: Qt.BackButton
                onClicked: goBack()
            }
            RowLayout {
                visible: tablesStack.currentItem
                         && tablesStack.currentItem.formType !== CBApi.OpenBaseForm
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
                        ColumnLayout {
                            MenuItem {
                                contentItem: LabeledIcon {
                                    text: qsTr("Record comparation")
                                }
                                onTriggered: {
                                    tablesStack.currentItem.compareMode = true
                                    menuWorkingWithData.close()
                                }
                                visible: tablesStack.currentItem
                                         && tablesStack.currentItem.formType === CBApi.ListForm
                            }
                            MenuItem {
                                contentItem: LabeledIcon {
                                    text: qsTr("Export to json")
                                }
                                onTriggered: {
                                    tablesStack.currentItem.node.exportListToFile(
                                                "data")
                                    menuWorkingWithData.close()
                                }
                                visible: tablesStack.currentItem
                                         && tablesStack.currentItem.formType === CBApi.ListForm
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
                                    menuWorkingWithData.close()
                                }
                                visible: tablesStack.currentItem
                                         && (tablesStack.currentItem.formType === CBApi.FullForm
                                             || tablesStack.currentItem.formType
                                             === CBApi.AttachForm)
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
                                    menuWorkingWithData.close()
                                }
                                visible: tablesStack.currentItem
                                         && (tablesStack.currentItem.formType === CBApi.ListForm
                                             || tablesStack.currentItem.formType === CBApi.FullForm)
                            }
                            MenuItem {
                                visible: tablesStack.currentItem
                                         && tablesStack.currentItem.formType === CBApi.FullForm

                                contentItem: LabeledIcon {
                                    iconSource: "/delete"
                                    text: qsTr("Delete")
                                }
                                onTriggered: {
                                    deleteRowDialog.open()
                                    menuWorkingWithData.close()
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
                                    menuWorkingWithData.close()
                                }
                                visible: tablesStack.currentItem
                                         && tablesStack.currentItem.formType === CBApi.FullForm
                            }
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
                    visible: tablesStack.currentItem
                             && tablesStack.currentItem.formType === CBApi.ListForm
                    onClicked: menuFilters.open()

                    Menu {
                        id: menuFilters
                        ColumnLayout {
                            MenuItem {
                                contentItem: LabeledIcon {
                                    iconSource: "/edit"
                                    text: qsTr("Set/edit filters")
                                }
                                onTriggered: {
                                    createAndPush(
                                                "CBControls/FilterDialog.qml", {
                                                    node: tablesStack.currentItem.node
                                                })
                                    menuFilters.close()
                                }
                            }
                            MenuItem {
                                contentItem: LabeledIcon {
                                    iconSource: "/delete"
                                    text: qsTr("Drop filters")
                                }
                                onTriggered: {
                                    tablesStack.currentItem.node.dropFilter()
                                    menuFilters.close()
                                }
                            }
                            MenuItem {
                                contentItem: LabeledIcon {
                                    text: qsTr("Predefined filters")
                                }
                                visible: tablesStack.currentItem
                                         && tablesStack.currentItem.node !== null
                                         && tablesStack.currentItem.node.predefinedFiltesList.length > 0
                                onTriggered: {
                                    menuPredefinedFilters.open()
                                    menuFilters.close()
                                }
                            }
                        }
                    }
                    Menu {
                        id: menuPredefinedFilters
                        Instantiator {
                            model: tablesStack.currentItem.node ? tablesStack.currentItem.node.predefinedFiltesList : null

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
                    onClicked: openBaseDialog.open()
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
                                menuFilters.close()
                            }
                        }
                        MenuItem {
                            text: qsTr("How have I came here?") // Mean what item have I selected before current form
                            onTriggered: {
                                aboutDialog.aboutHtml = CBApi.baseProvider.getSelectedWay()
                                aboutDialog.open()
                                menuFilters.close()
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

        // Implements back key navigation
        focus: true
        Keys.onBackPressed: {
            goBack()
        }
    }

    function providerReadyToWork() {
        title = CBApi.baseProvider.baseTitle
        tablesStack.clear() // pop BaseList form - it is not need now
        showListForm()
    }

    function showFullForm(node, index) {
        if (typeof index !== 'undefined') {
            node.selectItemWithIndex(index)
        }

        if (node.useFullForm) {
            createAndPush("file:///" + CBApi.baseProvider.fullFormPath(node), {
                              node: node
                          })
        } else {
            var fullForm = FormCreator.createFullForm(node)
            tablesStack.push(fullForm)
        }
    }

    /** @brief showListForm - load new node and show its record
                  * @param nodeName - name of node, can be undefined - it meens that we need load start node
                                                * @param currentNode - node which is shown now (need's to apply filters during loading process)
                                                                                                    */
    function showListForm(nodeName, currentNode) {
        var node
        if (nodeName) {
            node = CBApi.baseProvider.getNode(nodeName, currentNode)
        } else {
            node = CBApi.baseProvider.getStartNode()
        }

        if (node.useListForm) {
            createAndPush("file:///" + CBApi.baseProvider.listFormPath(node), {
                              node: node
                          })
        } else {
            var listForm = FormCreator.createListForm(node)
            tablesStack.push(listForm)
        }
    }

    function createAndPush(qmlURL, options) {
        var component = Qt.createComponent(qmlURL)
        if (component.status === Component.Error) {
            console.log(component.errorString())
            return
        }
        if (typeof options !== 'undefined') {
            tablesStack.push(component, options)
        } else {
            tablesStack.push(component)
        }
    }

    function showDifference(node, index1, index2) {
        var diff = node.recordDifference(index1, index2)
        createAndPush("CBControls/DiffView.qml", {
                          itemDifference: diff,
                          node:node
                      })
    }

    function goBack() {
        if (tablesStack.depth > 1) {
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

    function openBaseList(){
        // Iad this function because I use it from C++ in rare cases (mostly on first run) and it is very easy to forget about it
        createAndPush("CBControls/BasesList.qml")
    }

    MessageDialog {
        id: openBaseDialog
        text: qsTr("Do you realy want to stop working with this base?")
        icon: StandardIcon.Warning
        standardButtons: StandardButton.Yes | StandardButton.No
        modality: Qt.WindowModal
        onYes: {
            tablesStack.clear()
            openBaseList()
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
            goBack()
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
