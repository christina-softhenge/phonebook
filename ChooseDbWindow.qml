import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

Dialog {
    id: chooseDBWindow
    width: 250
    height: 180
    modal: true
    closePolicy: Dialog.CloseOnEscape
    property real startX
    property real startY
    property var chosenDb: 0
    property bool dbIsSet: false

    onOpened: {
        x = (root.width - width) / 2
        y = (root.height - height) / 2
        dbwarningText.text = ""
    }

    Rectangle {
        id: titleBar
        width: parent.width
        height: 30
        color: "#f0f0f0"
        border.color: "#ccc"
        anchors.top: parent.top

        Text {
            anchors.centerIn: parent
            text: "Select Database"
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            onPressed: function(event) {
                chooseDBWindow.startX = event.x
                chooseDBWindow.startY = event.y
            }
            onPositionChanged: function(event) {
                chooseDBWindow.x += event.x - chooseDBWindow.startX
                chooseDBWindow.y += event.y - chooseDBWindow.startY
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: titleBar.height
        border.color: "lightgrey"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text {
                id: dbwarningText
                color: "red"
                text: ""
                visible: text.length > 0
            }

            ComboBox {
                id: dbCombo
                Layout.fillWidth: true
                property int chosenDb: 0
                model: [ "MySQL", "SQLite" ]
                onCurrentIndexChanged: chosenDb = currentIndex
            }

            Button {
                text: "OK"
                Layout.alignment: Qt.AlignRight
                onClicked: {
                    chooseDBWindow.chosenDb = dbCombo.chosenDb
                    loginPopup.chosenDb = chooseDBWindow.chosenDb
                    chooseDBWindow.dbIsSet = storageControllerProperty.setDBType(chooseDBWindow.chosenDb,"password")
                    chooseDBWindow.close()
                }
            }
        }
    }
    LoginWindow {
        id: loginPopup
    }
}
