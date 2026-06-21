import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray

Variants {
    model: Quickshell.screens

    delegate: Component {
        PanelWindow {
            required property var modelData

            screen: modelData
            visible: Hyprland.focusedMonitor?.name === modelData.name

            anchors {
                top: true
                left: true
                right: true
            }

            margins {
                top: 5
                left: 5
                right: 5
            }

            color: "transparent"
            implicitHeight: 32

            Rectangle {
                anchors.fill: parent
                color: "#1E1E1E"
                radius: 4

                WorkspacesControl {
                    id: workspacesControl
                } // WorkspacesControl($workspacesControl)

                Item {
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: workspacesControl.right
                        right: date.left
                    }
                    Text {
                        anchors.centerIn: parent
                        text: Hyprland.activeToplevel?.title ?? ""
                        color: "#1EFFCE"
                    } // Text
                } // Item

                Text {
                    id: date
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(clock.date, "yyyy-MM-dd hh:mm:ss")
                    color: "white"
                    font.weight: Font.Bold
                } // Text($date)

                SystemClock {
                    id: clock
                    precision: SystemClock.Seconds
                } // SystemClock

                ListView {
                    property int iconSize: 24
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: spacing
                    }

                    spacing: 4
                    width: count * iconSize + (count - 1) * spacing
                    height: parent.height
                    model: SystemTray.items
                    orientation: ListView.Horizontal

                    delegate: Item {
                        required property var modelData

                        width: ListView.view.iconSize
                        height: parent.height

                        Image {
                            property ListView view: parent.ListView.view

                            anchors.centerIn: parent
                            sourceSize.width: parent.width
                            sourceSize.height: view.iconSize
                            source: parent.modelData.icon
                        } // Image
                    } // Item
                } // ListView
            } // Rectangle

            // Connections {
            // target: Hyprland
            // function onRawEvent(event) {
            // }
            // } // Connections
        } // PanelWindow
    }  // Component
}  // Variants
