import QtQuick 2.3

import CB.api 1.0

Rectangle {
    width: parent.width
    height: 500
    ListView {
        id: attachmentsListView
        clip: true
        width: parent.width
        height: 500
        model: CBApi.baseProvider.attachmentsProvider.attributes
        delegate: Rectangle {
            width: parent.width
            height: 100
            BackgroundRect {
            }
            Row {
                anchors.fill: parent
                //Image{ // In future there will be icon or image
                Rectangle {
                    color: "red"
                    width: 100
                    height: 100
                }
                Text {
                    text: modelData.about
                }
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    var component = Qt.createComponent("AttachmentFullInfo.qml")
                    switch (component.status){
                    case Component.Ready:
                        var form = component.createObject()
                        form.attachmentInfo = modelData
                        mainWindow.pushToStackView(form)
                        break;

                    case Component.Error:
                        console.log(component.errorString());
                        break;

                    }
                }
            }
        }
    }
}
