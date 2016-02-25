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
                action: setFiltersAction
            }
            MenuItem {
                action: dropFiltersAction
            }
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
            MenuItem {
                action: aboutDBAction
            }
        }
    }

