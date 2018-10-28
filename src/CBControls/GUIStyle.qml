import QtQuick 2.5
pragma Singleton

QtObject {
    // XXX: actually, I don't check it with iOs
    property bool isMobile: Qt.platform.os == "android"
                            || Qt.platform.os == "ios"
    property int barHeight: isMobile ? 100 : 50
    property bool isWindows: Qt.platform.os == "windows"
}
