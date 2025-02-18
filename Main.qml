import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

ApplicationWindow {
    id: root
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
            model: storageControllerProperty.model
            property bool editMode: false

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
                        if (treeView.editMode == false) {
                            storageControllerProperty.removeRow(model.row, model.column)
                        } else {
                            var rowData = storageControllerProperty.getRow(model.row, model.column)
                            addContactPopup.editMode = true;
                            addContactPopup.name = rowData[0]
                            addContactPopup.phone = rowData[1]
                            addContactPopup.date = rowData[2]
                            addContactPopup.email = rowData[3]
                            addContactPopup.open()
                        }
                    }
                }
            }
        }
        ColumnLayout {
            id: columnLay
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            Button {
                id: newContactButton
                text: "New contact"
                implicitWidth: 150
                implicitHeight: 50
                background: Rectangle {
                    color: "lightblue"
                    radius: 10
                }
                onClicked: {
                    addContactPopup.editMode = false;
                    addContactPopup.open()
                }
            }

            CustomTextEdit {
                id: filterEdit
                border.color: "black"
                onTextChanged: {
                    if (filterEdit.text.length >= 3 || filterEdit.text.length == 0) {
                        storageControllerProperty.filterWithKey(text)
                    }
                }
            }

            Button {
                id: filterButton
                text: "Filter"
                implicitWidth: 150
                implicitHeight: 50
                background: Rectangle {
                    color: "lightblue"
                    radius: 10
                }
                onClicked: {
                    storageControllerProperty.filterWithKey(filterEdit.text);
                }
            }

            Button {
                id: editButton
                text: "Edit"
                implicitWidth: 150
                implicitHeight: 50
                background: Rectangle {
                    color: "lightblue"
                    radius: 10
                }
                onClicked: {
                    if (treeView.editMode == false) {
                        text ="Select contact"
                        treeView.editMode = true
                    } else {
                        text = "Edit"
                        treeView.editMode = false
                    }
                }
            }
        }
    }
    AddContactWindow {
        id: addContactPopup
    }
    minimumWidth: rowLayout.implicitWidth
    minimumHeight: rowLayout.implicitHeight
}

