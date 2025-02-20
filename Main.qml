import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 600
    height: 500
    title: "Phonebook"


    ColumnLayout {
        id: mainColumnLayout
        anchors.fill: parent
        anchors.margins: 10
        RowLayout {
            id: headerLay
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            Button {
                id: newContactButton
                text: "New contact"
                implicitWidth: 100
                implicitHeight: 30
                background: Rectangle {
                    border.color: "lightgrey"
                    color: "white"
                    radius: 5
                }
                onClicked: {
                    addContactPopup.editMode = false;
                    addContactPopup.open()
                }
            }

            Button {
                id: editButton
                text: "Edit"
                implicitWidth: 100
                implicitHeight: 30
                background: Rectangle {
                    border.color: "lightgrey"
                    color: "white"
                    radius: 5
                }
                onClicked: {
                    if (tableView.editMode == false) {
                        text ="Select"
                        tableView.editMode = true
                        if (tableView.selectedRow != -1) {
                            var rowData = storageControllerProperty.getRow(tableView.selectedRow)
                            addContactPopup.editMode = true;
                            addContactPopup.name = rowData[0]
                            addContactPopup.phone = rowData[1]
                            addContactPopup.date = rowData[2]
                            addContactPopup.email = rowData[3]
                            addContactPopup.open()
                        }
                    } else {
                        text = "Edit"
                        tableView.editMode = false
                    }
                }
            }

            Button {
                id: deleteButton
                text: "Delete"
                implicitWidth: 100
                implicitHeight: 30
                background: Rectangle {
                    border.color: "lightgrey"
                    color: "white"
                    radius: 5
                }
                onClicked: {
                    if (tableView.selectedRow == -1 && text == "Delete") {
                        tableView.deleteMode = true
                        text ="Select"
                    } else if (tableView.selectedRow != -1){
                        storageControllerProperty.removeRow(tableView.selectedRow, tableView.model.column)
                        text = "Delete"
                        tableView.deleteMode = false
                    } else {
                        text = "Delete"
                        tableView.deleteMode = false
                    }
                }
            }

            Item { Layout.fillWidth: true }

            CustomTextEdit {
                id: filterEdit
                border.color: "grey"

                Text {
                    id: placeholder
                    text: "search"
                    color: "gray"
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    leftPadding: 7
                    visible: filterEdit.text.length === 0
                }
                onTextChanged: {
                    if (filterEdit.text.length >= 3 || filterEdit.text.length == 0) {
                        storageControllerProperty.filterWithKey(text)
                    }
                }
            }

        }

        Rectangle {
            Layout.fillWidth: true
            height: 35
            color: "#a5bacc"
            RowLayout {
                anchors.fill: parent
                spacing: 10
                Text {
                    text: "Name";
                    font.bold: true;
                    padding: 10;
                    leftPadding: 50;
                }
                Text {
                    text: "Phone";
                    font.bold: true;
                    padding: 10
                }
                Text {
                    text: "Date";
                    font.bold: true;
                    padding: 10
                }
                Text {
                    text: "Email";
                    font.bold: true;
                    padding: 10
                }
            }
        }

        TableView {
            id: tableView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: storageControllerProperty ? storageControllerProperty.model : null
            property bool editMode: false
            property int selectedRow: -1
            property bool deleteMode: false

            columnSpacing: 0
            rowSpacing: 0
            clip: true

            columnWidthProvider: function (column) {
                var totalWidth = tableView.width
                var columnWidths = [0.25, 0.25, 0.25, 0.25]
                return totalWidth * columnWidths[column]
            }

            delegate: Rectangle {
                id: tableViewDalegate
                implicitWidth: tableView.columnWidthProvider(model.column)
                implicitHeight: 40
                Rectangle {
                    width: parent.width
                    height: 1
                    color: "gray"
                    anchors.top: parent.top
                }
                Rectangle {
                    width: parent.width
                    height: 1
                    color: "gray"
                    anchors.bottom: parent.bottom
                }

                Rectangle {
                    id: background
                    anchors.fill: parent
                    color: tableView.selectedRow === row ? "#ced3d7" : "white"
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: 4
                    text: model.display
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: {
                        if (tableView.deleteMode == true) {
                            storageControllerProperty.removeRow(tableView.selectedRow, tableView.model.column)
                        }
                        if (tableView.selectedRow == row) {
                            tableView.selectedRow = -1
                        } else {
                            tableView.selectedRow = row
                        }
                        if (tableView.editMode == true) {
                            var rowData = storageControllerProperty.getRow(model.row)
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

    }
    AddContactWindow {
        id: addContactPopup
    }
    minimumWidth: tableView.implicitWidth
    minimumHeight: tableView.implicitHeight
}

