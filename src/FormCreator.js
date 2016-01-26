function createListForm(node) {
    var qmlString

    qmlString = "import QtQuick 2.0;\n" +
                "import CB.api 1.0;\n" +
                "import CBControls 1.0;\n" +
                "Rectangle {\n" +
                "   id: mainRect;\n" +
                "   property var formType: CBApi.ListForm\n" +
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

    if (node.useListForm){
        var component = Qt.createComponent("file:///" + CBApi.baseProvider.listFormPath(node))
        switch (component.status) {
        case Component.Ready:
            var form = component.createObject()
            form.node = node;
            return form;
        case Component.Error:
            console.log(component.errorString())
            return;
        }
    }

    var qmlString

    qmlString = "import QtQuick 2.0;\n" +
                "import CB.api 1.0;\n" +
            "import QtQuick.Controls 1.2\n\n"+
            "Rectangle {\n" +
            "   id: mainRect;\n" +
            "   property var formType: CBApi.ListForm\n" +
            "   property var node;\n"+
            "   onNodeChanged:{tableView.model = node.listModel;}\n\n"+
            "   TableView {\n       id:tableView;\n        anchors.fill:parent;\n" +
            "       onClicked: { mainWindow.showFullForm(node,row);}\n\n"+
            "       function applySort(){\n"+
            "           var column = getColumn(sortIndicatorColumn).role;\n"+
            "           model.sortByColumn(column,sortIndicatorOrder);\n"+
            "           sortIndicatorVisible = true;\n       }"+
            "       onSortIndicatorColumnChanged:applySort()\n"+
            "       onSortIndicatorOrderChanged:applySort()\n";


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

    //TODO: check dynamic model for indents
    if (node.useFullForm){
        var component = Qt.createComponent("file:///" + CBApi.baseProvider.fullFormPath(node))
        switch (component.status) {
        case Component.Ready:
            var form = component.createObject()
            form.node = node;
            return form;
        case Component.Error:
            console.log(component.errorString())
            return;
        }
    }


    var qmlString

    qmlString = "import QtQuick 2.0;\n" +
                "import CB.api 1.0;\n" +
                "import CBControls 1.0;\n" +
                "import QtQuick.Controls 1.4\n\n"+
                "Rectangle {\n" +
                "   id: mainRect;\n" +
                "   property var formType: CBApi.FullForm\n" +
                "   property var node;\n";

    var onNodeChangedString = "  onNodeChanged:{\n";

    qmlString += "  Flickable {\n"+
                 "       clip: true;\n"+
                 "       anchors.fill:parent;\n";

    qmlString += "       contentHeight: contentColumn.height + nextlevel.height;\n"

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

        var field_id = "field_" + field;

        switch (fieldType) {
        case "combo":
            qmlString += "LabeledComboBoxInput {\n  id:" + field_id + ";\n  title: qsTr(\"" + field + "\");\n   "
            qmlString += "anchors.fill: parent.widths;\n z:15;\n editing:false \n}\n"
            onNodeChangedString += field_id + ".model=node.listFromQuery(\"" + fieldStruct["query"]
                    + "\");\n"
            break
        case "date":
            qmlString += "LabeledDateInput {\n  id:" + field_id + ";\n  title: qsTr(\"" + field + "\");\n   "
            qmlString += "anchors.fill: parent.widths;\n z:15;\n editing:false \n}\n"
            break
        default:
            qmlString += "LabeledTextInput {id:" + field_id
                    + ";\n   anchors.fill: parent.widths;\n"
                    + "title: qsTr(\"" + field + "\");\n    editing:false\n}\n"
        }
        // TODO: Do something better that a lot of this property
        stateEditableString += "PropertyChanges { target:" + field_id  + ";editing:true }"
        collectDataString += field + ": " + field_id  + ".value,"
        onNodeChangedString +=field_id + ".value =  node.selectedItem." + field + ";\n";
    }

    if (node.usesUUIDs){
        qmlString += "AttachmentsList{id:attachList}";
        stateEditableString += "PropertyChanges { target:attachList;editing:true }"
    }

    qmlString += "      }\n" //Column {
    qmlString += "NextLevelList { id:nextlevel; y: contentColumn.childrenRect.height+contentColumn.y }"
    qmlString += "  }\n" //Flickable {

    stateEditableString += "PropertyChanges { target: nextlevel; visible:false }"
    stateEditableString += "}\n\n"
    qmlString += stateEditableString

    onNodeChangedString +="nextlevel.model = node.nextLevelList}\n\n";
    qmlString += onNodeChangedString;

    //FIXME: change string this coma deletion to Array.join
    collectDataString = collectDataString.substring(
                0, collectDataString.length - 1)
    collectDataString += "}; node.applyChanges(returnedMap); }"
    qmlString += collectDataString
    qmlString += "}" // mainRect

    if (needCollect) {
        CBApi.baseProvider.saveFullForm(qmlString,node)
    }

    component = Qt.createQmlObject(qmlString,tablesStack, "dynamicFull");
    component.node = node;

    return component;
}
