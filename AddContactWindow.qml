import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: addContactWindow
    width: 400
    height: 300
    closePolicy: Popup.CloseOnEscape
    property string name: ""
    property string phone: ""
    property string date: ""
    property string email: ""

    onOpened: {
            nameEdit.text = ""
            phoneEdit.text = ""
            birthDateEdit.text = ""
            emailEdit.text = ""
            nameEdit.border.color = "black"
            phoneEdit.border.color = "black"
            birthDateEdit.border.color = "black"
            emailEdit.border.color = "black"
            warningText.text = ""
    }

    Rectangle {
        anchors.fill: parent
        border.color: "black"
        ColumnLayout {
           id: columnLay
           anchors.fill: parent
           anchors.bottomMargin: 20
           anchors.leftMargin: 20
            GridLayout {
                id: gridlay
                columns: 2
                Text {
                    text: "name:"
                }

                CustomTextEdit {
                    id: nameEdit
                    border.color: "black"
                    text: addContactWindow.name
                    validator: RegularExpressionValidator { regularExpression: /^[a-zA-Z\s]+$/ }
                }

                Text {
                    text: "phone number:"
                }

                CustomTextEdit {
                    id: phoneEdit
                    border.color: "black"
                    text: addContactWindow.phone
                    validator: RegularExpressionValidator { regularExpression: /^\d+$/ }
                }

                Text {
                    text: "date of birth:"
                }

                CustomTextEdit {
                    id: birthDateEdit
                    border.color: "black"
                    text: addContactWindow.date
                    validator: RegularExpressionValidator { regularExpression: /^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$/ }
                    Text {
                        id: placeholderDate
                        text: "yyyy-mm-dd"
                        color: "gray"
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        leftPadding: 7
                        visible: birthDateEdit.text.length === 0
                    }
                }

                Text {
                    text: "email:"
                }

                CustomTextEdit {
                    id: emailEdit
                    border.color: "black"
                    text: addContactWindow.email
                    validator: RegularExpressionValidator { regularExpression: /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/ }
                    Text {
                        id: placeholderEmail
                        text: "name@example.com"
                        color: "gray"
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        leftPadding: 7
                        visible: emailEdit.text.length === 0
                    }
                }
                Text {
                    id: warningText
                    color: "red"
                }
            }
            RowLayout {
                id: rowLayout
                Button {
                    id: saveButton
                    implicitHeight: 25
                    text: "save"
                    onClicked: {
                        var inputs = [nameEdit, phoneEdit, birthDateEdit, emailEdit]
                        var allValid = true

                        for (var i = 0; i < inputs.length; i++) {
                            if (!inputs[i].acceptableInput) {
                                warningText.text = "Invalid input!"
                                inputs[i].border.color = "red"
                                allValid = false
                            } else {
                                inputs[i].border.color = "black"
                            }
                        }

                        if (allValid) {
                            if (!storageControllerProperty.addContact(nameEdit.text, phoneEdit.text, birthDateEdit.text, emailEdit.text)) {
                                warningText.text = "insertion failed!"
                            } else {
                                addContactWindow.close()
                            }
                        }
                    }
                }
                Button {
                    id: cancelButton
                    implicitHeight: 25
                    text: "cancel"
                    onClicked: addContactWindow.close()
                }
            }
        }
    }
}
