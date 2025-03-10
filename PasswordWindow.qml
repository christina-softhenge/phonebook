import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: passwordWindow
    width: 400
    height: 250
    modal: true
    closePolicy: Dialog.CloseOnEscape

    property string password: ""
    property bool editPassword: false
    property real startX
    property real startY

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
            text:  editPassword ? "Set New Password" : "Set Password"
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            onPressed: function(event) {
                passwordWindow.startX = event.x
                passwordWindow.startY = event.y
            }
            onPositionChanged: function(event) {
                passwordWindow.x += event.x - passwordWindow.startX
                passwordWindow.y += event.y - passwordWindow.startY
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
                validator: RegularExpressionValidator { regularExpression: /^[A-Za-z\d@$!%*?&]{4,}$/ }
                placeholderText: "Enter at least 4 characters"
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
                text: "Cancel"
                onClicked: passwordWindow.close()
            }

            Button {
                text: "OK"
                onClicked: {
                    if (setPasswordEdit.acceptableInput) {
                        warningText.text = ""
                        password = setPasswordEdit.text
                        editPassword = true
                        console.log("Password set:", password)
                        passwordWindow.close()
                    } else {
                        warningText.text = "Invalid password"
                    }
                }
            }
        }
    }
}
