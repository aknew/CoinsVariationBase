import QtQuick 2.0

Text {
    // HOTFIX: Windows default fonts doesn't have some unicode glyph, so I added titles an font size based on text length
    // I will redraw this app in future, so I don't wont to spend time for fix this trouble right now
    font.pointSize: text.length < 3 ? 18 : 10
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
}
