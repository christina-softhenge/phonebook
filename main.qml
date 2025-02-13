import QtQuick
import QtQuick.Controls
import QtQuick.Window

ApplicationWindow {
    visible: true
    width: 600
    height: 500
    title: "Tree View"

    TreeView {
        id: treeView
        anchors.fill: parent
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
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onDoubleClicked: {
                    treeViewProperty.onItemDoubleClicked(model.row,model.column);
                }
            }
        }
    }
}
