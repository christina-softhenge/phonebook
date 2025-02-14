import QtQuick

Rectangle {
    implicitWidth: 150
    implicitHeight: 25

    property alias text: input.text
    Flickable {
        id: flick
        topMargin: 4;
        leftMargin: 2;
        anchors.fill: parent
        contentWidth: input.contentWidth
        contentHeight: input.contentHeight
        clip: true

        function ensureVisible(r)
        {
            if (contentX >= r.x)
                contentX = r.x;
            else if (contentX+width <= r.x+r.width)
                contentX = r.x+r.width-width;
            if (contentY >= r.y)
                contentY = r.y;
            else if (contentY+height <= r.y+r.height)
                contentY = r.y+r.height-height;
        }

        TextInput {
            id: input
            leftPadding: 5;
            anchors.fill: parent
            onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
        }

        TapHandler {
            onTapped: input.focus = true
        }
    }
}
