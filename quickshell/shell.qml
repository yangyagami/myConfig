import QtQuick
import QtQuick.Controls
import QtMultimedia

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower

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
                    source: "wallpapers/the-end-of-summer.3840x2160.mp4"
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
                left: 11
                right: 11
            }

            color: "transparent"
            implicitHeight: 38

            Rectangle {
                anchors.fill: parent
                implicitHeight: 32
                color: "#1E1E1E"
                radius: 8

                WorkspacesControl {
                    id: workspacesControl
                    anchors {
                        leftMargin: 6
                    }
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

                Item {
                    id: powerItem

                    anchors {
                        rightMargin: -20
                        right: tray.left
                        verticalCenter: parent.verticalCenter
                    }
                    implicitWidth: childrenRect.width
                    implicitHeight: childrenRect.height

                    Text {
                        text: `${UPower.displayDevice.percentage * 100}%`
                        color: "white"
                        anchors {
                            right: batteryLeft.left
                            rightMargin: 4
                            verticalCenter: batteryLeft.verticalCenter
                        }
                        font {
                            pixelSize: 10
                            weight: Font.Bold
                        }
                    } // Text

                    Rectangle {
                        id: batteryLeft
                        width: 30
                        height: 18
                        radius: 4
                        border {
                            width: 2
                            color: "white"
                        }
                        color: "transparent"

                        Rectangle {
                            width: UPower.displayDevice.percentage *
                                parent.width - anchors.margins * 2
                            anchors {
                                top: parent.top
                                bottom: parent.bottom
                                left: parent.left
                                margins: 4
                            }
                            color: Qt.rgba(0.2, 1.0, 0.2, 1.0)
                        }  // Rectangle
                    }  // Rectangle($batteryLeft)

                    Rectangle {
                        id: batteryRight
                        width: 3
                        height: 7
                        radius: 2
                        color: "white"
                        anchors {
                            leftMargin: -1
                            left: batteryLeft.right
                            verticalCenter: batteryLeft.verticalCenter
                        }
                    }  // Rectangle($batteryRight)
                }  // Item($powerItem)

                ListView {
                    id: tray
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
                }  // ListView($tray)
            } // Rectangle

            // Connections {
            // target: Hyprland
            // function onRawEvent(event) {
            // }
            // } // Connections
        } // PanelWindow($bar)
    } // Variants
} // ShellRoot
