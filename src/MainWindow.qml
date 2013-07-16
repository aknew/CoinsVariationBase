import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    toolBar: ToolBar {
        RowLayout {
            ToolButton {
                iconName: "back"
                iconSource: "/icons/back.png";
                text: "back";
            }
            ToolButton {
                iconSource: "/icons/edit.png";
                text: "edit";
            }
            ToolButton {
                iconName: "add"
                iconSource: "/icons/add.png";
                text: "add";
            }
            ToolButton {
                iconSource: "/icons/delete.png";
                text: "delete";
            }
            ToolButton {
                iconSource: "/icons/Database.png";
                text: "systemTables";
            }
        }
    }

    StackView{
        id: tablesStack;
        initialItem:
            Text{
            text:Qt.platform.os
        }
    }
}
