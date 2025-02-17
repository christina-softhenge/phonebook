import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: addContactWindow
    width: 400
    height: 300
    closePolicy: Popup.CloseOnEscape
    property bool editMode: false
    property string name: ""
    property string phone: ""
    property string date: ""
    property string email: ""

    property string originalName: ""

    onOpened: {
        if (!editMode) {
            nameEdit.text = ""
            phoneEdit.text = ""
            birthDateEdit.text = ""
            emailEdit.text = ""
            nameEdit.border.color = "black"
            phoneEdit.border.color = "black"
            birthDateEdit.border.color = "black"
            emailEdit.border.color = "black"
            warningText.text = ""
        } else {
            originalName = nameEdit.text
        }
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
                }

                Text {
                    text: "phone number:"
                }

                CustomTextEdit {
                    id: phoneEdit
                    border.color: "black"
                    text: addContactWindow.phone
                }

                Text {
                    text: "date of birth:"
                }

                CustomTextEdit {
                    id: birthDateEdit
                    border.color: "black"
                    text: addContactWindow.date
                }

                Text {
                    text: "email:"
                }

                CustomTextEdit {
                    id: emailEdit
                    border.color: "black"
                    text: addContactWindow.email
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
                        let phoneRegex = /^\d+$/
                        let emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
                        let nameRegex = /^[a-zA-Z\s]+$/;  // Matches only alphabets and spaces for name
                        let birthdateRegex = /^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$/

                        function validateInput(field, regex, element) {
                            if (!regex.test(field)) {
                                element.border.color = "red"
                                return false;
                            } else {
                                element.border.color = "black"
                                return true;
                            }
                        }
                        warningText.text = ""

                        let isValid = true
                        isValid &= validateInput(nameEdit.text, nameRegex, nameEdit)
                        isValid &= validateInput(phoneEdit.text, phoneRegex, phoneEdit)
                        isValid &= validateInput(birthDateEdit.text, birthdateRegex, birthDateEdit)
                        isValid &= validateInput(emailEdit.text, emailRegex, emailEdit)

                        if (isValid) {
                            if (editMode == false) {
                                storageControllerProperty.addContact(nameEdit.text, phoneEdit.text, birthDateEdit.text, emailEdit.text)
                            } else {
                                var stringList = [nameEdit.text, phoneEdit.text, birthDateEdit.text, emailEdit.text]
                                storageControllerProperty.editRow(addContactWindow.originalName,stringList)
                            }
                            addContactWindow.close()
                        } else {
                            if (warningText.text === "") {
                                warningText.text = "Invalid argument."
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
