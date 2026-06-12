import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import QtQuick.LocalStorage
import org.kde.notification

PlasmoidItem {
    id: root
    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}

    property int focusTimeMinutes: Plasmoid.configuration.focusTimeMinutes || 25
    property int breakTimeMinutes: Plasmoid.configuration.breakTimeMinutes || 5
    property color ringColor: Plasmoid.configuration.ringColor || "#3daee9"
    property string clockFontFamily: Plasmoid.configuration.clockFontFamily || "sans-serif"
    property bool notifyOnEnd: Plasmoid.configuration.notifyOnEnd !== undefined ? Plasmoid.configuration.notifyOnEnd : true
    
    property int totalSeconds: focusTimeMinutes * 60
    property int secondsLeft: focusTimeMinutes * 60
    property string currentMode: "Focus"
    property bool isRunning: false
    property real progress: totalSeconds > 0 ? (totalSeconds - secondsLeft) / totalSeconds : 0
    property int clockSize: 200

    property var currentSessionDbId: null
    property var db: null

    Component.onCompleted: {
        db = LocalStorage.openDatabaseSync("FocusTrackerDB", "1.0", "Storage for Focus Sessions", 100000);
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS sessions(id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT, duration_seconds INTEGER, elapsed_seconds INTEGER, status TEXT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)');
        });
    }

    Notification {
        id: endSessionNotification
        componentName: "plasma_workspace"
        title: "Focus Tracker"
        iconName: "notifications"
    }

    function startNewSessionInDb() {
        if (!db) return;
        db.transaction(function(tx) {
            var rs = tx.executeSql("INSERT INTO sessions (type, duration_seconds, elapsed_seconds, status) VALUES (?, ?, ?, 'Active')", [root.currentMode, root.totalSeconds, 0]);
            root.currentSessionDbId = rs.insertId;
        });
    }

    function updateHeartbeatInDb() {
        if (!db || root.currentSessionDbId === null) return;
        db.transaction(function(tx) {
            tx.executeSql("UPDATE sessions SET elapsed_seconds=? WHERE id=?", [root.totalSeconds - root.secondsLeft, root.currentSessionDbId]);
        });
    }

    function endSessionInDb(finalStatus) {
        if (!db || root.currentSessionDbId === null) return;
        db.transaction(function(tx) {
            tx.executeSql("UPDATE sessions SET elapsed_seconds=?, status=? WHERE id=?", [root.totalSeconds - root.secondsLeft, finalStatus, root.currentSessionDbId]);
        });
        root.currentSessionDbId = null;
    }

    function switchMode() {
        currentMode = (currentMode === "Focus") ? "Break" : "Focus";
        totalSeconds = (currentMode === "Focus") ? focusTimeMinutes * 60 : breakTimeMinutes * 60;
        secondsLeft = totalSeconds;
    }

    function formatTime(seconds) {
        var mins = Math.floor(seconds / 60);
        var secs = seconds % 60;
        return (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs;
    }

    Timer {
        id: countdownTimer
        interval: 1000; repeat: true; running: root.isRunning
        onTriggered: {
            if (root.secondsLeft > 0) {
                root.secondsLeft--;
                if (root.secondsLeft % 5 === 0) root.updateHeartbeatInDb();
            } else {
                root.isRunning = false;
                if (root.notifyOnEnd) {
                    endSessionNotification.text = root.currentMode + " session has ended!";
                    endSessionNotification.sendEvent();
                }
                root.endSessionInDb("Completed");
                root.switchMode();
            }
        }
    }
}