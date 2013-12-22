import QtQuick 2.0
import CVBControls 1.0

Rectangle {
    id: mainRect
    Flickable {
        clip: true
        anchors.fill: parent
        contentHeight: picture.height + contentColumn.height + nextlevel.height
        ImageWithFullScreen {
            id: picture
            pict: selectedItem.pict
        }
        Column {
            id: contentColumn
            y: picture.height
            width: parent.width
            enabled: false
            TitledInput {
                id: txt_avers
                title: "Аверс"
                anchors.fill: parent.widths
                text: selectedItem.avers
                model: window.listForName("variantAvers")
                z: 15
            }
            TitledInput {
                id: txt_revers
                anchors.fill: parent.widths
                title: "Реверс:"
                text: selectedItem.revers
                model: window.listForName("variantRevers")
                z: 14
            }

            TitledInput {
                z: 13
                id: txt_edge
                anchors.fill: parent.widths
                title: "Гурт:"
                text: selectedItem.edge
                model: window.listForName("edges")
            }
            TitledInput {
                z: 12
                id: inp_MintYard
                anchors.fill: parent.widths
                title: "Монетный двор:"
                text: selectedItem.MintYard
                model: window.listForName("MintYard")
            }
            Row {
                spacing: 2
                Text {
                    text: "Тираж:"
                    font.pixelSize: 16
                }
                StyledTextInput {
                    id: txt_mintage
                    text: selectedItem.mintage
                    width: 150
                }
            }
            Row {
                spacing: 2
                Text {
                    text: "Цена:"
                    font.pixelSize: 16
                }
                StyledTextInput {
                    id: txt_price
                    text: selectedItem.price
                    width: 100
                }
            }
            Input {
                id: txt_comment
                anchors.fill: parent.widths
                text: selectedItem.comment
                title: "Прочее:"
            }
        }
        NextLevelList {
            id: nextlevel
            y: contentColumn.childrenRect.height + contentColumn.y
        }
    }
    states: State {
        name: "editable"
        PropertyChanges {
            target: contentColumn
            enabled: true
        }
        PropertyChanges {
            target: nextlevel
            visible: false
        }
        PropertyChanges {
            target: picture
            editing: true
        }
    }

    function collectData() {
        var returnedMap = {
            pict: picture.pict,
            edge: txt_edge.text,
            avers: txt_avers.text,
            revers: txt_revers.text,
            comment: txt_comment.text,
            MintYard: inp_MintYard.text,
            mintage: txt_mintage.text,
            price: txt_price.text
        }
        return returnedMap
    }
}
