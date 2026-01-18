import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

pragma ComponentBehavior: Bound

Scope {
    id: root

    property int currentWorkspaceId: -1
    property string focusedScreen

    Variants {
        id: variants
        model: Quickshell.screens

        PanelWindow {
            id: window

            required property var modelData

            screen: modelData
            color: "#FF7777"
            WlrLayershell.namespace: "raiden"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Background
            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            Connections {
                target: wallpaperSelector

                function onWallpaperChanged(wallpaperSource: string) {
                    wallpaper.source = wallpaperSource
                }
            } // Connections

            Image {
                id: wallpaper

                fillMode: Image.PreserveAspectCrop
                anchors.fill: parent
                source: ""
            } // Image($wallpaper)

            Process {
                command: ["cat", `${Quickshell.shellPath("")}/.wallpaper`]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        wallpaper.source = this.text.trim()
                    }
                } // StdioCollector
            } // Process
        } // PanelWindow($window)
    } // Variants

    FloatingWindow {
        id: wallpaperSelector

        property list<string> wallpapers

        signal wallpaperChanged(wallpaper: string)

        title: "wallpaper selector"
        visible: false

        onVisibleChanged: {
            if (visible) {
                ls.running = true
            }
        }

        ScrollView {
            anchors.fill: parent
            GridLayout {
                Repeater {
                    model: wallpaperSelector.wallpapers
                    Image {
                        required property var modelData

                        source: `${Quickshell.shellPath("wallpapers")}/${modelData}`
                        fillMode: Image.PreserveAspectCrop
                        Layout.preferredWidth: 400
                        Layout.preferredHeight: 300

                        MouseArea {
                            anchors.fill: parent
                            onPressed: {
                                wallpaperSelector.wallpaperChanged(parent.source)
                                echo.command = ["sh", "-c", `echo ${parent.source} > ${Quickshell.shellPath("")}/.wallpaper`]
                                echo.running = true
                            }

                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            } // HoverHandler
                        } // MouseArea
                    } // Image
                } // Repeater
            } // GridLayout
        } // ScrollView

        Process {
            id: ls

            command: ["ls", Quickshell.shellPath("wallpapers")]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    wallpaperSelector.wallpapers = this.text.trim().split("\n")
                }
            }
        } // Process

        Process {
            id: echo
        } // Process
    } // FloatingWindow

    PanelWindow {
        id: bar

        screen: {
            let tmp = Quickshell.screens.filter(
                    s => s.name == root.focusedScreen)[0]

            if (tmp == undefined) {
                return Quickshell.screens[0]
            }

            return tmp
        }
        anchors.left: true
        anchors.right: true
        anchors.top: true
        implicitHeight: 40
        color: "#DD000000"

        Text {
            anchors.centerIn: parent
            text: "Arch Linux"
            font.weight: Font.Bold
            font.pixelSize: 16
            color: "white"
        }  // Text

        Button {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: "wallpaper"

            background: Rectangle {
                color: "pink"
                radius: 4
            } // Rectangle

            onPressed: {
                wallpaperSelector.visible = true
            }
        } // Button

        Text {
            id: clock
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            color: "white"
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 10

            Process {
                // give the process object an id so we can talk
                // about it from the timer
                id: dateProc

                command: ["date"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: clock.text = this.text
                }
            } // Process($dateProc)

            // use a timer to rerun the process at an interval
            Timer {
                // 1000 milliseconds is 1 second
                interval: 1000

                // start the timer immediately
                running: true

                // run the timer again when it ends
                repeat: true

                // when the timer is triggered, set the running property of the
                // process to true, which reruns it if stopped.
                onTriggered: dateProc.running = true
            } // Timer
        } // Text($clock)

        RowLayout {
            id: workspaceRowLayout

            anchors.right: clock.left
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Repeater {
                id: monitorsRowLayout

                model: monitorsModel

                RowLayout {
                    id: monitorWorkspaceRowLayout

                    required property var workspaces
                    required property string name

                    Text {
                        text: parent.name
                        color: "white"
                    } // Text

                    Repeater {
                        model: monitorWorkspaceRowLayout.workspaces
                        Rectangle {
                            required property int id

                            Layout.preferredWidth: 12
                            Layout.preferredHeight: 12
                            radius: width / 2
                            color: id == root.currentWorkspaceId ?
                                       "lightblue" : "red"
                        } // Rectangle
                    } // Repeater
                } // RowLayout($monitorWorkspaceRowLayout)
            } // Repeater($monitorsRowLayout)
        } // RowLayout($workspaceRowLayout)
    } // PanelWindow($bar)

    Process {
        id: niriIpcEventStream

        property int lastIdx: 0

        command: ["niri", "msg", "--json", "event-stream"]
        running: true

        stdout: StdioCollector {
            waitForEnd: false
            onTextChanged: {
                let workspaces = null
                let currentWorkspaceId = -1

                const lines = this.text.split("\n")

                for (const line of lines.slice(niriIpcEventStream.lastIdx)) {
                    if (line.trim() == "") {
                        continue
                    }
                    const json = JSON.parse(line)

                    if ("WorkspaceActivated" in json) {
                        currentWorkspaceId = json.WorkspaceActivated.id
                        root.focusedScreen = monitorsModel.getMonitorName(currentWorkspaceId)
                    }

                    if ("WorkspacesChanged" in json) {
                        workspaces = json.WorkspacesChanged.workspaces
                    }
                }

                niriIpcEventStream.lastIdx = lines.length - 1

                if (workspaces != null) {
                    monitorsModel.clear()

                    workspaces.sort((a, b) => {
                                        if (a.output !== b.output) {
                                            if (a.output > b.output) {
                                                return 1
                                            } else if (a.output < b.output) {
                                                return -1
                                            }
                                        }
                                        return a.idx - b.idx
                    })

                    for (const workspace of workspaces) {
                        if (workspace.is_focused == true) {
                            root.currentWorkspaceId = workspace.id
                            root.focusedScreen = workspace.output
                        }

                        let idx = monitorsModel.indexOf(workspace.output)

                        if (idx < 0) {
                            monitorsModel.createMonitor(
                                        workspace.output, workspace.id)
                        } else {
                            monitorsModel.appendWorkspace(idx, workspace.id)
                        }
                    }
                }

                if (currentWorkspaceId != -1) {
                    root.currentWorkspaceId = currentWorkspaceId
                }
            }
        }
    } // Process($niriIpcEventStream)

    ListModel {
        id: monitorsModel

        function indexOf(outputName) {
            for (let i = 0; i < this.count; ++i) {
                if (this.get(i).name == outputName) {
                    return i
                }
            }
            return -1
        }

        function getMonitorName(workspaceId) {
            for (let i = 0; i < this.count; ++i) {
                let workspaces = this.get(i).workspaces
                for (let j = 0; j < workspaces.count; ++j) {
                    if (workspaces.get(j).id == workspaceId) {
                        return this.get(i).name
                    }
                }
            }
            return ""
        }

        function createMonitor(outputName, workspaceId) {
            this.append({
                            name: outputName,
                            workspaces: [ { id: workspaceId } ]
                        })
        }

        function appendWorkspace(monitorIndex, workspaceId, workspaceIdx) {
            this.get(monitorIndex).workspaces.append({ id: workspaceId })
        }
    } // ListModel($monitorsModel)
} // Scope($root)
