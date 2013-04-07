import QtQuick 1.1

Rectangle {
    id: mainRect
    width: 400
    height: 500
    Flickable {
        clip: true
        anchors.fill:parent
        contentHeight: contentColumn.height
        Column {
            id: contentColumn
            width: parent.width
            ImageWithFullScreen{
                source: "image://imageProvider/" + selectedItem.pict
            }
            Input {
                id: inp_MintYard
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
            NextLevelList {
            }
        }
    }
}

