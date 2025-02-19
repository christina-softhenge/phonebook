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
                        text ="Select contact"
                        tableView.editMode = true
                    } else {
                        text = "Edit"
                        tableView.editMode = false
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
                    leftPadding: 7  // Add some padding so it looks natural
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
            model: storageControllerProperty.model
            property bool editMode: false

            columnSpacing: 0
            rowSpacing: 0
            clip: true

            columnWidthProvider: function (column) {
                var totalWidth = tableView.width
                var columnWidths = [0.25, 0.25, 0.25, 0.25] // Proportional widths (adjust as needed)
                return totalWidth * columnWidths[column]
            }

            delegate: Rectangle {
                implicitWidth: tableView.columnWidthProvider(model.column)
                implicitHeight: 40
                border.color: "gray"
                border.width: 0
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
                    onDoubleClicked: {
                        if (tableView.editMode == false) {
                            storageControllerProperty.removeRow(model.row, model.column)
                        } else {
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

