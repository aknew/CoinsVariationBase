import QtQuick 2.0
import QtQuick.Controls 1.4
import CB.api 1.0

Item {
    property var node
    property var formType: CBApi.FilterDialog

    ListModel {
        id: filterList
        ListElement {
            field: 0
            relation: 0
            filter: ""
            deletable: false
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
                                                  deletable: false,
                                                  field: 1,
                                                  relation: 1,
                                                  filter: ""
                                              });

                            currentRow.deletable = true;
                        }
                        currentRow.filter = text
                    }
                }
            }
        }
        TableViewColumn {
            role: "deletable"
            title: ""
            width: 25
            delegate: Component {
                id: buttonDelegate
                Button {
                    iconSource:  "/icons/undo.png"
                    visible: styleData.value
                    onClicked: {
                        filterList.remove(styleData.row)
                    }

                }
            }
        }
    }
    function applyFilters(){

        var conditions = [];
        for (var i = 0; i < filterList.count; ++i){
            var filter = filterList.get(i);
            if (filter.deletable){
                var condition = "\"" + node.listViewFields[filter.field] + "\""
                switch (filter.relation){
                case 0:
                    condition += " = \"" + filter.filter + "\"";
                    break;
                case 1:
                    condition += " like \"%" + filter.filter + "%\"";
                    break;
                case 2:
                    condition += " = \"" + filter.filter + "\"";
                    condition = "not " + condition;
                    break;
                }
                conditions.push(condition);
            }
        }
        node.addFilter(conditions.join(" and "));
    }

}
