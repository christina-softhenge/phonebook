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
            model: treeViewProperty.model

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
        ColumnLayout {
            id: columnLay
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            Button {
                id: newContactButton
                text: "New contact"
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

            CustomTextEdit {
                id: filterEdit
                border.color: "black"
            }

            Button {
                id: filterButton
                text: "Filter"
                implicitWidth: 100
                implicitHeight: 50
                background: Rectangle {
                    color: "lightblue"
                    radius: 10
                }
                onClicked: {
                    treeViewProperty.filterWithKey(filterEdit.text)
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

