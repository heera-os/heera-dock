import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import HeeraUI 1.0 as HeeraUI
import Heera.Dock 1.0

Item {
    id: control

    property var popupText: ""

    signal clicked
    signal rightClicked

    MouseArea {
        id: _mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true

        onClicked: {
            if (mouse.button == Qt.LeftButton)
                control.clicked()
            else if (mouse.button == Qt.RightButton)
                control.rightClicked()
        }

        onPressed: {
            popupTips.hide()
        }

        onContainsMouseChanged: {
            if (containsMouse && control.popupText !== "") {
                popupTips.popupText = control.popupText

                if (Settings.direction === DockSettings.Left)
                    popupTips.position = Qt.point(root.width + HeeraUI.Units.largeSpacing,
                                                  control.mapToGlobal(0, 0).y + (control.height / 2 - popupTips.height / 2))
                else
                    popupTips.position = Qt.point(control.mapToGlobal(0, 0).x + (control.width / 2 - popupTips.width / 2),
                                                  mainWindow.y - popupTips.height - HeeraUI.Units.smallSpacing / 2)

                popupTips.show()
            } else {
                popupTips.hide()
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: HeeraUI.Units.smallRadius

        color: {
            if (_mouseArea.containsMouse) {
                if (_mouseArea.containsPress)
                    return (HeeraUI.Theme.darkMode) ? Qt.rgba(255, 255, 255, 0.3) : Qt.rgba(0, 0, 0, 0.2)
                else
                    return (HeeraUI.Theme.darkMode) ? Qt.rgba(255, 255, 255, 0.2) : Qt.rgba(0, 0, 0, 0.1)
            }

            return "transparent"
        }

        Behavior on color {
            ColorAnimation {
                duration: 125
                easing.type: Easing.InOutCubic
            }
        }
    }
}
