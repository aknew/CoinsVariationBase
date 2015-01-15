import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.0
import CVB.api 1.0

ApplicationWindow {
    id: mainWindow
    width: 360
    height: 360
    toolBar: ToolBar {
        id: windowToolbar
        states: [
            State {
                name: "editable"
                PropertyChanges {
                    target: defaultLayout
                    visible: false
                }
                PropertyChanges {
                    target: editableLayout
                    visible: true
                }
            },
            State {
                name: "fullform"
                PropertyChanges {
                    target: toolbuttonEdit
                    visible: true
                }
                PropertyChanges {
                    target: toolbuttonDelete
                    visible: true
                }
            }
        ]
        RowLayout {
            id:defaultLayout
            ToolButton {
                id: toolbuttonBack
                action: actionBack
            }
            ToolButton {
                id: toolbuttonEdit
                action: actionEdit
                visible:false
            }
            ToolButton {
                id: toolbuttonAdd
                action: actionAdd
            }
            ToolButton {
                id: toolbuttonDelete
                action: actionDelete
                visible:false
            }
//            ToolButton {
//                id: toolbuttonSystemTables
//                action: systemTables
//            }
        }
        RowLayout {
            id:editableLayout
            visible: false
            ToolButton {
                id: toolbuttonApply
                action: actionApply
            }
            ToolButton {
                id: toolbuttonUndo
                action: actionUndo
            }
        }
    }

    StackView {
        id: tablesStack
        anchors.fill: parent
        objectName: "tablesStack"
        initialItem: Text {
            text: Qt.platform.os
        }
    }

    FileDialog {
        id: openBaseDialog
        modality: Qt.WindowModal
        title: "Choose a base's folder"
        selectExisting: true
        selectMultiple: false
        selectFolder: true
        onAccepted: {
            console.log("Accepted: " + fileUrls[0])
            CVBApi.openBase(fileUrls[0])
        }
        onRejected: {
            console.log("Rejected")
        }
    }

    function openBase() {
        openBaseDialog.open()
    }

    function generateListViewFromFields(fieldList, model){
        var qmlString = "import QtQuick 2.0; import CVB.api 1.0; import CVBControls 1.0; Rectangle { id: mainRect; "
        qmlString += "ListView { id: listView; anchors.fill: parent; delegate: delegate; model:" + model + "}"
        qmlString += "Component { id: delegate;"
        qmlString += "Item { id: recipe; width: listView.width; height: Math.max(100,topLayout.height+10);"
        qmlString += "BackgroundRect{}"
        qmlString += "MouseArea {anchors.fill: parent; onClicked: { CVBApi.fullInfo(index);} }"
        qmlString += "Column { id: topLayout; anchors.centerIn: parent; width: listView.width-10;"

        for (var i = 0; i < fieldList.length; ++i) {

            var field = fieldList[i]
            qmlString += "Text { text:"

            var fieldTitleLength = 0

            if (fieldList.length !== 1) {
                // add field name only if we have more then 1 field
                qmlString += " \"<b>\"+"
                qmlString += "qsTr(\"" + field + "\")"
                qmlString += "+\":</b>\"+"
                fieldTitleLength = field.length + 8
            }

            qmlString += field + ";"

            qmlString += " width: parent.width; wrapMode: Text.Wrap; visible: text.length >"
                    + fieldTitleLength + ";}"
        }

        qmlString += "}" //Column {
        qmlString += "}" //Item {
        qmlString += "}" //Component {
        qmlString += "}" // mainRect
        console.log(qmlString)
        return qmlString;

    }

    function createListForm() {

        var fieldList = CVBApi.currentNode().listViewFields;

        var qmlString = generateListViewFromFields(fieldList, " CVBApi.currentNode().getListModel()");

        var listForm = Qt.createQmlObject(qmlString, tablesStack, "dynamicList")
        tablesStack.push(listForm)
        windowToolbar.state = ""
    }

    function createFullInfoForm() {

        var qmlString = "import QtQuick 2.0; import CVB.api 1.0; import CVBControls 1.0; import QtQuick.Controls 1.0; Rectangle { id: mainRect;"
        qmlString += "property bool isFullForm: true;"
        qmlString += "Flickable {clip: true; anchors.fill:parent;"
        qmlString += "contentHeight: nextlevel.y+nextlevel.height;"
        qmlString += "Column {id: contentColumn;y: 0;width: parent.width;"

        var collectDataString = "function collectData() { var returnedMap = {"

        var stateEditableString = "states: State { name: \"editable\";"

        var currentNode = CVBApi.currentNode();
        var selectedItem = currentNode.selectedItem;
        var fullFormFields = currentNode.fullFormFields;

        for (var i = 0; i < fullFormFields.length; ++i) {
            var fieldStruct = fullFormFields[i];
            var fieldType;
            var field;

            if ( typeof fieldStruct == 'string' || fieldStruct instanceof String){
                fieldType = "default";
                field = fieldStruct;
            }
            else {
                fieldType = fieldStruct["type"]
                field = fieldStruct["name"];
            }
            var field_value = selectedItem[field];

            if ( typeof field_value == 'string')
                field_value = field_value.replace(/"/g, '\\"');

            switch (fieldType) {
            case "picture":
                qmlString += "ImageWithFullScreen{ id: field_" + field
                        + "; value: \"" + field_value + "\"; editing:false}"
                break
            case "combo":
                qmlString += "LabeledComboBoxInput {id: field_" + field + "; title: qsTr(\"" + field + "\");"
                qmlString += "anchors.fill: parent.widths; value: \"" + field_value + "\";"
                qmlString += "model: CVBApi.listForName(\"" + fieldStruct["dict"]
                        + "\");z:15; editing:false}"
                break
            default:
                qmlString += "LabeledTextInput {id: field_" + field
                        + "; anchors.fill: parent.widths; value:  \"" + field_value
                        + "\";title: qsTr(\"" + field + "\"); editing:false}"
            }

            stateEditableString += "PropertyChanges { target:field_" + field + ";editing:true }"
            collectDataString += field + ": field_" + field + ".value,"
        }

        for (var i = 0; i < currentNode.subNodes.length; ++i) {
            var node = currentNode.subNodes[i];
            var model = node.getListModel();
            var fieldsToShow = model.fieldList.join("+\" \"+");
            var subnodeID = "subnode"+node.name

            stateEditableString += "PropertyChanges { target: "+subnodeID+"; editing:true }"
            qmlString += "Text  {font.pixelSize: 16; font.bold: true; text:qsTr(\""+node.name+"\")}"
            qmlString += "ListView {
                id:"+subnodeID+"
                clip: true
                property bool editing: false
                delegate:Component {
                    Item {
                        width: parent.width
                        height: 40
                        BackgroundRect{}
                        Text {
                            id: nextLevelButton
                            x: 5
                            y: 5
                            width: parent.width - x * 2
                            height: parent.height - y * 2
                            text:"+fieldsToShow+"
                            horizontalAlignment: Text.AlignHLeft
                            verticalAlignment: Text.AlignVCenter
                        }
                        Button{
                            visible:"+subnodeID+".editing
                            iconSource:\"/icons/delete.png\"
                            width: parent.height-5
                            height: parent.height-5
                            x:parent.width - parent.height -10
                            y:5
                            onClicked: {}
                        }
                   }
                }
                model: CVBApi.currentNode().subNodes[" +i+"].getListModel();
                width: parent.width
                height: 120
                interactive:false
            }";


        }

        qmlString += "}" //Column {
        qmlString += "NextLevelList { id:nextlevel; y: contentColumn.childrenRect.height+contentColumn.y }"
        qmlString += "}" //Flickable {

        stateEditableString += "PropertyChanges { target: nextlevel; visible:false }"
        stateEditableString += "}"
        qmlString += stateEditableString

        collectDataString = collectDataString.substring(
                    0, collectDataString.length - 1)
        collectDataString += "}; return returnedMap }"
        qmlString += collectDataString

        qmlString += "}" // mainRect
        console.log(qmlString)
        var fullInfoForm = Qt.createQmlObject(qmlString, tablesStack,
                                              "dynamicFullInfoForm")
        tablesStack.push(fullInfoForm)
        windowToolbar.state = "fullform"
    }

    function loadForm(formName) {
        console.log("try load form with name " + formName)
        var newForm = Qt.createComponent(formName)
        tablesStack.push(newForm)
    }

    //FIXME this file should contain all work with gui, calling CVBApi occurs because I deside don't mix migration to
    // QtQuick.Controls and refactoring in one stage
    Action {
        id: actionBack
        iconName: "back"
        iconSource: "/icons/back.png"
        text: "back"
        onTriggered: {
            tablesStack.pop()
//            CVBApi.buttonPressed(-1)
            windowToolbar.state=tablesStack.currentItem.isFullForm?"fullform":""
        }
        shortcut: "Ctrl+B"
    }
    Action {
        id: actionEdit
        iconSource: "/icons/edit.png"
        text: "edit"
        onTriggered: {
            windowToolbar.state = "editable"
            CVBApi.buttonPressed(-6)
        }
    }
    Action {
        id: actionAdd
        iconName: "add"
        iconSource: "/icons/add.png"
        text: "add"
        onTriggered: {
            CVBApi.buttonPressed(-2)
            windowToolbar.state = "editable"
        }
    }
    Action {
        id: actionDelete
        iconSource: "/icons/delete.png"
        text: "delete"
        onTriggered: CVBApi.buttonPressed(-3)
    }
//    Action {
//        id: systemTables
//        iconSource: "/icons/Database.png"
//        text: "systemTables"
//        //onTriggered: CVBApi.buttonPressed(-1);
//    }
    Action {
        id: actionApply
        iconSource: "/icons/apply.png"
        text: "apply"
        onTriggered: {
            windowToolbar.state = "fullform"
            CVBApi.buttonPressed(-4)
        }
    }
    Action {
        id: actionUndo
        iconSource: "/icons/undo.png"
        text: "undo"
        onTriggered: {
            windowToolbar.state = "fullform"
            CVBApi.buttonPressed(-5)
        }
    }
}
