function createListForm(node) {

    var qmlString

    qmlString = "import QtQuick 2.5;\n" +
                "import CB.api 1.0;\n" +
                "import CBControls 1.0;\n" +
                "import QtQuick.Controls 2.0\n\n"+
                "Rectangle {\n" +
                "   StackView.onRemoved: destroy() // Will be destroyed sometime after this call." +
                "   Component.onDestruction: console.log(\""+node.listFormName()+" Destruction Beginning!\")\n"+
                "   id: mainRect;\n" +
                "   property int formType: CBApi.ListForm\n" +
                "   property var node;\n"+
                "   onNodeChanged:{listView.model = node.listModel; editable = node.editable;}\n" +
                "   property int firstIndex:-1\n"+
                "   property bool compareMode: false\n" +
                "   property bool editable: true\n"

    qmlString+= "   ListView {\n" +
                "       ScrollBar.vertical: ScrollBar { }\n"+
                "       id:listView;\n" +
                "       anchors.fill: parent;\n" +
                "       delegate: delegate;\n   }\n";


    qmlString += "  Component {\n       id: delegate;\n";

    qmlString += "      Item {\n"+
                 "          id: delegateItem;\n"+
                 "          width: listView.width;\n"+
                 "          height: Math.max(100,topLayout.height+10);\n";

    qmlString += "          BackgroundRect{selected:(index===mainRect.firstIndex)}\n";
    qmlString += "          MouseArea {anchors.fill: parent\n"+
                 "                     onClicked: {\n" +
                 "                                 if (compareMode){\n"+
                 "                                      if (mainRect.firstIndex === -1){\n"+
                 "                                          mainRect.firstIndex = index;\n"+
                 "                                      }\n"+
                 "                                      else{\n"+
                 "                                          mainWindow.showDifference(mainRect.node,mainRect.firstIndex,index);\n"+
                 "                                          mainRect.firstIndex = -1;\n"+
                 "                                          mainRect.compareMode = false;\n"+
                 "                                      }\n"+
                 "                                 }\n"+
                 "                                 else{\n"+
                 "                                      mainWindow.showFullForm(node,index);\n"+
                 "                                 }\n"+
                 "                              }\n"+
                 "          }\n";
    if (node.usesUUIDs){
        qmlString += "        Image {\n"+
                     "            id: image\n"+
                     "            source: \"image://imageProvider/\" + id + \"/Main.jpg\"\n"+
                     "            height: parent.height-10\n"+
                     "            width: Math.min(height*2,parent.width/3)\n"+
                     "            sourceSize.height: height\n"+
                     "            sourceSize.width: width\n"+
                     "            fillMode: Image.PreserveAspectFit\n"+
                     "            anchors.left: parent.left\n"+
                     "            anchors.leftMargin: 5\n"+
                     "            anchors.top: parent.top\n"+
                     "            anchors.topMargin: 5\n"+
                     "            anchors.bottom: parent.bottom\n"+
                     "            anchors.bottomMargin: 5\n"+
                     "            }\n"+
                     "         Text {\n"+
                     "            id: topLayout;\n"+
                     "            anchors.left: image.right\n"+
                     "            anchors.right: parent.right\n"+
                     "            anchors.leftMargin: 5\n"+
                     "            anchors.rightMargin: 5\n"+
                     "            anchors.verticalCenter: parent.verticalCenter\n" +
                     "            text:"
    }
    else{

    qmlString += "          Text {\n"+
                 "              id: topLayout;\n"+
                 "              anchors.centerIn:parent;\n"+
                 "              width: listView.width-10;\n"+
                 "              text:"
        }

    var fieldList = node.listViewFields;
    var arr = [];
    for (var i = 0; i < fieldList.length; ++i) {

        var field = fieldList[i]
        if (field.length !==0){ // FIXME: this if actually always true because it check only that field name is not null
            var str = "";

            if (fieldList.length !== 1) {
                // add field name only if we have more then 1 field in item
                str += "                  \"<b>\"+"
                str += "qsTr(\"" + field + "\")"
                str += "+\":</b>\"+"
            }
            str += field
            arr.push(str)
        }
    }
    qmlString += arr.join("+\"<br>\"+\n") + "\n"
    qmlString += "            wrapMode: Text.Wrap;}\n"

    qmlString += "      }\n" //Item {
    qmlString += "  }\n" //Component {
    qmlString += "}" // mainRect

    var formName = node.listFormName();
    if (needCollect) {
        CBApi.saveForm(qmlString,formName)
    }

    var obj = Qt.createQmlObject(qmlString,tablesStack, formName);
    obj.node = node;

    return obj;
}

