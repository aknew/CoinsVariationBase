import QtQuick 2.0

Rectangle {
    id: mainRect
    width: 400
    height: 500
    Flickable {
        clip: true
        anchors.fill:parent
        contentHeight: contentColumn.height+nextlevel.height
        ImageWithFullScreen{
            id: picture
            pict:selectedItem.pict
        }
        Column {
            id: contentColumn
            y: picture.height
            width: parent.width
            enabled: false
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
            anchors.top: contentColumn.bottom
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
            description:inp_Description.text,
            comment:txt_comment.text,
            pict: picture.pict,
        }
        return returnedMap
    }

}

