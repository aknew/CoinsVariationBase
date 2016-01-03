import QtQuick 2.3

import CB.api 1.0

Rectangle {

    property var attachmentInfo

    onAttachmentInfoChanged: {
        for (var name in attachmentInfo) {
            addInfoField(name,attachmentInfo[name])
        }
    }

    function addInfoField(name, value) {
        var val ={'name':name,'value':value}
        listModel.append(val)
    }

    ListModel {
        id: listModel
    }

    ListView {
        id: attachmentsInfoListView
        clip: true
        width: parent.width
        height: 500
        model: listModel
        delegate: Text {
            text: "<b>" + name + ":</b> " + value
        }
    }
}
