import QtQuick
import QtQuick.Controls
import QtMultimedia

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray

ShellRoot {
    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: surface
                required property var modelData

                screen: modelData

                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }

                color: "#080808"
                WlrLayershell.layer: WlrLayer.Background
                exclusiveZone: 1

                VideoOutput {
                    id: videoOutput
                    anchors.fill: parent
                }  // VideoOutput($videoOutput)

                MediaPlayer {
                    source: "wallpapers/albedos-paradise.1920x1080.mp4"
                    audioOutput: AudioOutput {}  // AudioOutput
                    videoOutput: videoOutput
                    loops: MediaPlayer.Infinite

                    Component.onCompleted: {
                        play();
                    }
                }  // MediaPlayer
            } // PanelWindow($surface)
        } // Component
    } // Variants

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData

            screen: modelData
            visible: Hyprland.focusedMonitor?.name === modelData.name
            WlrLayershell.layer: WlrLayer.Background

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
                implicitHeight: 32
                color: "#1E1E1E"
                radius: 4

                WorkspacesControl {
                    id: workspacesControl
                } // WorkspacesControl($workspacesControl)

                Item {
                    clip: true
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: workspacesControl.right
                        right: date.left
                        leftMargin: 10
                        rightMargin: 10
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
        } // PanelWindow($bar)
    } // Variants
} // ShellRoot
