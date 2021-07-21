import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15
import Heera.Dock 1.0
import HeeraUI 1.0 as HeeraUI
import Heera.Accounts 1.0 as Accounts

ControlCenterDialog {
    id: control
    width: 500
    height: _mainLayout.implicitHeight + HeeraUI.Units.largeSpacing * 4

    property point position: Qt.point(0, 0)

    onWidthChanged: adjustCorrectLocation()
    onHeightChanged: adjustCorrectLocation()
    onPositionChanged: adjustCorrectLocation()

    color: "transparent"

    function adjustCorrectLocation() {
        var posX = control.position.x
        var posY = control.position.y

        // left
        if (posX < 0)
            posX = HeeraUI.Units.largeSpacing

        // top
        if (posY < 0)
            posY = HeeraUI.Units.largeSpacing

        // right
        if (posX + control.width > Screen.width)
            posX = Screen.width - control.width - HeeraUI.Units.largeSpacing

        // bottom
        if (posY > control.height > Screen.width)
            posY = Screen.width - control.width - HeeraUI.Units.largeSpacing

        control.x = posX
        control.y = posY
    }

    Brightness {
        id: brightness
    }

    Accounts.UserAccount {
        id: currentUser
    }

    HeeraUI.RoundedRect {
        id: _background
        anchors.fill: parent
        radius: control.height * 0.05
        color: HeeraUI.Theme.primaryBackgroundColor
        opacity: 0.5
    }

    HeeraUI.WindowShadow {
        view: control
        geometry: Qt.rect(control.x, control.y, control.width, control.height)
        radius: _background.radius
    }

    ColumnLayout {
        id: _mainLayout
        anchors.fill: parent
        anchors.margins: HeeraUI.Units.largeSpacing * 2
        spacing: HeeraUI.Units.largeSpacing

        Item {
            id: topItem
            Layout.fillWidth: true
            height: 50

            RowLayout {
                id: topItemLayout
                anchors.fill: parent
                spacing: HeeraUI.Units.largeSpacing

                Image {
                    id: userIcon
                    Layout.fillHeight: true
                    width: height
                    sourceSize: Qt.size(width, height)
                    source: currentUser.iconFileName ? "file:///" + currentUser.iconFileName : "image://icontheme/default-user"

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Item {
                            width: userIcon.width
                            height: userIcon.height

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.height / 2
                            }
                        }
                    }
                }

                Label {
                    id: userLabel
                    text: currentUser.userName
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    elide: Label.ElideRight
                }

                IconButton {
                    id: settingsButton
                    implicitWidth: topItem.height * 0.8
                    implicitHeight: topItem.height * 0.8
                    Layout.alignment: Qt.AlignTop
                    source: "qrc:/svg/" + (HeeraUI.Theme.darkMode ? "dark/" : "light/") + "settings.svg"
                    onLeftButtonClicked: {
                        control.visible = false
                        process.startDetached("heera-settings")
                    }
                }

                IconButton {
                    id: shutdownButton
                    implicitWidth: topItem.height * 0.8
                    implicitHeight: topItem.height * 0.8
                    Layout.alignment: Qt.AlignTop
                    source: "qrc:/svg/" + (HeeraUI.Theme.darkMode ? "dark/" : "light/") + "system-shutdown-symbolic.svg"
                    onLeftButtonClicked: {
                        control.visible = false
                        process.startDetached("heera-shutdown")
                    }
                }
            }
        }

        Item {
            id: controlItem
            Layout.fillWidth: true
            height: 120
            visible: wirelessItem.visible || bluetoothItem.visible

            RowLayout {
                anchors.fill: parent
                spacing: HeeraUI.Units.largeSpacing

                CardItem {
                    id: wirelessItem
                    Layout.fillHeight: true
                    Layout.preferredWidth: contentItem.width / 3 - HeeraUI.Units.largeSpacing * 3
                    icon: "qrc:/svg/dark/network-wireless-connected-100.svg"
                    visible: networking.wirelessHardwareEnabled
                    checked: networking.wirelessEnabled
                    label: qsTr("Wi-Fi")
                    text: networking.wirelessEnabled ? connectionIconProvider.currentSSID ?
                                                           connectionIconProvider.currentSSID :
                                                           qsTr("On") : qsTr("Off")
                    onClicked: networking.wirelessEnabled = !networking.wirelessEnabled
                }

                CardItem {
                    id: bluetoothItem
                    Layout.fillHeight: true
                    Layout.preferredWidth: contentItem.width / 3 - HeeraUI.Units.largeSpacing * 3
                    icon: "qrc:/svg/light/bluetooth-symbolic.svg"
                    checked: false
                    label: qsTr("Bluetooth")
                    text: qsTr("Off")
                }
                CardItem {
                                    id: darkModeItem
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    icon: HeeraUI.Theme.darkMode || checked ? "qrc:/svg/dark/dark-mode.svg"
                                                                         : "qrc:/svg/light/dark-mode.svg"
                                    checked: HeeraUI.Theme.darkMode
                                    label: qsTr("Dark Mode")
                                    text: HeeraUI.Theme.darkMode ? qsTr("On") : qsTr("Off")
                                    onClicked: appearance.switchDarkMode(!HeeraUI.Theme.darkMode)
                                }

            }
        }

        MprisController {
            height: 100
            Layout.fillWidth: true
        }

        Item {
            id: brightnessItem
            Layout.fillWidth: true
            height: 50
            visible: brightness.enabled

            HeeraUI.RoundedRect {
                id: brightnessItemBg
                anchors.fill: parent
                radius: HeeraUI.Units.largeRadius
                color: HeeraUI.Theme.tertiaryBackgroundColor
                opacity: 0.3
            }

            RowLayout {
                anchors.fill: brightnessItemBg
                anchors.margins: HeeraUI.Units.largeSpacing
                anchors.leftMargin: HeeraUI.Units.largeSpacing * 2
                anchors.rightMargin: HeeraUI.Units.largeSpacing * 2
                spacing: HeeraUI.Units.largeSpacing

                Image {
                    width: parent.height * 0.6
                    height: parent.height * 0.6
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/svg/" + (HeeraUI.Theme.darkMode ? "dark" : "light") + "/brightness.svg"
                }

                Slider {
                    id: brightnessSlider
                    from: 0
                    to: 100
                    stepSize: 1
                    value: brightness.value
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    onMoved: {
                        brightness.setValue(brightnessSlider.value)
                    }
                }
            }
        }

        Item {
            id: volumeItem
            Layout.fillWidth: true
            height: 50
            visible: volume.isValid

            HeeraUI.RoundedRect {
                id: volumeItemBg
                anchors.fill: parent
                anchors.margins: 0
                radius: HeeraUI.Units.largeRadius
                color: HeeraUI.Theme.tertiaryBackgroundColor
                opacity: 0.3
            }

            RowLayout {
                anchors.fill: volumeItemBg
                anchors.margins: HeeraUI.Units.largeSpacing
                anchors.leftMargin: HeeraUI.Units.largeSpacing * 2
                anchors.rightMargin: HeeraUI.Units.largeSpacing * 2
                spacing: HeeraUI.Units.largeSpacing

                Image {
                    width: parent.height * 0.6
                    height: parent.height * 0.6
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/svg/" + (HeeraUI.Theme.darkMode ? "dark" : "light") + "/" + volume.iconName + ".svg"
                }

                Slider {
                    id: slider
                    from: 0
                    to: 100
                    stepSize: 1
                    value: volume.volume
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    onValueChanged: {
                        volume.setVolume(value)

                        if (volume.isMute && value > 0)
                            volume.setMute(false)
                    }
                }
            }
        }

        RowLayout {
            Label {
                id: timeLabel

                Timer {
                    interval: 1000
                    repeat: true
                    running: true
                    triggeredOnStart: true
                    onTriggered: {
                        timeLabel.text = new Date().toLocaleString(Qt.locale(), Locale.LongFormat)
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                visible: battery.available
                Image {
                    id: batteryIcon
                    width: 22
                    height: 16
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/svg/" + (HeeraUI.Theme.darkMode ? "dark/" : "light/") + battery.iconSource
                    asynchronous: true

                }

                Label {
                    text: battery.chargePercent + "%"
                    color: HeeraUI.Theme.textColor
                }
            }
        }
    }
}
