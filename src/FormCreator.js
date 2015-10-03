function createListForm(node) {
    var qmlString

    qmlString = "import QtQuick 2.0;\n" +
                "import CB.api 1.0;\n" +
                "import CBControls 1.0;\n" +
                "Rectangle {\n" +
                "   id: mainRect;\n" +
                "   property bool isListView: true;\n" +
                "   property var node;\n"+
                "   onNodeChanged:{listView.model = node.listModel;}\n";

    qmlString+= "   ListView {\n" +
                "       id:listView;\n" +
                "       anchors.fill: parent;\n" +
                "       delegate: delegate;\n   }\n";


    qmlString += "  Component {\n       id: delegate;\n";

    qmlString += "      Item {\n"+
                 "          id: recipe;\n"+
                 "          width: listView.width;\n"+
                 "          height: Math.max(100,topLayout.height+10);\n";

    qmlString += "          BackgroundRect{}\n";
    qmlString += "          MouseArea {anchors.fill: parent; onClicked: { mainWindow.showFullForm(node,index);} }\n";

    qmlString += "          Column {\n"+
                 "          id: topLayout;\n"+
                 "          anchors.centerIn:parent;\n"+
                 "          width: listView.width-10;\n";

    var fieldList = node.listViewFields;
    for (var i = 0; i < fieldList.length; ++i) {

        var field = fieldList[i]
        qmlString += "              Text {text:"

        var fieldTitleLength = 0

        if (fieldList.length !== 1) {
            // add field name only if we have more then 1 field in item
            qmlString += " \"<b>\"+"
            qmlString += "qsTr(\"" + field + "\")"
            qmlString += "+\":</b>\"+"
            fieldTitleLength = field.length + 8
        }

        qmlString += field + ";"

        qmlString += " width: parent.width; wrapMode: Text.Wrap; visible: text.length >"
                + fieldTitleLength + ";}\n"
    }

    qmlString += "          }\n" //Column {
    qmlString += "      }\n" //Item {
    qmlString += "  }\n" //Component {
    qmlString += "}" // mainRect

    if (needCollect) {
        CBApi.baseProvider.saveListForm(qmlString,node)
    }

    var component = Qt.createQmlObject(qmlString,tablesStack, "dynamicList");
    component.node = node;

    return component;
}

function createTable(node){

    var qmlString

    qmlString = "import QtQuick 2.0;\n" +
                "import CB.api 1.0;\n" +
            "import QtQuick.Controls 1.2\n\n"+
            "Rectangle {\n" +
            "   id: mainRect;\n" +
            "   property bool isListView: true;\n" +
            "   property var node;\n"+
            "   onNodeChanged:{tableView.model = node.listModel;}\n\n"+
            "   TableView {\n       id:tableView;\n        anchors.fill:parent;\n" +
            "       onClicked: { mainWindow.showFullForm(node,row);}\n\n";


    var fieldList = node.listViewFields;
    for (var i = 0; i < fieldList.length; ++i) {

        var field = fieldList[i]
        qmlString +="        TableViewColumn { role: \"" + field +"\"; title:qsTr(\""+ field +"\")}\n"

    }

    qmlString += "  }\n" //TableView
    qmlString += "}" // mainRect

    if (needCollect) {
        CBApi.baseProvider.saveListForm(qmlString,node)
    }

    var component = Qt.createQmlObject(qmlString,tablesStack, "dynamicList");
    component.node = node;

    return component;
}

function createFullForm(node) {
    //FIXME: need rewrite collect data, comboboxes

    var qmlString

    qmlString = "import QtQuick 2.0;\n" +
                "import CB.api 1.0;\n" +
                "import CBControls 1.0;\n" +
                "import QtQuick.Controls 1.4\n\n"+
                "Rectangle {\n" +
                "   id: mainRect;\n" +
                "   property bool isListView: false;\n" +
                "   property var node;\n";

    qmlString += "  Flickable {\n"+
                 "       clip: true;\n"+
                 "       anchors.fill:parent;\n";

    qmlString += "       contentHeight: nextlevel.y+nextlevel.height;\n"

    qmlString += "      Column {id: contentColumn;y: 0;width: parent.width;"

    var collectDataString = "function collectData() { var returnedMap = {"

    var stateEditableString = "states: State { name: \"editing\";"

    var fullFormFields = node.fullFormFields;


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

        switch (fieldType) {
        case "combo":
            qmlString += "LabeledComboBoxInput {\n  id: field_" + field + ";\n  title: qsTr(\"" + field + "\");\n   "
            qmlString += "anchors.fill: parent.widths;\n value: node.selectedItem." + field + ";\n"
            qmlString += "model: node.listFromQuery(\"" + fieldStruct["query"]
                    + "\");z:15; editing:false}\n"
            break
        default:
            qmlString += "LabeledTextInput {id: field_" + field
                    + ";\n   anchors.fill: parent.widths;\n  value:  node.selectedItem." + field
                    + ";\n  title: qsTr(\"" + field + "\");\n    editing:false\n}\n"
        }

        stateEditableString += "PropertyChanges { target:field_" + field + ";editing:true }"
        collectDataString += field + ": field_" + field + ".value,"
    }

    if (node.hasImages){
        qmlString +="Label{text: qsTr(\"Images\"); font.pixelSize: 16; font.bold: true;}\n"


        qmlString+= "   ListView {\n" +
                    "       height: CBApi.baseProvider.images.rowCount>1?400:200;\n" +
                    "       width: parent.width;\n" +
                    "       delegate: imageDelegate;\n" +
                    "       model:CBApi.baseProvider.images;\n" +
                    " }\n";


        qmlString += "  Component {\n       id: imageDelegate;\n";

        qmlString += "      Item {\n"+
                     "          width: parent.width;\n"+
                     "          height: 200;\n";
        qmlString += "          Image{ anchors.fill: parent \n" +
                     "          source: \"image://imageProvider/\"+id\n" +
                     "          fillMode: Image.PreserveAspectFit}\n";

        qmlString += "          MouseArea {anchors.fill: parent; onClicked: { mainWindow.showFullImageInfo(index);} }\n";
        qmlString += "       }\n";
        qmlString += "  }\n";
    }

    qmlString += "      }\n" //Column {
    qmlString += "NextLevelList { id:nextlevel; y: contentColumn.childrenRect.height+contentColumn.y }"
    qmlString += "  }\n" //Flickable {

    //stateEditableString += "PropertyChanges { target: nextlevel; visible:false }"
    stateEditableString += "}"
    qmlString += stateEditableString

    collectDataString = collectDataString.substring(
                0, collectDataString.length - 1)
    collectDataString += "}; return returnedMap }"
    qmlString += collectDataString
    qmlString += "}" // mainRect

    if (needCollect) {
        CBApi.baseProvider.saveFullForm(qmlString,node)
    }

    var component = Qt.createQmlObject(qmlString,tablesStack, "dynamicFull");
    component.node = node;

    return component;
}
