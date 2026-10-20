import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import "HyprlandClientPickerModel.js" as HyprlandClientPickerModel

Item {
  id: root
  property var shell: null
  property bool opened: false
  property var clients: []
  property int selectedIndex: 0
  property string error: ""
  readonly property var matches: HyprlandClientPickerModel.filterClients(clients, search.text)

  function open() {
    clients = []
    error = ""
    search.text = ""
    selectedIndex = 0
    opened = true
    if (!listProc.running) listProc.running = true
    Qt.callLater(function() { search.forceActiveFocus() })
  }

  function close() { opened = false }

  function dismiss() {
    if (shell) shell.hide("sjb.hyprland-client-picker")
    else close()
  }

  function moveSelection(delta) {
    if (matches.length === 0) return
    selectedIndex = Math.max(0, Math.min(matches.length - 1, selectedIndex + delta))
    results.positionViewAtIndex(selectedIndex, ListView.Contain)
  }

  function activate(fetch) {
    if (selectedIndex >= matches.length || actionProc.running) return
    actionProc.command = HyprlandClientPickerModel.dispatchClient(matches[selectedIndex], fetch)
    actionProc.running = true
    opened = false
  }

  Process {
    id: listProc
    command: ["hyprctl", "clients", "-j"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var parsed = HyprlandClientPickerModel.parseClients(text)
        if (parsed === null) root.error = "Could not read Hyprland clients"
        else root.clients = parsed
      }
    }
    onExited: function(exitCode) {
      if (exitCode !== 0) root.error = "Could not list Hyprland clients"
    }
  }

  Process {
    id: actionProc
    onExited: function(exitCode) {
      if (exitCode !== 0) console.warn("Hyprland client picker: dispatch failed:", exitCode)
      root.dismiss()
    }
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "sjb.hyprland-client-picker"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: Color.menu.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    Rectangle {
      id: card
      width: Math.min(520, panel.width - 48)
      height: Math.min(panel.height - 48, Math.max(160, Math.min(root.matches.length, 7) * 50 + 102))
      anchors.centerIn: parent
      radius: Style.cornerRadius
      color: Color.menu.background
      border.color: Color.menu.border
      border.width: 1

      MouseArea { anchors.fill: parent; onClicked: {} }

      Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        TextInput {
          id: search
          width: parent.width
          height: 28
          color: Color.menu.text
          font.family: Style.font.menuFamily
          font.pixelSize: Style.font.heading
          clip: true
          onTextChanged: { root.selectedIndex = 0; results.positionViewAtBeginning() }
          Keys.priority: Keys.BeforeItem
          Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) root.dismiss()
            else if (event.key === Qt.Key_Up) root.moveSelection(-1)
            else if (event.key === Qt.Key_Down) root.moveSelection(1)
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
              root.activate((event.modifiers & Qt.ControlModifier) !== 0)
            else return
            event.accepted = true
          }

          Text {
            visible: !search.text
            text: "Search clients…"
            color: Color.menu.text
            opacity: 0.55
            font: search.font
          }
        }

        Item {
          width: parent.width
          height: Math.max(0, card.height - 102)

          ListView {
            id: results
            anchors.fill: parent
            clip: true
            model: root.matches
            delegate: Rectangle {
              required property var modelData
              required property int index
              width: ListView.view.width
              height: 50
              radius: Style.cornerRadius
              color: index === root.selectedIndex ? Color.menu.selectedBackground : "transparent"

              Text {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 12
                text: (modelData.title || modelData.class || "Untitled") + "  ·  " + (modelData.class || "")
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: index === root.selectedIndex ? Color.menu.selectedText : Color.menu.text
                font.family: Style.font.menuFamily
                font.pixelSize: Style.font.body
              }

              MouseArea {
                anchors.fill: parent
                onClicked: { root.selectedIndex = index; root.activate(false) }
              }
            }
          }

          Text {
            anchors.centerIn: parent
            visible: root.matches.length === 0
            text: root.error || "No matching clients"
            color: Color.menu.text
            font.family: Style.font.menuFamily
          }
        }

        Text {
          text: "Enter: focus   ·   Ctrl+Enter: fetch"
          color: Color.menu.text
          opacity: 0.6
          font.family: Style.font.menuFamily
          font.pixelSize: Style.font.caption
        }
      }
    }
  }
}
