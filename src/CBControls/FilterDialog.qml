import QtQuick 2.5
import QtQuick.Controls 2.0
import CB.api 1.0

import "."

// QTBUG-34418, singletons require explicit import to load qmldir file
Page {
    header:ToolBar{
        ToolButton {
            anchors.left: parent.left
            anchors.leftMargin: 5
            height: parent.height
            width: parent.height
            visible: tablesStack.depth > 1
            contentItem: Image {
                source: "/apply"
                fillMode: Image.Pad
            }
            //shortcut: Qt.BackButton
            onClicked: {
                applyFilters()
                mainWindow.goBack()
            }
        }
        ToolButton {
            anchors.right: parent.right
            anchors.rightMargin: 5
            height: parent.height
            width: parent.height
            contentItem: Image {
                source: "/undo"
                fillMode: Image.Pad
            }
            onClicked: mainWindow.goBack()
        }
    }
    id: root
    property var node
    onNodeChanged: {

        translatedFields.clear()
        var fieldList = node.listViewFields
        for (var i = 0; i < fieldList.length; ++i) {
            var field = fieldList[i]
            translatedFields.append({
                                        text: qsTr(field)
                                    })
        }
        var str = node.filter;
        var list = str.split(" and ")
        var pattern = /"?([A-Za-z]{1,})"?\s(=|like|not\slike)\s"?([^"]{1,})"?/
        var patternNE = /not\s"?([A-Za-z]{1,})"?\s=\s"?([^"]{1,})"?/
        for ( i = 0; i < list.length ; i++) {
            var result = list[i].match(patternNE)
            if (result){
                var val = {
                    field: fieldList.indexOf(result[1]),
                    relation: 2,
                    filter: result[2]
                }
                filterList.append(val)
            }
            else{
                result = list[i].match(pattern)
                if (result){
                    var relation;
                    // TODO: remove magic numbers
                    switch (result[2]) {
                    case "=":
                        relation = 0;
                        break
                    case "like":
                        relation = 1;
                        result[3] = result[3].replace(/^%/,"");
                        result[3] = result[3].replace(/%$/,"");
                        break
                    case "not like":
                        relation = 3;
                        result[3] = result[3].replace(/^%/,"");
                        result[3] = result[3].replace(/%$/,"");
                        break
                    }
                    val = {
                        field: fieldList.indexOf(result[1]),
                        relation: relation,
                        filter: result[3]
                    }
                    filterList.append(val)
                }
            }
        }
    }

    property int formType: CBApi.FilterDialog
    property var filterList: ListModel {
    }

    ListModel {
        id: realtions
        ListElement {
            text: qsTr("is equal")
        }
        ListElement {
            text: qsTr("contains")
        }
        ListElement {
            text: qsTr("not equal")
        }
        ListElement {
            text: qsTr("not contains")
        }
    }

    ListView {
        ScrollBar.vertical: ScrollBar {
        }
        id: listView
        model: filterList
        anchors.top: parent.top
        anchors.bottom: bar.bottom
        width: parent.width
        delegate: Item {
            height: 100
            width: parent.width
            BackgroundRect {
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    editRowDialog.field = field
                    editRowDialog.filter = filter
                    editRowDialog.relation = relation
                    editRowDialog.index = index
                    editRowDialog.open()
                }
            }

            Text {
                text: qsTr(node.listViewFields[field]) + " <b>" + realtions.get(
                          relation).text + "</b> " + filter
                wrapMode: Text.Wrap
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.right: btnRemove.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 5
            }
            Button {
                id: btnRemove
                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                contentItem: Image {
                    source: "/delete"
                    fillMode: Image.Pad
                }
                onClicked: {
                    filterList.remove(index)
                }
            }
        }
    }
    Rectangle {
        id: bar
        width: parent.width
        height: GUIStyle.barHeight
        anchors.bottom: parent.bottom
        Button {
            id: btnAddField
            contentItem: Image {
                source: "/add"
            }
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
                editRowDialog.index = -1
                editRowDialog.open()
            }
        }
    }

    Popup {
        id: editRowDialog
        property int index: -1
        property alias field: edtField.currentIndex
        property alias relation: edtRelation.currentIndex
        property alias filter: edtFilter.value

        contentItem: Rectangle {
            implicitWidth: 600
            implicitHeight: GUIStyle.isMobile ? 315 : 200
            Column {
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.bottom: btnApply.top
                anchors.bottomMargin: 5
                width: parent.width
                spacing: 5
                Item {
                    width: parent.width
                    height: edtField.height
                    Label {
                        id: lblField
                        text: qsTr("Field:")
                        font.bold: true
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                    }
                    ComboBox {
                        id: edtField
                        anchors.left: lblField.right
                        anchors.leftMargin: 5
                        anchors.right: parent.right
                        anchors.rightMargin: 5
                        model: ListModel {
                            id: translatedFields
                        }
                    }
                }
                Item {
                    width: parent.width
                    height: edtRelation.height
                    Label {
                        id: lblRelation
                        text: qsTr("Relation:")
                        font.bold: true
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                    }
                    ComboBox {
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
            case 3:
                condition += " not like \"%" + filter.filter + "%\""
                break
            }
            conditions.push(condition)
        }
        node.filter = conditions.join(" and ");
    }
}
