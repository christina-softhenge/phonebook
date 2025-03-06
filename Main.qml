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

    Dialog {
        id: chooseDBWindow
        width: 250
        height: 200
        modal: true
        closePolicy: Dialog.CloseOnEscape
        property real startX
        property real startY

        onOpened: {
            x = (root.width - width) / 2
            y = (root.height - height) / 2
        }
        MouseArea {
            anchors.fill: parent
            onPressed: function(event) {
                chooseDBWindow.startX = event.x
                chooseDBWindow.startY = event.y
            }
            onPositionChanged: function(event) {
                chooseDBWindow.x += event.x - chooseDBWindow.startX
                chooseDBWindow.y += event.y - chooseDBWindow.startY
            }
        }

        Rectangle {
            anchors.fill: parent
            border.color: "lightgrey"
            ColumnLayout {
                anchors.margins: 20
                anchors.fill: parent
                Text {
                    id: selectText
                    text: "Select Database"
                }
                Text {
                    id: dbwarningText
                    color: "red"
                    text: ""
                }

                RowLayout {
                    ComboBox {
                        id: dbCombo
                        property int chosenDb: 0;
                        model: [ "MySql", "Sqlite" ]
                        onCurrentIndexChanged: {
                            chosenDb = currentIndex
                        }
                    }
                }
            }
        }

        footer: Rectangle {
            width: parent.width
            height: 50

            Row {
                spacing: 10
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 10

                Button {
                    text: "OK"
                    onClicked: {
                        var outcome = storageControllerProperty.setDBType(dbCombo.chosenDb)
                        if (!outcome) {
                            dbwarningText.text = "Database setup failed."
                        } else {
                            tableView.dbChanged()
                            chooseDBWindow.accept()
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
                    if (tableView.selectedRow != []){
                        storageControllerProperty.deleteRows(tableView.selectedRows)
                        text = "Delete"
                        tableView.selectedRows = []
                        tableView.selectionsChanged()
                    }
                }
            }

            Button {
                id: changeDbButton
                text: "Change db"
                implicitWidth: 100
                implicitHeight: 30
                background: Rectangle {
                    border.color: "lightgrey"
                    color: "white"
                    radius: 5
                }
                onClicked: {
                    chooseDBWindow.open()
                }
            }

            Button {
                id: importFromCSVButton
                text: "import"
                implicitWidth: 100
                implicitHeight: 30
                background: Rectangle {
                    border.color: "lightgrey"
                    color: "white"
                    radius: 5
                }
                onClicked: {
                    fileDialog.open()
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
            property var selectedRows: []
            signal selectionsChanged
            signal dbChanged
            signal selectAllPressed

            columnSpacing: 0
            rowSpacing: 0
            focus: true
            clip: true

            columnWidthProvider: function (column) {
                var totalWidth = tableView.width
                var columnWidths = [0.25, 0.25, 0.25, 0.25]
                return totalWidth * columnWidths[column]
            }

            Keys.onPressed: (event) => {
                if (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_A) {
                    selectAllPressed()
                    event.accepted = true
                }
            }

            delegate: Rectangle {
                id: tableViewDelegate
                implicitWidth: tableView.columnWidthProvider(model.column)
                implicitHeight: 40

                property int rowIndex: (tableView && tableView.model && model.row !== undefined) ? model.row : -1
                property int colIndex: (tableView && tableView.model && model.column !== undefined) ? model.column : -1

                function resetState() {
                    if (storageControllerProperty && rowIndex >= 0) {
                        if (textField) {
                            textField.text = model.display || ""
                            if (colIndex === 3 && storageControllerProperty.getRow(rowIndex)) {
                                textField.originalEmail = storageControllerProperty.getRow(rowIndex)[3]
                                textField.stringList = storageControllerProperty.getRow(rowIndex)
                            }
                        }
                        background.updateColor()
                    }
                }

                Connections {
                    target: tableView
                    function onDbChanged() {
                        tableView.focus = true
                        tableView.selectedRows = []
                        background.updateColor()
                    }
                    function onSelectAllPressed() {
                        tableView.selectedRows = Array.from({length: tableView.model.rowCount()}, (_, i) => i)
                        background.updateColor()
                    }
                }

                onRowIndexChanged: resetState()
                onColIndexChanged: resetState()

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
                    color: tableView.selectedRows.includes(row) ? "#ced3d7" : "white"
                    Connections {
                        target: tableView
                        function onSelectionsChanged() {
                            background.color = tableView.selectedRows.includes(row) ? "#ced3d7" : "white"
                        }
                    }
                    function updateColor() {
                        background.color = tableView.selectedRows.includes(row) ? "#ced3d7" : "white";
                    }
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

                    property string originalEmail: storageControllerProperty ? storageControllerProperty.getRow(row)[3] : null
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
                        storageControllerProperty.editRow(originalEmail, stringList)
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
                    onClicked: function(mouse) {
                        if (mouse.modifiers & Qt.ControlModifier) {
                            let index = tableView.selectedRows.indexOf(row)
                            if (index !== -1) {
                                tableView.selectedRows.splice(index, 1)
                            } else {
                            tableView.selectedRows.push(row)
                            }
                            tableView.selectionsChanged()
                        } else {
                            let index = tableView.selectedRows.indexOf(row)
                            if (index !== -1) {
                                tableView.selectedRows = []
                            } else {
                                tableView.selectedRows = []
                                tableView.selectedRows.push(row)
                            }
                            tableView.selectionsChanged()
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
    }

    AddContactWindow {
        id: addContactPopup
    }
    minimumWidth: tableView.implicitWidth
    minimumHeight: tableView.implicitHeight
}


