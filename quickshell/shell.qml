import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    property int currentWorkspace: 1

    color: "#FF7777"
    WlrLayershell.namespace: `raiden`
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    Image {
        id: wallpaper

        anchors.fill: parent
        source: "file:///home/yangsiyu/Pictures/Wallpapers/random_wallpaper.jpg"
    }  // Image($wallpaper)

    PanelWindow {
        id: bar

        anchors.left: true
        anchors.right: true
        anchors.bottom: true
        implicitHeight: 40
        color: "#DD000000"

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
            }  // Process($dateProc)

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
            }  // Timer
        }  // Text($clock)

        RowLayout {
            id: workspaceRowLayout

            anchors.right: clock.left
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: 4

                Rectangle {
                    Layout.preferredWidth: 12
                    Layout.preferredHeight: 12
                    radius: width / 2
                    color: (index + 1) == root.currentWorkspace ?
                        "lightblue" : "red"
                }  // Rectangle
            }  // Repeater
        }  // RowLayout($workspaceRowLayout)
    }  // PanelWindow($bar)

    Process {
        id: niriIpc

        command: ["niri", "msg", "--json", "event-stream"]
        running: true

        stdout: StdioCollector {
            waitForEnd: false
            onTextChanged: {
                let current_workspace = 1
                for (const line of this.text.split("\n")) {
                    if (line.trim() == "") {
                        continue
                    }

                    console.debug("line:", line)
                    const json = JSON.parse(line)

                    if ("WorkspaceActivated" in json) {
                        current_workspace = json.WorkspaceActivated.id
                    }
                }

                root.currentWorkspace = current_workspace
                console.debug("current_workspace:", current_workspace)
            }
        }
    }  // Process
}  // PanelWindow($root)
