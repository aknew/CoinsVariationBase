import QtQuick 2.0
import QtQuick.Controls 1.4

Item {
    property var node

    ListModel {
        id: filterList
        ListElement {
            field: "avers"
            relation: "!="
            filter: "122"
            button: "-"
        }
        ListElement {
            field: "revers"
            relation: "contains"
            filter: " sample"
            button: "-"
        }
        ListElement {
            field: ""
            relation: "=="
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
                    //currentText: styleData.value
                    model: ListModel {
                        id: fieldsList
                        ListElement {
                            text: "nominal"
                        }
                        ListElement {
                            text: "years"
                        }
                        ListElement {
                            text: "metal"
                        }
                    }
                    onCurrentIndexChanged: {
                        filterList.get(styleData.row).field = currentText
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
                    //currentText: styleData.value
                    model: ListModel {
                        ListElement {
                            text: "=="
                        }
                        ListElement {
                            text: "!="
                        }
                        ListElement {
                            text: "contains"
                        }
                    }
                    onCurrentIndexChanged: {
                        filterList.get(styleData.row).relation = currentText
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
                                                  field: "avers", //FIXME:
                                                  relation: "==",
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
