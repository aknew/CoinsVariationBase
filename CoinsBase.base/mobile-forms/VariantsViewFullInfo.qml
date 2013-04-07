import QtQuick 1.1

Rectangle {
    id: mainRect
    Flickable {
        clip: true
        anchors.fill: parent
        contentHeight: contentColumn.height
        Column {
            id: contentColumn
            width: parent.width

            ImageWithFullScreen {
                source: "image://imageProvider/" + selectedItem.pict
            }
            Input {
                id: txt_avers
                anchors.fill: parent.widths
                text: selectedItem.avers
                title: "Аверс:"
            }
            Input {
                id: txt_revers
                anchors.fill: parent.widths
                text: selectedItem.revers
                title: "Реверс:"
            }
            Input {
                id: txt_edge
                anchors.fill: parent.widths
                text: selectedItem.edge
                title: "Гурт:"
            }
            Input {
                id: inp_MintYard
                anchors.fill: parent.widths
                text: selectedItem.MintYard
                title: "Монетный двор:"
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
