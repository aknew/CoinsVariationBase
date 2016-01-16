import QtQuick 2.5
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4

import CB.api 1.0

Rectangle {
    width: parent.width
    height: 500
    Rectangle{
        id: attachBar
        width: parent.width
        height: 100
        anchors.top:parent.top
        Button{
            id: btnAddField
            iconSource: "/icons/add.png"
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top:parent.top
            anchors.topMargin: 5
            height:parent.height - 10
            width: parent.height - 10
            onClicked:{
                attachDialog.open()
            }
        }
    }
    ListView {
        id: attachmentsListView
        clip: true
        width: parent.width
        anchors.top: attachBar.bottom
        height: 400
        model: CBApi.baseProvider.attachmentsProvider.attributes
        delegate: Rectangle {
            width: parent.width
            height: 100
            BackgroundRect {
            }
            Row {
                anchors.topMargin: 5
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.fill: parent
                Image{
                    width: 90
                    height: 90
                    source: "image://imageProvider/" + modelData.file
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    text: modelData.about === undefined ? modelData.file : modelData.about
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

    FileDialog {
        id: attachDialog
        modality: Qt.WindowModal
        title: qsTr("Choose a file to load as attach")
        selectMultiple: false
        onAccepted: {
            var modelData = CBApi.baseProvider.attachmentsProvider.insertNewAttach(fileUrls[0])
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
