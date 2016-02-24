import QtQuick 2.5
import QtQuick.Controls 1.4
import CB.api 1.0

// TODO: move all items triggers/titles to Actions

MenuBar {
        Menu {
            id: fileMenu
            title: qsTr("File")
            MenuItem {
                text: qsTr("Open")
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
                iconSource: "/edit"
                onTriggered: {
                    windowToolbar.state = "editing"
                    tablesStack.currentItem.state = "editing"
                }
            }
            MenuItem {
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
            MenuItem {
                text: qsTr("Delete")
                iconSource: "/delete"
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
                    aboutDialog.aboutHtml = CBApi.baseProvider.getAbout()
                    aboutDialog.open()
                }
            }
        }
    }

