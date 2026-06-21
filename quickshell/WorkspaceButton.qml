import QtQuick
import QtQuick.Controls

import Quickshell.Hyprland

Button {
    id: root

    required property var modelData;
    property int itemSize: 24

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    } // HoverHandler

    text: modelData + 1
    checked: {
        let focusedWorkspace = Hyprland.focusedWorkspace?.id;
        if (!focusedWorkspace) {
            return false;
        }
        if (Hyprland.focusedWorkspace?.id > GlobalContext.workspacesCount) {
            focusedWorkspace -= GlobalContext.workspacesCount;

        }
        return modelData + 1 === focusedWorkspace;
    }
    implicitWidth: itemSize
    implicitHeight: itemSize
    background: Rectangle {
        color: root.checked ? "#1ECEFF" : "transparent"
        radius: 4
    } // Rectangle
    contentItem: Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: root.text
        color: root.checked ? "black" : "white"
    } // Text

    onPressed: {
        let workspacesCount = GlobalContext.workspacesCount;
        let target = modelData + 1;
        if (Hyprland.focusedWorkspace.id > workspacesCount) {
            target += GlobalContext.workspacesCount;
        }
        Hyprland.dispatch(`hl.dsp.focus({ workspace = ${target}})`);
    }
}  // Button($root)
