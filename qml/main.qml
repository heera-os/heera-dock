import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15

import Heera.NetworkManagement 1.0 as NM
import Heera.Dock 1.0
import HeeraUI 1.0 as HeeraUI

Item {
    id: root
    visible: true
    clip: true

    property color backgroundColor: HeeraUI.Theme.darkMode ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(255, 255, 255, 0.45)
    property color borderColor: HeeraUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.1) : Qt.rgba(0, 0, 0, 0.05)
    property real windowRadius: (Settings.direction === DockSettings.Left) ? root.width * 0.3 : root.height * 0.3
    property bool isHorizontal: Settings.direction !== DockSettings.Left
    property var appViewLength: isHorizontal ? appItemView.width : appItemView.height
    property real iconSize: 0

    Timer {
        id: resizeIconTimer
        interval: 100
        running: false
        repeat: false
        triggeredOnStart: true
        onTriggered: calcIconSize()
    }

    function delayCalcIconSize() {
        resizeIconTimer.running = true
    }

    function calcIconSize() {
        var size = Settings.iconSize

        while (1) {
            if (appItemView.count * size <= root.appViewLength)
                break

            size--
        }

        root.iconSize = size
    }

    Volume {
        id: volume
    }

    Battery {
        id: battery
    }

    NM.ConnectionIcon {
        id: connectionIconProvider
    }

    NM.Networking {
        id: networking
    }

    HeeraUI.WindowShadow {
        view: mainWindow
        geometry: Qt.rect(root.x, root.y, root.width, root.height)
        radius: _background.radius
    }


    Rectangle {
        id: _background
        anchors.fill: parent
        radius: windowRadius
        color: HeeraUI.Theme.primaryBackgroundColor
        opacity: Settings.dockTransparency == true ? 0.4 : 1

        Behavior on color {
            ColorAnimation {
                duration: 125
                easing.type: Easing.InOutCubic
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            radius: windowRadius
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.9)
            antialiasing: true
            smooth: true
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: windowRadius - 1
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(255, 255, 255, 0.5)
            antialiasing: true
            smooth: true
        }
    }

    HeeraUI.PopupTips {
        id: popupTips
    }

    GridLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.rightMargin: isHorizontal ? HeeraUI.Units.smallSpacing : 0
        anchors.bottomMargin: isHorizontal ? 0 : HeeraUI.Units.smallSpacing
        flow: isHorizontal ? Grid.LeftToRight : Grid.TopToBottom
        rowSpacing: 0
        columnSpacing: 0

        DockItem {
            id: launcherItem
            implicitWidth: root.iconSize
            implicitHeight: root.iconSize
            enableActivateDot: false
            iconName: "qrc:/svg/launcher.svg"
            popupText: qsTr("Launcher")
            onClicked: process.startDetached("heera-launcher")
            Layout.alignment: Qt.AlignCenter
        }
        ToolSeparator {}
        Rectangle {
            width: 50
            height: root.height ? root.height / 4 : 1
            color: "transparent"
            border.color: "transparent"
            border.width: 0
            radius: 0
        }

        ListView {
            id: appItemView
            orientation: isHorizontal ? Qt.Horizontal : Qt.Vertical
            snapMode: ListView.SnapToItem
            clip: true
            model: appModel
            interactive: true
            highlight: highlightBar

            Layout.fillHeight: true
            Layout.fillWidth: true

            delegate: AppItem {
                implicitWidth: isHorizontal ? root.iconSize : appItemView.width
                implicitHeight: isHorizontal ? appItemView.height : root.iconSize
            }

            moveDisplaced: Transition {
                NumberAnimation {
                    properties: "x, y"
                    duration: 300
                    easing.type: Easing.InOutCubic
                }
            }
        }

        ListView {
            id: systemTrayView
            spacing: HeeraUI.Units.smallSpacing
            Layout.preferredWidth: isHorizontal ? count * itemHeight + (count - 1) * spacing : mainLayout.width * 0.7
            Layout.preferredHeight: isHorizontal ? mainLayout.height * 0.7 : count * itemHeight + (count - 1) * spacing
            Layout.alignment: Qt.AlignCenter
            model: trayModel
            orientation: isHorizontal ? Qt.Horizontal : Qt.Vertical
            layoutDirection: Qt.RightToLeft
            interactive: false
            clip: true

            onCountChanged: delayCalcIconSize()

            property var itemWidth: isHorizontal ? itemHeight / 2 + HeeraUI.Units.smallSpacing : mainLayout.width * 0.7
            property var itemHeight: isHorizontal ? mainLayout.height * 0.7 : itemWidth / 2

            StatusNotifierModel {
                id: trayModel
            }

            delegate: StandardItem {
                height: systemTrayView.itemHeight
                width: systemTrayView.itemWidth

                Image {
                    anchors.centerIn: parent
                    source: iconName ? "image://icontheme/" + iconName
                                     : iconBytes ? "data:image/png;base64," + iconBytes
                                                 : "image://icontheme/application-x-desktop"
                    width: 16
                    height: width
                    sourceSize.width: width
                    sourceSize.height: height
                    asynchronous: true
                }

                onClicked: trayModel.leftButtonClick(id)
                onRightClicked: trayModel.rightButtonClick(id)
                popupText: toolTip ? toolTip : title
            }
        }

        StandardItem {
            id: controlItem
            Layout.preferredWidth: isHorizontal ? controlLayout.implicitWidth : mainLayout.width * 0.7
            Layout.preferredHeight: isHorizontal ? mainLayout.height * 0.7 : controlLayout.implicitHeight
            Layout.alignment: Qt.AlignCenter
            Layout.rightMargin: isHorizontal ? HeeraUI.Units.smallSpacing : 0
            Layout.bottomMargin: isHorizontal ? 0 : HeeraUI.Units.smallSpacing

            onClicked: {
                if (controlCenter.visible)
                    controlCenter.visible = false
                else {
                    controlCenter.visible = true
                    controlCenter.position = Qt.point(mapToGlobal(0, 0).x, mapToGlobal(0, 0).y)
                }
            }

            GridLayout {
                id: controlLayout
                anchors.fill: parent
                flow: isHorizontal ? Grid.LeftToRight : Grid.TopToBottom
                columnSpacing: isHorizontal ? HeeraUI.Units.largeSpacing * 1.5 : 0
                rowSpacing: isHorizontal ? 0 : HeeraUI.Units.largeSpacing * 1.5

                // Padding
                Item {
                    width: 1
                    height: 1
                }

                Image {
                    id: networkIcon
                    width: 16
                    height: width
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/svg/" + (HeeraUI.Theme.darkMode ? "dark/" : "light/") +
                            connectionIconProvider.connectionTooltipIcon + ".svg"
                    asynchronous: true
                    Layout.alignment: Qt.AlignCenter
                    visible: networking.enabled && status === Image.Ready
                }

                Image {
                    id: batteryIcon
                    visible: battery.available && status === Image.Ready
                    width: 22
                    height: 16
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/svg/" + (HeeraUI.Theme.darkMode ? "dark/" : "light/") + battery.iconSource
                    asynchronous: true
                    Layout.alignment: Qt.AlignCenter
                }
              Label {
                    text: battery.chargePercent + "%"
                    color: HeeraUI.Theme.textColor
                }

                Image {
                    id: volumeIcon
                    visible: volume.isValid && status === Image.Ready
                    source: "qrc:/svg/" + (HeeraUI.Theme.darkMode ? "dark/" : "light/") + volume.iconName + ".svg"
                    width: 16
                    height: width
                    sourceSize: Qt.size(width, height)
                    asynchronous: true
                    Layout.alignment: Qt.AlignCenter
                }



                // Padding
                Item {
                    width: 1
                    height: 1
                }
            }

            DropShadow {
                source: controlLayout
                anchors.fill: controlLayout
                radius: 20.0
                samples: 17
                color: "black"
                verticalOffset: 2
                visible: HeeraUI.Theme.darkMode
            }
        }




        StandardItem {
            id: datetimeitem
            Layout.fillHeight: true
            Layout.preferredWidth: today.implicitWidth + HeeraUI.Units.smallSpacing



            Column {
                anchors.fill: parent
                Text {
                    id: time
                    font {

                      pointSize: root.height ? root.height / 4 : 1
                    }
                    color: HeeraUI.Theme.textColor
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    id: today
                    font {

                     pointSize: root.height ? root.height / 6 : 1
                    }
                    color: HeeraUI.Theme.textColor
                    anchors.horizontalCenter: parent.horizontalCenter

                }
            }

            Timer {
                interval: 500
                running: true
                repeat: true

                onTriggered: {
                    var date = new Date()
                    time.text = date.toLocaleTimeString(Qt.locale(), "hh:mm ap")
                    today.text = date.toLocaleDateString(Qt.locale(), "yyyy-dd-MM dddd")
                }
            }
        }


    }

    ControlCenter {
        id: controlCenter
    }

    Connections {
        target: Settings
        function onDirectionChanged() {
            popupTips.hide()
        }
    }

}
