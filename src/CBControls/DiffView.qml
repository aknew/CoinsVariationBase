import QtQuick 2.5
import QtQuick.Controls 2.0
import Qt.labs.platform 1.1
import QtQuick.Layouts 1.1

Page {
    id: diffView
    header: ToolBar {
        ToolButton {
            anchors.left: parent.left
            anchors.leftMargin: 5
            height: parent.height
            width: parent.height
            visible: tablesStack.depth > 1
            contentItem: ToolbarContextItem{
                text: '⬅'
            }
            //shortcut: Qt.BackButton
            onClicked: mainWindow.goBack()
        }
        ToolButton {
            anchors.right: mergeButton.left
            anchors.rightMargin: 5
            height: parent.height
            width: parent.height
            contentItem: ToolbarContextItem{
                text: '⚙'
            }
            onClicked:{settingsPopup.open()}
        }
        ToolButton {
            id: mergeButton
            anchors.right: parent.right
            anchors.rightMargin: 5
            height: parent.height
            width: parent.height
            contentItem: ToolbarContextItem{
                text: '🔗'
            }
            onClicked: {
                mergedMap = {

                }
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
    property int index: 0

    function mergeNext() {
        if (index < itemDifference.allFieldsModel.length) {
            var fd = itemDifference.allFieldsModel[index]
            ++index
            if (fd.isEqual) {
                mergedMap[fd.name] = fd.highlightedFirst
                mergeNext()
            } else {
                rowMergeDialog.fieldDifference = fd
                rowMergeDialog.open()
                diff1 += qsTr(fd.name) + ": " + fd.differenceFirst + ";"
                diff2 += qsTr(fd.name) + ": " + fd.differenceSecond + ";"
            }
        } else {
            rowMergeDialog.close()
            diffDialog.diff1 = diff1
            diffDialog.diff2 = diff2
            diffDialog.open()
        }
    }

    Popup{
        id: settingsPopup
        contentItem: ColumnLayout{
            width:250
            LabeledTextInput {
                id: separator
                title: qsTr("Separator:")
                value:" "
                editing: true
            }
            LabeledTextInput {
                id: joinSeparator
                title: qsTr("Join with:")
                value:" "
                editing: true
            }
            Button{
                text: qsTr("Apply")
                onClicked: {
                    itemDifference.recalculateDifferences(separator.value,joinSeparator.value);
                    listView.model = itemDifference.diffFieldsModel;
                    settingsPopup.close();
                }
            }
        }
    }

    Popup {
        id: rowMergeDialog
        property var fieldDifference
        onFieldDifferenceChanged: {
            title.text = qsTr("Merged field: ") + qsTr(fieldDifference.name)
            edtRecord1.text = "<b>" + qsTr(
                        "Record 1:") + " </b>" + fieldDifference.highlightedFirst
            edtRecord2.text = "<b>" + qsTr(
                        "Record 2:") + " </b>" + fieldDifference.highlightedSecond
            edtResult.value = fieldDifference.commonPart
        }

        contentItem: Rectangle {
            implicitWidth: diffView.width
            implicitHeight: diffView.height
            ColumnLayout {
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
                RowLayout {
                    height: edtRecord1.height
                    width: parent.width
                    Label {
                        width: parent.width
                        id: edtRecord1
                        wrapMode: Text.Wrap
                    }
                    Button {
                        text: qsTr("Use as result")
                        onClicked: {
                            edtResult.value = rowMergeDialog.fieldDifference.originalFirst
                        }
                    }
                }
                RowLayout {
                    height: edtRecord1.height
                    Label {
                        width: parent.width
                        id: edtRecord2
                        wrapMode: Text.Wrap
                    }
                    Button {
                        text: qsTr("Use as result")
                        onClicked: {
                            edtResult.value = rowMergeDialog.fieldDifference.originalSecond
                        }
                    }
                }
                LabeledLongText {
                    id: edtResult
                    title: qsTr("Merge result:")
                    editing: true
                }
            }

            Button {
                id: btnApply
                width: (parent.width - 15) / 2
                anchors.horizontalCenter: parent.horizontalCenter
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
            edtDiff1.text = "<b>" + qsTr("Record 1:") + " </b>" + diff1
        }

        property string diff2
        onDiff2Changed: {
            edtDiff2.text = "<b>" + qsTr("Record 2:") + " </b>" + diff2
            edtResultDiff.value = diff2
        }

        property alias result: edtResult.value

        contentItem: Rectangle {
            implicitWidth: diffView.width
            implicitHeight: diffView.height
            Column {
                anchors.top: parent.top
                anchors.topMargin: 5
                anchors.bottom: btnApplyDiff.top
                anchors.bottomMargin: 5
                width: parent.width
                spacing: 5
                Label {
                    text: qsTr("Difference description")
                    font.bold: true
                }
                Label {
                    id: edtDiff1
                }
                Label {
                    id: edtDiff2
                }
                LabeledLongText {
                    id: edtResultDiff
                    title: qsTr("Result diff:")
                    editing: true
                }
            }

            Button {
                id: btnApplyDiff
                width: (parent.width - 15) / 2
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                text: qsTr("Apply")
                onClicked: {
                    diffDialog.close()
                    var flag = node.mergeRecords(itemDifference.id2,
                                                 itemDifference.id1, mergedMap,
                                                 edtResultDiff.value)
                    if (flag) {
                        mainWindow.goBack()
                    } else {
                        dlgMergeError.open()
                    }
                }
            }
        }
    }

    MessageDialog {
        id: dlgMergeError
        text: qsTr("Record merging finishes with errors, see log for details")
        buttons: StandardButton.Ok
    }

    property var node
    property var itemDifference
    onItemDifferenceChanged: {
        if (typeof (itemDifference) != "undefined") {
            listView.model = itemDifference.diffFieldsModel
            image1.source = "image://imageProvider/" + itemDifference.id1 + "/main.thumbnail.jpg"
            image2.source = "image://imageProvider/" + itemDifference.id2 + "/main.thumbnail.jpg"
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
