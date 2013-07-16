import QtQuick 2.0

Rectangle {
    id: mainRect
    Column {
        id: contentColumn
        enabled: false
        anchors.fill: parent
        spacing: 2
        Row {
            z:15
            spacing: 2
            ComboBox{
                id: txt_nominal
                text: selectedItem.nominal
                model: window.listForName("nominals");
            }
            Text {
                text: " обр. "
                font.pixelSize: 16
                height: txt_lastYear.height
                verticalAlignment: Text.AlignVCenter
            }
            StyledTextInput {
                id: txt_firstYear
                text: selectedItem.firstYear
                maximumLength: 4
                width: 50
            }
            Text {
                text: "-"
                font.pixelSize: 16
                height: txt_lastYear.height
                verticalAlignment: Text.AlignVCenter
            }
            StyledTextInput {
                id: txt_lastYear
                text: selectedItem.lastYear
                maximumLength: 4
                width: 50
            }
        }
        TitledInput {
            z:14
            id: txt_metal
            title: "Металл: "
            text: selectedItem.metal
            model: window.listForName("metals");
        }

        TitledInput {
            z:13
            id: txt_issue
            title: "Выпуск: "
            text: selectedItem.issue
            model: window.listForName("issues");
        }
        Input {
            id: txt_avers
            anchors.fill: parent.widths
            title: "Аверс:"
            text: selectedItem.avers
        }
        Input {
            id: txt_revers
            anchors.fill: parent.widths
            title: "Реверс:"
            text: selectedItem.revers
        }
        TitledInput {
            z:12
            id: txt_edge
            anchors.fill: parent.widths
            title: "Гурт:"
            text: selectedItem.edge            
            model: window.listForName("edges");
        }
        Input {
            id: txt_comment
            anchors.fill: parent.widths
            title: "Прочее:"
            text: selectedItem.comment
        }
    }
    NextLevelList {
        id:nextlevel
        y: contentColumn.childrenRect.height+2
    }
    states: State {
                    name: "editable";
                    PropertyChanges { target: contentColumn; enabled:true }
                    PropertyChanges { target: nextlevel; visible:false }
                }

    function collectData() {
        var returnedMap = {
            nominal: txt_nominal.text,
            lastYear: txt_lastYear.text,
            firstYear: txt_firstYear.text,
            metal: txt_metal.text,
            issue: txt_issue.text,
            edge: txt_edge.text,
            avers: txt_avers.text,
            revers: txt_revers.text,
            comment: txt_comment.text
        }
        return returnedMap
    }
}
