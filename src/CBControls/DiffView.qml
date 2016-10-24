import QtQuick 2.5
import QtQuick.Controls 2.0

Page {
    header:ToolBar{
        ToolButton {
            anchors.left: parent.left
            anchors.leftMargin: 5
            height: parent.height
            width: parent.height
            visible: tablesStack.depth > 1
            contentItem: Image {
                source: "/merge"
                fillMode: Image.Pad
            }
            onClicked: {
                mergedMap = {}
                diff1 = ""
                diff2 = ""
                index = 0
                mergeNext()
            }
        }
    }

    property string diff1: ""
    property string diff2: ""
    property var mergedMap
    property int index:0

    function mergeNext(){
        if (index < itemDifference.allFieldsModel.length) {
            var fd = itemDifference.allFieldsModel[index]
            ++index
            if (fd.isEqual){
                mergedMap[fd.name]=fd.highlightedFirst;
                mergeNext()
            }
            else{
                rowMergeDialog.name = fd.name;
                rowMergeDialog.record1 = fd.highlightedFirst;
                rowMergeDialog.record2 = fd.highlightedSecond;
                rowMergeDialog.result = fd.commonPart;
                rowMergeDialog.open();
                diff1 += qsTr(fd.name) +": " + fd.differenceFirst +";";
                diff2 += qsTr(fd.name) +": " + fd.differenceSecond +";";

            }

        }
        else{
            rowMergeDialog.close()
            diffDialog.diff1 = diff1;
            diffDialog.diff2 = diff2;
            diffDialog.open()
        }
    }

    Popup {
        id: rowMergeDialog
        property string name
        onNameChanged: {
            title.text = qsTr("Merged field: ") + qsTr(name)
        }

        property string record1
        onRecord1Changed: {
            edtRecord1.text = qsTr("Record 1: ")+ record1
        }

        property string record2
        onRecord2Changed: {
            edtRecord2.text = qsTr("Record 2: ")+ record2
        }

        property alias result:edtResult.value

        contentItem: Rectangle {
            implicitWidth: 600
            implicitHeight: 400
            Column {
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.bottom: btnApply.top
                anchors.bottomMargin: 5
                width: parent.width
                spacing: 5
                Label {
                    id: title
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                }
                Label {
                    id: edtRecord1
                }
                Label {
                    id: edtRecord2
                }
                LabeledTextInput {
                    id: edtResult
                    title: qsTr("Merge result:")
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
                    mergedMap[rowMergeDialog.name] = edtResult.value
                    mergeNext()
                }
            }
        }
    }

    Popup {
        id: diffDialog
        property string diff1
        onDiff1Changed: {
            edtDiff1.text = qsTr("Diff 1: ")+ diff1
        }

        property string diff2
        onDiff2Changed: {
            edtDiff2.text = qsTr("Diff 2: ")+ diff2
            edtResultDiff.value = diff2
        }

        property alias result:edtResult.value

        contentItem: Rectangle {
            implicitWidth: 600
            implicitHeight: 400
            Column {
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.bottom: btnApplyDiff.top
                anchors.bottomMargin: 5
                width: parent.width
                spacing: 5
                Label {
                    id: edtDiff1
                }
                Label {
                    id: edtDiff2
                }
                LabeledTextInput {
                    id: edtResultDiff
                    title: qsTr("Result diff:")
                    editing: true
                }
            }

            Button {
                id: btnApplyDiff
                width: (parent.width - 15) / 2
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                text: qsTr("Apply")
                onClicked: {
                    diffDialog.close()
                    node.mergeRecords(itemDifference.id2, itemDifference.id1, mergedMap, edtResultDiff.value);
                    mainWindow.goBack();
                }
            }
        }
    }

    property var node
    property var itemDifference
    onItemDifferenceChanged: {
        if (typeof (itemDifference) != "undefined") {
            listView.model = itemDifference.diffFieldsModel
            image1.source = "image://imageProvider/" + itemDifference.id1 + "/Main.jpg"
            image2.source = "image://imageProvider/" + itemDifference.id2 + "/Main.jpg"
        }
    }

    Image {
        id: image1
        width: parent.width / 2 - 15
        height: width / 2
        fillMode: Image.PreserveAspectFit
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.top: parent.top
        anchors.topMargin: 5
    }
    Image {
        id: image2
        width: parent.width / 2 - 15
        height: width / 2
        fillMode: Image.PreserveAspectFit
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.top: parent.top
        anchors.topMargin: 5
    }
    ComboBox {
        id: diffMode
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.top: image1.bottom
        anchors.topMargin: 5
        model: [qsTr("Show different fields"), qsTr("Show all fields")]
        onCurrentIndexChanged: {
            if (typeof (itemDifference) == "undefined") {
                return
            }
            if (currentIndex == 0) {
                listView.model = itemDifference.diffFieldsModel
            } else {
                listView.model = itemDifference.allFieldsModel
            }
        }
    }

    ListView {
        id: listView
        clip: true
        ScrollBar.vertical: ScrollBar {
        }
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.top: diffMode.bottom
        anchors.topMargin: 5
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        delegate: delegate
        Component {
            id: delegate
            Item {
                id: delegateItem
                width: listView.width
                height: rectName.height + Math.max(lbl1.height,
                                                   lbl2.height) + 15
                Rectangle {
                    id: rectName
                    color: "lightgray"
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    anchors.right: parent.right
                    height: lblName.height + 10
                    Text {
                        id: lblName
                        text: qsTr(modelData.name) + ":"
                        font.bold: true
                        anchors.centerIn: parent
                    }
                }
                Text {
                    id: lbl1
                    text: modelData.highlightedFirst
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.top: rectName.bottom
                    anchors.topMargin: 5
                    width: parent.width / 2 - 10
                    wrapMode: Text.Wrap
                }
                Text {
                    id: lbl2
                    text: modelData.highlightedSecond
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.top: rectName.bottom
                    anchors.topMargin: 5
                    width: parent.width / 2 - 10
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
