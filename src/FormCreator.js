function createListForm(node) {

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
                 "          id: delegateItem;\n"+
                 "          width: listView.width;\n"+
                 "          height: Math.max(100,topLayout.height+10);\n";

    qmlString += "          BackgroundRect{}\n";
    qmlString += "          MouseArea {anchors.fill: parent; onClicked: { mainWindow.showFullForm(node,index);} }\n";
    if (node.usesUUIDs){
        qmlString += "        Image {\n"+
                     "            id: image\n"+
                     "            source: \"image://imageProvider/\" + id + \"/Main.jpg\"\n"+
                     "            height: parent.height-10\n"+
                     "            width: height*2\n"+
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
        if (field.length !==0){
            var str = "";

            if (fieldList.length !== 1) {
                // add field name only if we have more then 1 field in item
                str += " \"<b>\"+"
                str += "qsTr(\"" + field + "\")"
                str += "+\":</b>\"+"
            }
            str += field
            arr.push(str)
        }
    }
    qmlString += arr.join("+\"<br>\"+\n") + "\n"
    qmlString += "              wrapMode: Text.Wrap;}\n"

    qmlString += "      }\n" //Item {
    qmlString += "  }\n" //Component {
    qmlString += "}" // mainRect

    if (needCollect) {
        CBApi.baseProvider.saveListForm(qmlString,node)
    }

    component = Qt.createQmlObject(qmlString,tablesStack, node.listFormName());
    component.node = node;

    return component;
}

function createFullForm(node) {

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

    qmlString += "   ScrollView {\n"+
                 "       clip: true;\n"+
                 "       anchors.fill:parent;\n";

    qmlString += "       Column {\n" +
                 "            id: contentColumn\n"+
                 "            width: mainRect.width - 20\n"
    if (node.usesUUIDs){
        qmlString += "            Image {\n"+
                     "                  id: image\n"+
                     "                  width: parent.width\n"+
                     "                  height: Math.min(parent.width/2,300)\n"+
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
                              "        name: \"editing\";"

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
            collectDataString +="            "+field + ": " + field_id  + ".getValue(),"
            onNodeChangedString +="        "+field_id + ".setValue(node.selectedItem." + field + ");\n";
            break
        case "date":
            qmlString += "            LabeledDateInput {\n" +
                         "                id:" + field_id + ";\n"+
                         "                title: qsTr(\"" + field + "\");\n" +
                         "            }\n"

            collectDataString +="            "+field + ": " + field_id  + ".value,"
            onNodeChangedString +="        "+field_id + ".value =  node.selectedItem." + field + ";\n";
            break
        case "long text":
            qmlString += "            LabeledLongText {id:" + field_id + ";\n"+
                    "                title: qsTr(\"" + field + "\");\n" +
                    "            }\n"

            collectDataString +="            "+field + ": " + field_id  + ".value,"
            onNodeChangedString +="        "+field_id + ".value =  node.selectedItem." + field + ";\n";
            break;

        case "hyperlink":
            qmlString += "            LabeledTextInput {id:" + field_id + ";\n"+
                    "                title: qsTr(\"" + field + "\");\n" +
                    "                linkable: true\n" +
                    "            }\n"

            collectDataString +="            "+field + ": " + field_id  + ".value,"
            onNodeChangedString +="        "+field_id + ".value =  node.selectedItem." + field + ";\n";
            break;
        default:
            qmlString += "            LabeledTextInput {id:" + field_id + ";\n"+
                    "                title: qsTr(\"" + field + "\");\n" +
                    "            }\n"

            collectDataString +="            "+field + ": " + field_id  + ".value,"
            onNodeChangedString +="        "+field_id + ".value =  node.selectedItem." + field + ";\n";
        }

        // TODO: Do something better that a lot of this property
        stateEditableString += "        PropertyChanges { target:" + field_id  + ";editing:true }"
    }

    if (node.usesUUIDs){
        qmlString += "            AttachmentsList{\n"+
                     "                  id:attachList;\n"+
                     "            }\n";
        stateEditableString += "        PropertyChanges {target:attachList;editing:true }"
    }


    qmlString += "            NextLevelList {\n"+
                 "                id:nextlevel;\n"+
                 "            }"
    qmlString += "        }\n" //Column {
    qmlString += "    }\n" //Flickable {

    stateEditableString += "        PropertyChanges { target: nextlevel; visible:false }"
    stateEditableString += "}\n\n"
    qmlString += stateEditableString

    onNodeChangedString +="        nextlevel.model = node.nextLevelList}\n\n";
    qmlString += onNodeChangedString;

    //TODO: change this coma deletion to Array.join
    collectDataString = collectDataString.substring(
                0, collectDataString.length - 1)
    collectDataString += "        }\n"+
                         "        node.applyChanges(returnedMap)\n"+
                         "    }\n"
    qmlString += collectDataString
    qmlString += "}" // mainRect

    if (needCollect) {
        CBApi.baseProvider.saveFullForm(qmlString,node)
    }

    component = Qt.createQmlObject(qmlString,tablesStack, node.fullFormName());
    component.node = node;

    return component;
}

function createMenu(){
    var menuName = Qt.platform.os == "android" ? "AndroidMenu.qml":"DesktopMenu.qml"
    var component = Qt.createComponent(menuName)
    switch (component.status) {
    case Component.Ready:
        var menu = component.createObject()
        return menu;
    case Component.Error:
        console.log(component.errorString())
        break
    }
}
