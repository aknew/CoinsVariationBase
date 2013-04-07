import QtQuick 1.1

Rectangle {
    id: mainRect
    Flickable {
        clip: true
        anchors.fill:parent
        contentHeight: picture.height+contentColumn.height+nextlevel.height
        ImageWithFullScreen{
            id: picture
            pict:selectedItem.pict
        }
        Column {
            id: contentColumn
            y: picture.height
            width: parent.width
            enabled: false
            TitledInput {
                z:12
                id: inp_status
                anchors.fill: parent.widths
                title: "Статус:"
                text: selectedItem.status
                model: window.listForName("statuses");
            }
            Input {
                id: txt_condition
                anchors.fill: parent.widths
                title: "Сохранность:"
                text: selectedItem.condition
            }
            Input {
                id: txt_comment
                anchors.fill: parent.widths
                title: "Прочее:"
                text: selectedItem.otherInfo
            }
        }
        NextLevelList {
            id:nextlevel
            y: contentColumn.childrenRect.height+contentColumn.y
        }
    }

    states: State {
                    name: "editable";
                    PropertyChanges { target: contentColumn; enabled:true }
                    PropertyChanges { target: nextlevel; visible:false }
                    PropertyChanges { target: picture; editing:true}
                }

    function collectData() {
        var returnedMap = {
            pict: picture.pict,
            otherInfo: txt_comment.text,
            status:inp_status.text,
            condition:txt_condition.text
        }
        return returnedMap
    }
}
