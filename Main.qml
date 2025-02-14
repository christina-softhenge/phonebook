import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 600
    height: 500
    title: "Tree View"

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        anchors.margins: 10
        TreeView {
            id: treeView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: treeViewProperty.getModel()

            delegate: TreeViewDelegate {
                indentation: 20

                contentItem: Row {
                    spacing: 8
                    Text {
                        text: model.display
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onDoubleClicked: {
                        treeViewProperty.onItemDoubleClicked(model.row, model.column);
                    }
                }
            }
        }
        Button {
            text: "New contact"
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            implicitWidth: 100
            implicitHeight: 50
            background: Rectangle {
                color: "lightblue"
                radius: 10
            }
            onClicked: {
                console.log("Button clicked")
                contactWindow.show()
            }
        }
    }

    Window {
        id: contactWindow
        width: 300
        height: 200
        visible: false
        title: "New Contact"
        modality: Qt.NonModal
        GridLayout {
            id: gridlay
            anchors.fill: parent
            columns:2
            anchors.margins: 20
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
            Button {
                implicitHeight: 25;
                text: "save"
                onClicked: {
                    treeViewProperty.addContact(name.text,phone.text,birthDate.text,email.text)
                    contactWindow.close()
                }
            }
        }
        minimumWidth: gridlay.implicitWidth
        minimumHeight: gridlay.implicitHeight
    }
    minimumWidth: rowLayout.implicitWidth
    minimumHeight: rowLayout.implicitHeight
}