function createFullForm(node) {

    var qmlString

    qmlString = "import QtQuick 2.5;\n" +
                "import CB.api 1.0;\n" +
                "import CBControls 1.0;\n" +
                "import QtQuick.Controls 2.0\n\n"+
                "Rectangle {\n" +
                "   StackView.onRemoved: destroy() // Will be destroyed sometime after this call." +
                "   Component.onDestruction: console.log(\""+node.fullFormName()+" Destruction Beginning!\")\n"+
                "   id: mainRect;\n" +
                "   property int formType: CBApi.FullForm\n" +
                "   property var node;\n" +
                "   property bool editable: true\n"

    var onNodeChangedString = "  onNodeChanged:{\n" +
                              "          editable = node.editable\n"

    qmlString += "   Flickable {\n"+
                 "       ScrollBar.vertical: ScrollBar { }\n"+
                 "       clip: true;\n"+
                 "       contentHeight: contentColumn.height\n"+
                 "       anchors.fill:parent;\n";

    qmlString += "       Column {\n" +
                 "            id: contentColumn\n"+
                 "            width: mainRect.width\n"
    if (node.usesUUIDs){
        qmlString += "            Image {\n"+
                     "                  id: image\n"+
                     "                  width: parent.width\n"+
                     "                  height: Math.min(parent.width/2,300)\n"+
                     "                  sourceSize.height: height\n"+
                     "                  sourceSize.width: width\n"+
                     "                  fillMode: Image.PreserveAspectFit\n"+
                     "                  MouseArea {\n"+
                     "                             anchors.fill: parent\n"+
                     "                             onClicked: {\n"+
                     "                                         CBApi.baseProvider.attachmentsProvider.openAttach(\"Main.jpg\")\n"+
                     "                                         }\n"+
                     "                            }\n" +
                     "            }\n";
        onNodeChangedString +="        image.source =  \"image://imageProvider/\"+node.selectedItem.id + \"/Main.jpg\"\n";
    }

    var collectDataString = "    function collectData() {"+
                            "        var returnedMap = {"

    var stateEditableString = "    states: State {\n"+
                              "        name: \"editing\"\n"

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
            qmlString += "            LabeledComboBoxInput {\n"+
                         "                id:" + field_id + ";\n"+
                         "                title: qsTr(\"" + field + "\");\n";

            if (fieldStruct["query"]){
                onNodeChangedString +="        "+ field_id + ".model=node.listFromQuery(\"" + fieldStruct["query"]
                    + "\");\n"
            }
            else{
                qmlString+="                model:" + fieldStruct["list"]
            }
            qmlString += "            }\n"
            collectDataString +="            "+field + ": " + field_id  + ".getValue(),\n"
            onNodeChangedString +="        "+field_id + ".setValue(node.selectedItem." + field + ");\n";
            break
        case "date":
            qmlString += "            LabeledDateInput {\n" +
                         "                id:" + field_id + ";\n"+
                         "                title: qsTr(\"" + field + "\");\n" +
                         "            }\n"

            collectDataString +="            "+field + ": " + field_id  + ".value,\n"
            onNodeChangedString +="        "+field_id + ".value =  node.selectedItem." + field + ";\n";
            break
        case "long text":
            qmlString += "            LabeledLongText {id:" + field_id + ";\n"+
                    "                title: qsTr(\"" + field + "\");\n" +
                    "            }\n"

            collectDataString +="            "+field + ": " + field_id  + ".value,\n"
            onNodeChangedString +="        "+field_id + ".value =  node.selectedItem." + field + ";\n";
            break;

        case "hyperlink":
            qmlString += "            LabeledTextInput {id:" + field_id + ";\n"+
                    "                title: qsTr(\"" + field + "\");\n" +
                    "                linkable: true\n" +
                    "            }\n"

            collectDataString +="            "+field + ": " + field_id  + ".value,\n"
            onNodeChangedString +="        "+field_id + ".value =  node.selectedItem." + field + ";\n";
            break;
        default:
            qmlString += "            LabeledTextInput {id:" + field_id + ";\n"+
                    "                title: qsTr(\"" + field + "\");\n" +
                    "            }\n"

            collectDataString +="            "+field + ": " + field_id  + ".value,\n"
            onNodeChangedString +="        "+field_id + ".value =  node.selectedItem." + field + ";\n";
        }

        // TODO: Do something better that a lot of this property
        stateEditableString += "        PropertyChanges { target:" + field_id  + ";editing:true }\n"
    }

    if (node.usesUUIDs){
        qmlString += "            AttachmentsList{\n"+
                     "                  id:attachList;\n"+
                     "            }\n";
        stateEditableString += "        PropertyChanges {target:attachList;editing:true }\n"
    }


    qmlString += "            NextLevelList {\n"+
                 "                id:nextlevel;\n"+
                 "            }"
    qmlString += "        }\n" //Column {
    qmlString += "    }\n" //Flickable {

    stateEditableString += "        PropertyChanges { target: nextlevel; visible:false }\n"
    stateEditableString += "    }\n\n"
    qmlString += stateEditableString

    onNodeChangedString +="        nextlevel.model = node.nextLevelList}\n\n";
    qmlString += onNodeChangedString;

    //TODO: change this coma deletion to Array.join
    collectDataString = collectDataString.substring(
                0, collectDataString.length - 2) // remove coma and \n
    collectDataString += "\n        }\n"+
                         "        node.applyChanges(returnedMap)\n"+
                         "    }\n"
    qmlString += collectDataString
    qmlString += "}" // mainRect

    var formName =  node.fullFormName()
    if (needCollect) {
        CBApi.saveForm(qmlString,formName)
    }

    var obj = Qt.createQmlObject(qmlString,tablesStack, formName);
    obj.node = node;

    return obj;
}
