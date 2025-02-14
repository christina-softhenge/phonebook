import QtQuick

Rectangle {
    implicitWidth: 150
    implicitHeight: 25
    property alias text: input.text


    onHeightChanged: {
        console.log("height", height, implicitHeight, width, implicitWidth)
    }

    Flickable {
        id: flick
        topMargin: 4
        leftMargin: 2
        anchors.fill: parent
        contentWidth: input.contentWidth
        contentHeight: input.contentHeight
        clip: true

        function ensureVisible(rect)
        {
            if (contentX >= rect.x)
                contentX = rect.x
            else if (contentX + width <= rect.x + rect.width)
                contentX = rect.x + rect.width - width
            if (contentY >= rect.y)
                contentY = rect.y
            else if (contentY + height <= rect.y + rect.height)
                contentY = rect.y + rect.height - height
        }

        TextInput {
            id: input
            leftPadding: 5
            anchors.fill: parent
            activeFocusOnPress: true
            onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
        }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            input.forceActiveFocus()
        }
    }
}
