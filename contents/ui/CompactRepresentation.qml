import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Item {
    id: compactRoot
    
    property int minSize: Math.min(width, height)
    
    Layout.minimumWidth: 32
    Layout.minimumHeight: 32

    Shape {
        anchors.centerIn: parent
        width: compactRoot.minSize
        height: compactRoot.minSize
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            strokeWidth: 3
            strokeColor: Qt.rgba(0.5, 0.5, 0.5, 0.3)
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: compactRoot.minSize / 2; centerY: compactRoot.minSize / 2
                radiusX: (compactRoot.minSize / 2) - 4; radiusY: (compactRoot.minSize / 2) - 4
                startAngle: 0; sweepAngle: 360
            }
        }

        ShapePath {
            strokeWidth: 3
            strokeColor: root.ringColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: compactRoot.minSize / 2; centerY: compactRoot.minSize / 2
                radiusX: (compactRoot.minSize / 2) - 4; radiusY: (compactRoot.minSize / 2) - 4
                startAngle: -90; sweepAngle: 360 * root.progress
            }
        }
    }

    Kirigami.Icon {
        anchors.centerIn: parent
        width: compactRoot.minSize * 0.55
        height: compactRoot.minSize * 0.55
        
        source: "clock"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = !root.expanded
    }
}