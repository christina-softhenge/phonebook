import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: loginWindow
    width: 300
    height: 250
    modal: true
    closePolicy: Dialog.CloseOnEscape
    property real startX
    property real startY
    property var chosenDb:0

    onOpened: {
        x = (root.width - width) / 2
        y = (root.height - height) / 2
        warningText.text = ""
        setPasswordEdit.text = ""
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
            text: "Enter the password"
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            onPressed: function(event) {
                loginWindow.startX = event.x
                loginWindow.startY = event.y
            }
            onPositionChanged: function(event) {
                loginWindow.x += event.x - loginWindow.startX
                loginWindow.y += event.y - loginWindow.startY
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10
        anchors.topMargin: 40

        Text {
            text: "Enter Password:"
            font.bold: true
        }

        RowLayout {
            TextField {
                id: setPasswordEdit
                Layout.fillWidth: true
                echoMode: eyeButton.checked ? TextInput.Normal : TextInput.Password
                validator: RegularExpressionValidator { regularExpression: /^[A-Za-z\d@$!%*?&_]{4,}$/ }
                font.pixelSize: 14
            }

            CheckBox {
                id: eyeButton
                text: "Show"
            }
        }

        Text {
            id: warningText
            text: ""
            color: "red"
            visible: text.length > 0
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 10

            Button {
                text: "OK"
                onClicked: {
                    if (storageControllerProperty.setDBType(loginWindow.chosenDb, setPasswordEdit.text)) {
                        warningText.text = ""
                        loginWindow.close()
                    } else {
                        warningText.text = "Password is incorrect"
                    }
                }
            }
        }
    }
}
