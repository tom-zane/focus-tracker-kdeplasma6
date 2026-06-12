import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

Item {
    Layout.minimumWidth: 280
    Layout.minimumHeight: 380
    Layout.preferredWidth: 320
    Layout.preferredHeight: 400

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing * 2

        RowLayout {
            Layout.fillWidth: true
            
            PlasmaComponents.Label {
                text: "Focus Tracker"
                font.weight: Font.Bold
            }
            
            Item { Layout.fillWidth: true }
            
            PlasmaComponents.Button {
                icon.name: "view-history"
                display: PlasmaComponents.AbstractButton.IconOnly
                flat: true
                onClicked: {
                    var component = Qt.createComponent("HistoryWindow.qml");
                    if (component.status === Component.Ready) {
                        var win = component.createObject(root, { "accentColor": root.ringColor });
                        win.show();
                    }
                }
            }
        }

        Item {
            Layout.preferredWidth: 200
            Layout.preferredHeight: 200
            Layout.alignment: Qt.AlignHCenter

            Shape {
                anchors.fill: parent
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    strokeWidth: 12
                    strokeColor: Qt.rgba(0.5, 0.5, 0.5, 0.2)
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap
                    PathAngleArc { centerX: 100; centerY: 100; radiusX: 90; radiusY: 90; startAngle: 0; sweepAngle: 360 }
                }

                ShapePath {
                    strokeWidth: 12
                    strokeColor: root.ringColor
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap
                    PathAngleArc { centerX: 100; centerY: 100; radiusX: 90; radiusY: 90; startAngle: -90; sweepAngle: 360 * root.progress }
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 0
                
                PlasmaComponents.Label { 
                    Layout.alignment: Qt.AlignHCenter
                    text: root.formatTime(root.secondsLeft)
                    font.family: root.clockFontFamily
                    font.pixelSize: 42 
                    font.weight: Font.DemiBold
                }
                PlasmaComponents.Label { 
                    Layout.alignment: Qt.AlignHCenter
                    text: root.currentMode
                    font.family: root.clockFontFamily
                    font.pixelSize: 16
                    opacity: 0.7
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Kirigami.Units.largeSpacing

            PlasmaComponents.Button { 
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                display: PlasmaComponents.AbstractButton.IconOnly
                icon.name: "media-skip-forward"
                onClicked: { root.endSessionInDb("Skipped"); root.switchMode(); } 
            }
            
            PlasmaComponents.Button { 
                Layout.preferredWidth: 56
                Layout.preferredHeight: 56
                
                Layout.leftMargin: Kirigami.Units.largeSpacing * 1.5
                Layout.rightMargin: Kirigami.Units.largeSpacing * 1.5
                
                display: PlasmaComponents.AbstractButton.IconOnly
                icon.name: root.isRunning ? "media-playback-pause" : "media-playback-start"
                
                background: Rectangle {
                    color: root.ringColor
                    radius: Kirigami.Units.smallSpacing 
                    
                    opacity: parent.down ? 0.45 : (parent.hovered ? 0.35 : 0.25)
                    
                    border.color: Qt.rgba(0, 0, 0, 0.1)
                    border.width: 1
                }

                onClicked: { 
                    if(!root.isRunning && root.currentSessionDbId === null) root.startNewSessionInDb(); 
                    root.isRunning = !root.isRunning; 
                } 
            }
            PlasmaComponents.Button { 
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                display: PlasmaComponents.AbstractButton.IconOnly
                icon.name: "media-playback-stop"
                onClicked: { root.endSessionInDb("Interrupted"); root.isRunning = false; root.secondsLeft = root.totalSeconds; } 
            }
        }

        Item { Layout.fillHeight: true }
    }
}