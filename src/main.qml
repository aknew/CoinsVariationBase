import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2

//import QtWebKit 3.0
import CB.api 1.0
import "FormCreator.js" as FormCreator

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
                onTriggered: openBase()
            }
            MenuSeparator {
            }
        }
        Menu {
            title: qsTr("Filters")
            visible: tablesStack.currentItem.formType === CBApi.ListForm
            MenuItem {
                text: qsTr("Set filters")
                onTriggered: {
                    var component = Qt.createComponent(
                                "CBControls/FilterDialog.qml")
                    if (component.status === Component.Ready) {
                        var form = component.createObject()
                        form.node = tablesStack.currentItem.node
                        tablesStack.push(form)
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
            title: qsTr("Change data")
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
        text: qsTr("apply")
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
        text: qsTr("undo")
        onTriggered: {
            windowToolbar.state = ""
            tablesStack.currentItem.state = ""
            tablesStack.currentItem.node.dropChanges()
            if (isInsertingNew) {
                actionBack.trigger()
                isInsertingNew = false
            } else {
                //HOTFIX: to update data after dropping
                tablesStack.currentItem.node = tablesStack.currentItem.node
            }
        }
    }
    Action {
        id: actionBack
        text: qsTr("back")
        iconSource: "/icons/back.png"
        shortcut: Qt.BackButton
        onTriggered: {
            if (tablesStack.depth > 2) {
                if (tablesStack.currentItem.formType === CBApi.FilterDialog) {
                    tablesStack.currentItem.applyFilters()
                }

                tablesStack.pop()
            }
        }
    }

    property bool needCollect: false

    StackView {
        id: tablesStack
        anchors.fill: parent
        objectName: "tablesStack"
        initialItem: Text {
            property bool isListView: false
            text: "Running on: " + Qt.platform.os + "\n" + "Open some base to start work"
        }
    }

    function providerReadyToWork() {
        tablesStack.pop(tablesStack.initialItem)
        title = CBApi.baseProvider.baseTitle
        var node = CBApi.baseProvider.getStartNode()
        var listForm
        if (Qt.platform.os == "android") {
            listForm = FormCreator.createListForm(node)
        } else {
            listForm = FormCreator.createTable(node)
        }
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
        var listForm
        if (Qt.platform.os == "android") {
            listForm = FormCreator.createListForm(node)
        } else {
            listForm = FormCreator.createTable(node)
        }
        tablesStack.push(listForm)
    }

    function pushToStackView(view) {
        tablesStack.push(view)
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
            openBase()
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

    function openBase() {

        //HOTFIX: for android
        //        if (Qt.platform.os == "android") {
        //            CBApi.openBase("/storage/sdcard0/VariationBase/")
        //        }
        openBaseDialog.open()
    }

    function openBaseAlert() {
        messageDialog.open()
    }
    Connections {
        target: CBSettings
        onRecentBasesChanged: {
            var count = fileMenu.items.length
            for (var i = count - 1; i > 1; --i) {
                fileMenu.removeItem(fileMenu.items[i])
            }

            var recentBases = CBSettings.recentBases
            for (i = 0; i < recentBases.length; ++i) {
                var base = recentBases[i]
                var qmlString = "import QtQuick 2.2\nimport QtQuick.Controls 1.2\nimport CB.api 1.0\n"
                qmlString += "MenuItem {text:\"" + base + "\"; "
                qmlString += "onTriggered: CBApi.openRecentBase(\"" + base + "\")}"
                var component = Qt.createQmlObject(qmlString, tablesStack,
                                                   "menuItem")
                fileMenu.insertItem(fileMenu.items.length, component)
            }
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
