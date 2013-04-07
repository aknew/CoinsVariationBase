import QtQuick 1.1

Rectangle {
    id: mainRect
    Flickable {
        clip: true
        anchors.fill:parent
        contentHeight: contentColumn.height
        Column {
            //Rectangle{
            id: contentColumn
            width: parent.width

            ImageWithFullScreen{
                source: "image://imageProvider/" + selectedItem.pict
            }
            Text {
                text: "Статус:" + selectedItem.status
            }
            Text {
                text: "Сохранность:" + selectedItem.condition
            }
            Input {
                id: txt_comment
                anchors.fill: parent.widths
                title: "Прочее:"
                text: selectedItem.otherInfo
            }
            NextLevelList {
            }
        }
    }
}
