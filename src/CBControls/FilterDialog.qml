import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import CB.api 1.0

Item {
    id: root
    property var node
    onNodeChanged: {
        if (node.filterList){
            filterList = node.filterList;
        }
    }

    property var formType: CBApi.FilterDialog
    property var filterList: ListModel { }

    ListModel{
        id: realtions
        ListElement{ text:"is equal"}
        ListElement{ text:"contains"}
        ListElement{ text:"not equal"}
    }

    ListView {
        id: listView
        model: filterList
        anchors.top: parent.top
        anchors.bottom:bar.bottom
        width: parent.width
        delegate: Item{
            height:100
            width: parent.width
            BackgroundRect{}
            MouseArea{
                anchors.fill: parent
                onClicked:{
                    editRowDialog.field = field;
                    editRowDialog.filter = filter
                    editRowDialog.relation = relation
                    editRowDialog.index = index;
                    editRowDialog.open()
                }
            }

            Text {
                text: node.listViewFields[field] + " <b>" + realtions.get(relation).text + "</b> " +filter
                wrapMode: Text.Wrap
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.right: btnRemove.left
                anchors.rightMargin: 5
            }
            Button {
                id: btnRemove
                anchors.right: parent.right
                iconSource: "/icons/undo.png"
                onClicked: {
                    filterList.remove(index)
                }
            }
        }

    }
    Rectangle {
        id: bar
        width: parent.width
        height: 100
        anchors.bottom: parent.bottom
        Button {
            id: btnAddField
            iconSource: "/icons/add.png"
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 5
            height: parent.height - 10
            width: parent.height - 10
            onClicked: {
                editRowDialog.field = 0
                editRowDialog.filter = ""
                editRowDialog.relation = 1
                editRowDialog.index = -1;
                editRowDialog.open()
            }
        }
    }

    Dialog {
        id: editRowDialog
        property int index: -1
        property alias field: edtField.currentIndex
        property alias relation: edtRelation.currentIndex
        property alias filter: edtFilter.value

        contentItem: Rectangle {
            implicitWidth: 600
            implicitHeight:Qt.platform.os == "android" ? 300 : 115
            Column{
                anchors.top:parent.top
                anchors.topMargin: 5
                anchors.bottom:btnApply.top
                anchors.bottomMargin: 5
                width:parent.width
                spacing: 5
                Item{
                   width: parent.width
                   height: edtField.height
                   Label{
                      id: lblField
                      text: qsTr("Field:")
                      font.bold: true
                      anchors.left: parent.left
                      anchors.leftMargin: 5
                      height: parent.height
                      verticalAlignment : Text.AlignVCenter
                   }
                   ComboBox{
                       id: edtField
                       model: node.listViewFields
                       anchors.left: lblField.right
                       anchors.leftMargin: 5
                       anchors.right: parent.right
                       anchors.rightMargin: 5
                   }
                }
                Item{
                   width: parent.width
                   height: edtRelation.height
                   Label{
                      id: lblRelation
                      text: qsTr("Relation:")
                      font.bold: true
                      anchors.left: parent.left
                      anchors.leftMargin: 5
                      height: parent.height
                      verticalAlignment : Text.AlignVCenter
                   }
                   ComboBox{
                       id: edtRelation
                       model: realtions
                       anchors.left: lblRelation.right
                       anchors.leftMargin: 5
                       anchors.right: parent.right
                       anchors.rightMargin: 5
                   }
                }
                LabeledTextInput {
                    id: edtFilter
                    title: qsTr("Filter string:")
                    editing: true
                }
            }

            Button {
                id: btnApply
                width: (parent.width - 15) / 2
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                text: qsTr("Apply")
                onClicked: {
                    var val = {
                        field: editRowDialog.field,
                        relation: editRowDialog.relation,
                        filter: editRowDialog.filter
                    }
                    if (editRowDialog.index === -1) {
                        filterList.append(val)
                    } else {
                        filterList.set(editRowDialog.index, val)
                    }
                    editRowDialog.close()
                    console.log(filterList.count)
                }
            }
            Button {
                width: (parent.width - 15) / 2
                anchors.left: btnApply.right
                anchors.leftMargin: 5
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                text: qsTr("Cancel")
                onClicked: {
                    editRowDialog.close()
                }
            }
        }
    }


    function applyFilters() {
        node.dropFilter()
        node.filterList = filterList;
        var conditions = []
        for (var i = 0; i < filterList.count; ++i) {
            var filter = filterList.get(i)
            var condition = "\"" + node.listViewFields[filter.field] + "\""
            // TODO: remove magic numbers
            switch (filter.relation) {
            case 0:
                condition += " = \"" + filter.filter + "\""
                break
            case 1:
                condition += " like \"%" + filter.filter + "%\""
                break
            case 2:
                condition += " = \"" + filter.filter + "\""
                condition = "not " + condition
                break
            }
            conditions.push(condition)
        }
        node.addFilter(conditions.join(" and "))
    }
}
