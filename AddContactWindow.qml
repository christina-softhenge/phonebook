import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: addContactWindow
    width: 400
    height: 300
    closePolicy: Popup.CloseOnEscape

    onOpened: {
        name.text = ""
        phone.text = ""
        birthDate.text = ""
        email.text = ""
        name.border.color = "black"
        phone.border.color = "black"
        birthDate.border.color = "black"
        email.border.color = "black"
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
                    id: name
                    border.color: "black"
                }

                Text {
                    text: "phone number:"
                }

                CustomTextEdit {
                    id: phone
                    border.color: "black"
                }

                Text {
                    text: "date of birth:"
                }

                CustomTextEdit {
                    id: birthDate
                    border.color: "black"
                }

                Text {
                    text: "email:"
                }

                CustomTextEdit {
                    id: email
                    border.color: "black"
                }
                Text {
                    id: warningText
                    color: "red"
                }
            }
            RowLayout {
                id: rowLayout
                Button {
                    implicitHeight: 25
                    text: "save"
                    onClicked: {
                        let phoneRegex = /^\d+$/
                        let emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
                        let nameRegex = /^[a-zA-Z\s]+$/;  // Matches only alphabets and spaces for name
                        let birthdateRegex = /^(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}$/

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
                        isValid &= validateInput(name.text, nameRegex, name)
                        isValid &= validateInput(phone.text, phoneRegex, phone)
                        isValid &= validateInput(birthDate.text, birthdateRegex, birthDate)
                        isValid &= validateInput(email.text, emailRegex, email)

                        if (isValid) {
                            treeViewProperty.addContact(name.text, phone.text, birthDate.text, email.text)
                            addContactWindow.close()
                        } else {
                            if (warningText.text === "") {
                                warningText.text = "Invalid argument."
                            }
                        }
                    }
                }
                Button {
                    implicitHeight: 25
                    text: "cancel"
                    onClicked: addContactWindow.close()
                }
            }
        }
    }
}
