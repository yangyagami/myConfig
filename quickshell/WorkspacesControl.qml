import QtQuick

ListView {
    property int itemSize: 24

    anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
        leftMargin: spacing
    }
    spacing: 4
    implicitWidth: count * itemSize + (count - 1) * spacing
    implicitHeight: itemSize
    model: 5
    orientation: ListView.Horizontal
    delegate: WorkspaceButton {
        itemSize: ListView.view.itemSize
    } // WorkspaceButton
} // ListView
