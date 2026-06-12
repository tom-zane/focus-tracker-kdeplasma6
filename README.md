# Focus Tracker for KDE Plasma 6

A native, lightweight, and highly integrated Pomodoro focus timer widget built specifically for the KDE Plasma 6 desktop environment. 

Focus Tracker helps you manage your time seamlessly, right from your desktop or taskbar. Designed with modern Kirigami components, it blends perfectly with your system's aesthetic while providing powerful session tracking to boost your productivity.

---

## ✨ Key Features

* **Taskbar & Desktop Integration:** 
  * **Panel Mode:** Docks neatly into your taskbar. Displays a live, miniature progress ring and dynamic icons (Play, Pause, Break) so you can see your status at a glance without opening the widget.
  * **Desktop Mode:** Place it directly on your desktop as a persistent, floating timer dashboard.
* **Session History & Tracking:** 
  * Automatically saves completed, skipped, and interrupted sessions to a local SQLite database (`FocusTrackerDB`).
  * Dedicated History Window to review your daily productivity and past sessions.
* **Native KDE Design:** 
  * Built using standard KDE Kirigami and Plasma components.
  * Honors your system's color schemes, accent colors, and typography.
* **Customizable Sessions:** 
  * Easily toggle between **Focus** and **Break** modes.
  * Sleek UI controls to Play, Pause, Skip, or Stop sessions.
* **System Notifications:** Integrates deeply with KDE's notification system to alert you the moment a session ends.

---

## 🛠️ Prerequisites

Before installing, ensure your system meets the following requirements:
* **KDE Plasma 6.x** or higher
* **KDE Frameworks 6**
* `kpackagetool6` (Included in standard Plasma development/packaging tools)

---

## 🚀 Installation

1. **Clone the repository:**
   Download the source code to your local machine.
```bash
   git clone [https://github.com/tom-zane/kde-focus-tracker.git](https://github.com/tom-zane/kde-focus-tracker.git)
   cd kde-focus-tracker/package
   ```
   *(Note: Make sure your terminal is in the directory containing the `metadata.json` file).*

2. **Install the Applet:**
   Use the official KDE package tool to install the widget into your local user directory.
```bash
   kpackagetool6 -t Plasma/Applet -i .
   ```

3. **Restart the Plasma Shell:**
   To force Plasma to recognize the newly installed widget and its icons, restart the shell:
```bash
   plasmashell --replace &
   ```

---

## 🖱️ How to Use (Running the Widget)

Once installed, adding Focus Tracker to your workflow is easy:

1. **Add to Panel (Taskbar):**
   * Right-click an empty space on your Plasma Panel.
   * Select **Add Widgets...**
   * Search for **Focus Tracker**.
   * Drag and drop the widget onto your panel. 
   * *Behavior:* It will appear as a compact clock icon with a progress ring. Click it to expand the full timer dashboard.

2. **Add to Desktop:**
   * Right-click an empty space on your Desktop.
   * Select **Add Widgets...**
   * Drag and drop **Focus Tracker** directly onto your wallpaper.
   * *Behavior:* It will immediately display the full timer dashboard.

3. **Using the Timer:**
   * **Start/Pause:** Click the large central button to begin or pause your current session.
   * **Skip:** Click the skip forward icon to end the current session early and jump to the next mode (Focus -> Break -> Focus).
   * **Stop:** Click the square stop button to completely interrupt and reset the current timer.
   * **History:** Click the top-right history icon to view your past session database.

---

## 🔄 Updating

If you download a newer version of the source code or make custom edits to the QML files, you must push the update to your system:

1. Navigate to your project folder (`.../kde-focus-tracker/package`).
2. Run the update command:
```bash
   kpackagetool6 -t Plasma/Applet -u .
   ```
3. Restart the Plasma shell to load the new files into memory:
```bash
   plasmashell --replace &
   ```

---

## 🗑️ Uninstallation

To completely remove the widget from your system, run the following command in your terminal:

```bash
kpackagetool6 -t Plasma/Applet -r com.github.tom-zane.focus-tracker
```
*(You may need to restart the Plasma shell (`plasmashell --replace &`) afterward to remove any lingering visual caches).*

---

## 📄 License
This project is open-source and licensed under the [GNU General Public License v2.0](LICENSE) (GPL-2.0+). Feel free to fork, modify, and distribute!
