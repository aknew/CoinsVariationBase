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

            Text {
                id: txt_main
                text: selectedItem.year + "  " + selectedItem.mintmark
                font.bold: true
            }
            Input {
                id: txt_avers
                title: "Аверс"
                anchors.fill: parent.widths
                text: selectedItem.avers
            }
            Input {
                id: txt_revers
                anchors.fill: parent.widths
                title: "Реверс:"
                text: selectedItem.revers
            }

            Input {
                id: txt_edge
                anchors.fill: parent.widths
                title: "Гурт:"
                text: selectedItem.edge
            }
            ImageWithFullScreen{
                source: "image://imageProvider/" + selectedItem.pict
            }
            Input {
                id: inp_MintYard
                anchors.fill: parent.widths
                title: "Монетный двор:"
                text: selectedItem.MintYard
            }
            Text {
                text: "Тираж:" + selectedItem.mintage
            }
            Text {
                text: "Цена:" + selectedItem.price
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
