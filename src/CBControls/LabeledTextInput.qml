import QtQuick 2.3
import QtQuick.Controls 1.4

FocusScope {
    width: parent.width
    height:titleLabel.height + input.height
    signal
    accepted
    property alias value: input.text
    property alias title: titleLabel.text
    property alias editing: input.enabled
    Label {
        id: titleLabel
        text: ""
        font.pixelSize: 16
        font.bold: true
    }
    TextArea{
        id: input
        font.pixelSize: 16
        width: parent.width
        anchors.top: titleLabel.bottom
        wrapMode: Text.Wrap
        height: 44
    }
}
