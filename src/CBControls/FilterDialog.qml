import QtQuick 2.0
import QtQuick.Controls 1.4

Item {
    property var node
    property bool isListView: false

    ListModel {
        id: filterList
        ListElement {
            field: 0
            relation: 0
            filter: ""
            button: "+"
        }

    }
    TableView {
        height: 50
        model: filterList
        anchors.fill: parent
        TableViewColumn {
            role: "field"
            title: qsTr("field")
            delegate: Component {
                id: comboFieldDelegate
                ComboBox {

                    model: node.listViewFields
                    currentIndex:styleData.value;
                    onCurrentIndexChanged: {
                        filterList.get(styleData.row).field = currentIndex
                    }
                }
            }
        }
        TableViewColumn {
            role: "relation"
            title: qsTr("relation")
            delegate: Component {
                id: comboDelegate
                ComboBox {
                    model: node.relationList()
                    currentIndex:styleData.value;
                    onCurrentIndexChanged: {
                        filterList.get(styleData.row).relation = currentIndex
                    }
                }
            }
        }
        TableViewColumn {
            role: "filter"
            title: qsTr("filter string")
            delegate: Component {
                id: textDelegate
                TextField {
                    text: styleData.value
                    onEditingFinished: {
                        var currentRow = filterList.get(styleData.row);

                        if (currentRow.filter===""){

                            filterList.append({
                                                  button: "+",
                                                  field: 1,
                                                  relation: 1,
                                                  filter: ""
                                              });

                            currentRow.button = "-";
                        }
                        currentRow.filter = text
                    }
                }
            }
        }
        TableViewColumn {
            role: "button"
            title: ""
            width: 25
            delegate: Component {
                id: buttonDelegate
                Button {
                    //iconSource: styleData.value  === "+" ?"/icons/add.png":"/icons/undo.png"
                    iconSource:  "/icons/undo.png"
                    visible: styleData.value  === "-"
                    onClicked: {
//                        var k = filterList.get(styleData.row)
//                        console.log(k.field)
//                        console.log(k.filter)
                        filterList.remove(styleData.row)
                    }

                }
            }
        }
    }
}
