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
                        treeViewProperty.onItemDoubleClicked(model.row, model.column)
                    }
                }
            }
        }
        AddContactWindow {
            id: addContactPopup
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
                addContactPopup.open()
            }
        }
    }
    minimumWidth: rowLayout.implicitWidth
    minimumHeight: rowLayout.implicitHeight
    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        currentFolder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
        nameFilters: ["Text files (*.txt)"]
        onAccepted: {
            treeViewProperty.setPath(fileDialog.selectedFiles)
        }
        onRejected: {
            console.log("Canceled")
        }
        Component.onCompleted: visible = true
    }
}

