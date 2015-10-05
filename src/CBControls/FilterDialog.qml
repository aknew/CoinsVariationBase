import QtQuick 2.0
import QtQuick.Controls 1.4

Item {
    property var node;

    Component {
        id: comboDelegate
        ComboBox {
            model: ListModel {
                ListElement { text: "Banana" }
                ListElement { text: "Apple" }
                ListElement { text: "Coconut" }
            }
        }
    }

    Component{
        id: buttonDelegate
        Button{
            action:itemText==="+"?addAction:undoAction;
        }
    }

    Component {
        id: textDelegate
        TextField {
            text: itemText
        }
    }

    ListModel {
        id: filterList
        ListElement{
            field:"";
            relation:"=="
            filter:""
            button:"+"
        }
    }
    TableView{
        height: 50
        model: filterList
        anchors.fill: parent
        TableViewColumn{
            role: "field"
            title: qsTr("field")
        }
        TableViewColumn{
            role: "relation"
            title: qsTr("relation")
        }
        TableViewColumn{
            role: "filter"
            title: qsTr("filter string")
        }
        TableViewColumn{
            role: "button"
            title:""
            width:25
        }
        itemDelegate: Item {
                height: 25
                Loader {
                    property string itemText: styleData.value
                    sourceComponent: styleData.column === 3 ? buttonDelegate:textDelegate //: comboDelegate
                }
            }
    }

    Action{
        id: addAction
        iconSource: "/icons/add.png"
        onTriggered: {
            filterList.append({"button":"-","field":"test field","relation":"like","filter":"test filter"})
        }
    }
    Action{
        id: undoAction
        iconSource: "/icons/undo.png"
        onTriggered: {
            //filterList.remove()
        }
    }


}

