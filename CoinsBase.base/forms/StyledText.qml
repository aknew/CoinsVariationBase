import QtQuick 2.0

//Данный компонент служит просто для вынесения настроек текста в один вид
Text {
    property string title: ""
    property string mainText: ""
    text: "<b>"+title+"</b>"+mainText
    width: parent.width
    wrapMode: Text.Wrap
    visible: mainText.length > 0
}
