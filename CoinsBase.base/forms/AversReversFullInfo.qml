import QtQuick 1.1

Rectangle {
    id: mainRect
    width: 400
    height: 500
    Flickable {
        clip: true
        anchors.fill:parent
        contentHeight: contentColumn.height+nextlevel.height
        Column {
            id: contentColumn
            width: parent.width
            enabled: false
            ImageWithFullScreen{
                pict:selectedItem.pict
            }
            Input {
                id: inp_Description
                anchors.fill: parent.widths
                title: "Описание:"
                text: selectedItem.description
            }

            Input {
                id: txt_comment
                anchors.fill: parent.widths
                text: selectedItem.comment
                title: "Прочее:"
            }
        }
        NextLevelList {
            id:nextlevel
            y: contentColumn.childrenRect.height+2
        }
    }
    states: State {
                    name: "editable";
                    PropertyChanges { target: contentColumn; enabled:true }
                    PropertyChanges { target: nextlevel; visible:false }
                }

    function collectData() {
        var returnedMap = {
            description:inp_Description.text,
            comment:txt_comment.text
        }
        return returnedMap
    }

}

