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
    title: "Phonebook"
    Popup {
        id: chooseDBWindow
        width: 250
        height: 200
        Rectangle {
            anchors.fill: parent
            border.color: "black"
            ColumnLayout {
                anchors.margins: 20
                anchors.fill: parent
                Text {
                    id: selectText
                    text: "Select Database" }
                RowLayout {
                    Button {
                        id: sqliteButton
                        text: "SQLite"
                        onClicked: {
                            storageControllerProperty.setDBType(0)
                            chooseDBWindow.close()
                        }
                    }
                    Button {
                        id: mysqlButton
                        text: "MySQL"
                        onClicked: {
                            storageControllerProperty.setDBType(1)
                            chooseDBWindow.close()
                        }
                    }
                }
            }
        }
    }
    Component.onCompleted: chooseDBWindow.open()

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
                    addContactPopup.open()
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

            Text {
                id: warningText
                color: "red"
                text: ""
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
                id: tableViewDelegate
                implicitWidth: tableView.columnWidthProvider(model.column)
                implicitHeight: 40
                Rectangle {
                    id: topLine
                    width: parent.width
                    height: 1
                    color: "green"
                    anchors.top: parent.top
                }

                Rectangle {
                    id: bottomLine
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

                TextField {
                    id: textField
                    width: contentWidth + leftPadding + rightPadding
                    anchors.fill: parent
                    anchors.margins: 4
                    text: model.display
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    readOnly: true

                    property string originalName: storageControllerProperty ? storageControllerProperty.getRow(row)[0] : null
                    property var stringList:  storageControllerProperty ? storageControllerProperty.getRow(row) : null
                    property int columnChanged: 0
                    onTextChanged: {
                        if (column == 0){
                            text = text.replace(/[^A-Za-z ]/g, "");
                        } else
                        if (column == 1) {
                            text = text.replace(/[^0-9]/g, "");
                        } else
                        if (column == 2) {
                            text = text.replace(/[^0-9-]/g, "");
                            let match = text.match(/^(\d{0,4})(-?)(\d{0,2})(-?)(\d{0,2})$/);
                            if (match) {
                                let year = match[1];
                                let firstDash = year.length === 4 ? "-" : "";
                                let month = match[3];
                                let secondDash = month.length === 2 ? "-" : "";
                                let day = match[5];

                                text = year + firstDash + month + secondDash + day;
                            }
                            if (text.length > 10) {
                                text = text.substring(0, 10);
                            }
                        } else {
                            text = text.replace(/[^a-zA-Z0-9@._-]/g, "");

                            let emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
                            if (emailPattern.test(text)) {
                                color = "black";
                            } else {
                                color = "grey";
                            }
                        }
                        stringList[column] = text
                        columnChanged = column
                    }

                    background: Rectangle {
                        border.width: 0
                        color: "transparent"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onDoubleClicked: {
                            parent.readOnly = false
                            parent.forceActiveFocus()
                            parent.selectAll()
                        }
                    }

                    function onFinished(column) {
                        if (column == 3) {
                            if (textField.color == "#808080" || textField.color == "#ff0000") {
                                textField.color = "red";
                                warningText.text = "Invalid argument!"
                                return;
                            }
                        }
                        warningText.text = ""
                        storageControllerProperty.editRow(originalName, stringList)
                    }

                    onEditingFinished: {
                        onFinished(columnChanged)
                        display = text
                        readOnly = true
                    }

                    onActiveFocusChanged: {
                        if (!activeFocus) {
                            onFinished(columnChanged)
                            readOnly = true
                            text = display
                        }
                    }

                    Keys.onReturnPressed: {
                        onFinished(columnChanged)
                        display = text
                        readOnly = true
                        focus = false
                    }

                    Keys.onEscapePressed: {
                        onFinished(columnChanged)
                        text = display
                        readOnly = true
                        focus = false
                    }
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
                    }
                }
            }
        }
    }
    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        currentFolder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
       nameFilters: ["CSV files (*.csv)"]
        onAccepted: {
            storageControllerProperty.setPath(fileDialog.selectedFiles)
        }
        onRejected: {
            console.log("Canceled")
        }
        Component.onCompleted: visible = true
    }

    AddContactWindow {
        id: addContactPopup
    }
    minimumWidth: tableView.implicitWidth
    minimumHeight: tableView.implicitHeight
}


