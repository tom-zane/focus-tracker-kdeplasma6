import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import QtQuick.LocalStorage
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

Window {
    id: historyWindow
    width: 750 
    height: 850
    title: "Focus Tracker Dashboard"
    color: Kirigami.Theme.backgroundColor
    
    onClosing: destroy()

    property color accentColor: Kirigami.Theme.highlightColor
    property string customFontFamily: "sans-serif"

    property int dailyGoalHours: 4
    property int todayMinutes: 0
    property int streakDays: 0
    
    property var last7DaysData: []
    property var last4WeeksData: []
    property var calendarCells: []
    property string currentMonthStr: ""
    
    property int viewYear: new Date().getFullYear()
    property int viewMonth: new Date().getMonth()

    property var dailyTotalsMap: ({})

    Component.onCompleted: {
        fetchDatabaseData();
    }

    function fetchDatabaseData() {
        try {
            var db = LocalStorage.openDatabaseSync("FocusTrackerDB", "1.0", "Storage for Focus Sessions", 100000);
            var totals = {};

            db.readTransaction(function(tx) {
                var rs = tx.executeSql("SELECT date(timestamp, 'localtime') as day, SUM(elapsed_seconds) as total_seconds FROM sessions WHERE type='Focus' GROUP BY day ORDER BY day DESC");
                
                for (var i = 0; i < rs.rows.length; i++) {
                    var row = rs.rows.item(i);
                    totals[row.day] = row.total_seconds;
                }
            });

            dailyTotalsMap = totals;
            processDataIntoUI();

        } catch (err) {
            console.error("Error reading database for History:", err);
        }
    }

    function toISODate(d) {
        var tzOffset = (new Date()).getTimezoneOffset() * 60000;
        return (new Date(d - tzOffset)).toISOString().split('T')[0];
    }

    function formatShortDate(d) {
        const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        return d.getDate() + " " + months[d.getMonth()];
    }

    function formatDuration(minutes) {
        if (minutes < 60) return minutes + "m";
        let h = Math.floor(minutes / 60);
        let m = minutes % 60;
        return m > 0 ? (h + "h " + m + "m") : (h + "h");
    }

    function processDataIntoUI() {
        let now = new Date();
        
        let todayStr = toISODate(now);
        historyWindow.todayMinutes = Math.floor((dailyTotalsMap[todayStr] || 0) / 60);

        let currentStreak = 0;
        let checkDate = new Date();
        
        if ((dailyTotalsMap[toISODate(checkDate)] || 0) > 0) {
            currentStreak++;
        }
        checkDate.setDate(checkDate.getDate() - 1);

        while (true) {
            let val = dailyTotalsMap[toISODate(checkDate)] || 0;
            if (val > 0) {
                currentStreak++;
                checkDate.setDate(checkDate.getDate() - 1);
            } else {
                break;
            }
        }
        historyWindow.streakDays = currentStreak;

        let days = [];
        for (let i = 6; i >= 0; i--) { 
            let tempD = new Date(now);
            tempD.setDate(now.getDate() - i);
            let mins = Math.floor((dailyTotalsMap[toISODate(tempD)] || 0) / 60);
            
            days.push({ 
                label: (i === 0) ? "Today" : formatShortDate(tempD), 
                isToday: (i === 0),
                time: formatDuration(mins)
            });
        }
        last7DaysData = days;

        let weeks = [];
        for (let i = 3; i >= 0; i--) { 
            let endD = new Date();
            endD.setDate(endD.getDate() - (i * 7));
            let startD = new Date(endD);
            startD.setDate(endD.getDate() - 6);
            
            let weekSeconds = 0;
            for(let j = 0; j <= 6; j++) {
                let tempD = new Date(startD);
                tempD.setDate(startD.getDate() + j);
                weekSeconds += (dailyTotalsMap[toISODate(tempD)] || 0);
            }
            
            weeks.push({ 
                label: (i === 0) ? "This Week" : formatShortDate(startD) + " - " + formatShortDate(endD), 
                isThisWeek: (i === 0),
                hours: Math.round(weekSeconds / 3600)
            });
        }
        last4WeeksData = weeks;

        renderCalendar(viewYear, viewMonth);
    }

    function renderCalendar(year, month) {
        const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        currentMonthStr = monthNames[month] + " " + year;
        
        let firstDay = new Date(year, month, 1).getDay(); 
        let daysInMonth = new Date(year, month + 1, 0).getDate();
        
        let cells = [];
        for (let i = 0; i < firstDay; i++) {
            cells.push({ day: "", valid: false, hours: 0 });
        }
        
        // Match dates against database map
        for (let i = 1; i <= daysInMonth; i++) {
            let padMonth = (month + 1).toString().padStart(2, '0');
            let padDay = i.toString().padStart(2, '0');
            let dateStr = year + "-" + padMonth + "-" + padDay;
            
            let daySeconds = dailyTotalsMap[dateStr] || 0;
            let hoursLogged = Math.round(daySeconds / 3600); // Convert seconds to rounded hours
            
            cells.push({ day: i, valid: true, hours: hoursLogged }); 
        }
        calendarCells = cells;
    }

    function changeMonth(offset) {
        viewMonth += offset;
        if (viewMonth < 0) { viewMonth = 11; viewYear--; }
        if (viewMonth > 11) { viewMonth = 0; viewYear++; }
        renderCalendar(viewYear, viewMonth); // Re-render with new month
    }

    function getHeatmapColor(hours, valid) {
        if (!valid) return "transparent";
        if (hours <= 0) return Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.05);
        if (hours <= 2) return Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.25);
        if (hours <= 4) return Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.50);
        if (hours <= 6) return Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.75);
        return Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 1.0); 
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing * 2
        spacing: Kirigami.Units.largeSpacing * 2

        RowLayout {
            Layout.fillWidth: true
            PlasmaComponents.Label {
                text: "Focus Dashboard"
                font.family: historyWindow.customFontFamily
                font.pixelSize: 24
                font.weight: Font.Black
                Layout.fillWidth: true
            }
            PlasmaComponents.Label {
                text: "🔥 " + historyWindow.streakDays + " Day Streak"
                font.family: historyWindow.customFontFamily
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: historyWindow.accentColor
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            color: historyWindow.accentColor
            radius: 8
            
            ColumnLayout {
                anchors.centerIn: parent
                PlasmaComponents.Label {
                    text: "Today's Focus"
                    font.family: historyWindow.customFontFamily
                    color: "#ffffff" 
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    Layout.alignment: Qt.AlignHCenter
                }
                PlasmaComponents.Label {
                    text: Math.floor(historyWindow.todayMinutes / 60) + "h " + (historyWindow.todayMinutes % 60) + "m"
                    font.family: historyWindow.customFontFamily
                    color: "#ffffff"
                    font.pixelSize: 54
                    font.weight: Font.Black
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        PlasmaComponents.Label { 
            text: "Last 7 Days"; 
            font.family: historyWindow.customFontFamily
            font.weight: Font.ExtraBold 
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            
            Repeater {
                model: historyWindow.last7DaysData
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 65
                    color: modelData.isToday ? historyWindow.accentColor : "transparent"
                    border.color: modelData.isToday ? "transparent" : Qt.rgba(historyWindow.accentColor.r, historyWindow.accentColor.g, historyWindow.accentColor.b, 0.3)
                    border.width: 1
                    radius: 4

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2
                        PlasmaComponents.Label {
                            text: modelData.label
                            font.family: historyWindow.customFontFamily
                            font.pixelSize: 11
                            color: modelData.isToday ? "#ffffff" : Kirigami.Theme.textColor
                            Layout.alignment: Qt.AlignHCenter
                        }
                        PlasmaComponents.Label {
                            text: modelData.time
                            font.family: historyWindow.customFontFamily
                            font.weight: Font.Bold
                            font.pixelSize: 16
                            color: modelData.isToday ? "#ffffff" : Kirigami.Theme.textColor
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }

        PlasmaComponents.Label { 
            text: "Last 4 Weeks"; 
            font.family: historyWindow.customFontFamily
            font.weight: Font.ExtraBold 
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            
            Repeater {
                model: historyWindow.last4WeeksData
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 65
                    color: modelData.isThisWeek ? historyWindow.accentColor : "transparent"
                    border.color: modelData.isThisWeek ? "transparent" : Qt.rgba(historyWindow.accentColor.r, historyWindow.accentColor.g, historyWindow.accentColor.b, 0.3)
                    border.width: 1
                    radius: 4

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2
                        PlasmaComponents.Label {
                            text: modelData.label
                            font.family: historyWindow.customFontFamily
                            font.pixelSize: 11
                            color: modelData.isThisWeek ? "#ffffff" : Kirigami.Theme.textColor
                            Layout.alignment: Qt.AlignHCenter
                        }
                        PlasmaComponents.Label {
                            text: modelData.hours + "h"
                            font.family: historyWindow.customFontFamily
                            font.weight: Font.Bold
                            font.pixelSize: 16
                            color: modelData.isThisWeek ? "#ffffff" : Kirigami.Theme.textColor
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }

        // --- Monthly Heatmap Calendar ---
        RowLayout {
            Layout.fillWidth: true
            PlasmaComponents.Label { 
                text: "Monthly Heatmap"; 
                font.family: historyWindow.customFontFamily
                font.weight: Font.ExtraBold; 
                Layout.fillWidth: true 
            }
            PlasmaComponents.Button { 
                icon.name: "go-previous"
                display: PlasmaComponents.AbstractButton.IconOnly
                onClicked: changeMonth(-1)
            }
            PlasmaComponents.Label { 
                text: historyWindow.currentMonthStr
                font.family: historyWindow.customFontFamily
                font.weight: Font.Bold 
                Layout.minimumWidth: 100
                horizontalAlignment: Text.AlignHCenter
            }
            PlasmaComponents.Button { 
                icon.name: "go-next"
                display: PlasmaComponents.AbstractButton.IconOnly
                onClicked: changeMonth(1)
            }
        }

        // Days of Week Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 4
            Repeater {
                model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                delegate: PlasmaComponents.Label {
                    Layout.fillWidth: true
                    text: modelData
                    font.family: historyWindow.customFontFamily
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignHCenter
                    opacity: 0.6
                }
            }
        }

        // Calendar Grid
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 7
            rowSpacing: 4
            columnSpacing: 4

            Repeater {
                model: historyWindow.calendarCells 
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 4
                    color: historyWindow.getHeatmapColor(modelData.hours, modelData.valid)

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 0
                        visible: modelData.valid
                        
                        PlasmaComponents.Label {
                            text: modelData.day
                            font.family: historyWindow.customFontFamily
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            Layout.alignment: Qt.AlignHCenter
                            color: modelData.hours > 4 ? "#ffffff" : Kirigami.Theme.textColor
                        }
                        PlasmaComponents.Label {
                            text: modelData.hours > 0 ? modelData.hours + "h" : ""
                            font.family: historyWindow.customFontFamily
                            font.pixelSize: 10
                            opacity: 0.7
                            Layout.alignment: Qt.AlignHCenter
                            color: modelData.hours > 4 ? "#ffffff" : Kirigami.Theme.textColor
                        }
                    }
                }
            }
        }
    }
}