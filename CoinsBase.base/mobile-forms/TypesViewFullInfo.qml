import QtQuick 1.1

Rectangle {
    id: mainRect
    Column {
        anchors.fill: parent
        Text {
            id: txt_nominal
            text: selectedItem.nominal + " обр. " + selectedItem.firstYear
                  + " - " + selectedItem.lastYear
            font.bold: true
        }
        Text {
            id: txt_metal
            //text: "Металл: " +myModel[window.currentIndex()].metal
            text: "Металл: " + selectedItem.metal
        }

        Text {
            id: txt_issue
            text: "Выпуск: " + selectedItem.issue
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
        Input {
            id: txt_edge
            anchors.fill: parent.widths
            title: "Гурт:"
            text: selectedItem.edge
        }
        Input {
            id: txt_comment
            anchors.fill: parent.widths
            title: "Прочее:"
            text: selectedItem.comment
        }
        NextLevelList {
        }
    }
    function collectData() {
        console.log("into collectData")
        console.log(txt_edge.text)
        //console.log(selectedItem.edge)
        //selectedItem.edge=txt_edge.text;
        //console.log(selectedItem.edge)
        var returnedMap = {
            edge: txt_edge.text,
            avers: txt_avers.text,
            revers: txt_revers.text
        }
        return returnedMap
    }
}
