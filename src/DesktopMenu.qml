import QtQuick 2.5
import QtQuick.Controls 1.4
import CB.api 1.0

MenuBar {
        Menu {
            id: fileMenu
            title: qsTr("File")
            MenuItem {
                action: openAction
            }
            MenuItem {
                action: aboutCurrentSelectedItem
            }
        }
        Menu {
            title: qsTr("Work with data")
            visible: tablesStack.currentItem.formType === CBApi.ListForm ||
                     tablesStack.currentItem.formType === CBApi.FullForm ||
                     tablesStack.currentItem.formType === CBApi.AttachForm
            MenuItem {
                action: compareRecords
                visible: tablesStack.currentItem.formType === CBApi.ListForm
            }
            Menu {
                title: qsTr("Record managing")
                MenuItem {
                    action: editAction
                    visible: tablesStack.currentItem.formType === CBApi.FullForm ||
                             tablesStack.currentItem.formType === CBApi.AttachForm
                }
                MenuItem {
                    action: newRecordAction
                    visible: tablesStack.currentItem.formType === CBApi.ListForm ||
                             tablesStack.currentItem.formType === CBApi.FullForm
                }
                MenuItem {
                    visible: tablesStack.currentItem.formType === CBApi.FullForm
                    action:  deleteRowAction
                }
                MenuItem {
                    action: cloneAction
                    visible: tablesStack.currentItem.formType === CBApi.FullForm
                }
            }

            Menu {
                title: qsTr("Filters")
                iconSource: "/filter"
                visible: tablesStack.currentItem.formType === CBApi.ListForm
                MenuItem {
                    action: setFiltersAction
                }
                MenuItem {
                    action: dropFiltersAction
                }
            }
            MenuItem {
                text:qsTr("Export to json")
                visible: tablesStack.currentItem.formType === CBApi.ListForm
                onTriggered: {
                    tablesStack.currentItem.node.exportListToFile("export")
                }
            }
        }
        Menu {
            title: qsTr("About")
            MenuItem {
                action: aboutDBAction
            }
        }
    }

