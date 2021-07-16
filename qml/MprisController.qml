import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import HeeraUI 1.0 as HeeraUI
import Heera.Mpris 1.0

Item {
    id: control
    visible: control.currentService && (_songLabel.text != "" || _artistLabel.text != "")

    property bool available: if (currentService)
                                 return true
                             else
                                 return false

    property bool isPlaying: currentService && mprisManager.playbackStatus === Mpris.Playing
    property alias currentService: mprisManager.currentService
    property var artUrlTag: Mpris.metadataToString(Mpris.ArtUrl)
    property var titleTag: Mpris.metadataToString(Mpris.Title)
    property var artistTag: Mpris.metadataToString(Mpris.Artist)

    MprisManager {
        id: mprisManager
    }

    HeeraUI.RoundedRect {
        id: _background
        anchors.fill: parent
        anchors.margins: 0
        radius: HeeraUI.Units.largeRadius
        color: HeeraUI.Theme.tertiaryBackgroundColor
        opacity: 0.3
    }

    RowLayout {
        id: _mainLayout
        anchors.fill: parent
        anchors.margins: HeeraUI.Units.largeSpacing
        anchors.leftMargin: HeeraUI.Units.largeSpacing * 2
        anchors.rightMargin: HeeraUI.Units.largeSpacing * 2
        spacing: HeeraUI.Units.largeSpacing

        Image {
            id: artImage
            Layout.fillHeight: true
            width: height
            visible: status === Image.Ready
            sourceSize: Qt.size(width, height)
            source: control.available ? (artUrlTag in mprisManager.metadata) ? mprisManager.metadata[artUrlTag].toString() : "" : ""

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: artImage.width
                    height: artImage.height

                    Rectangle {
                        anchors.fill: parent
                        radius: HeeraUI.Units.largeRadius
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent

                Item {
                    Layout.fillHeight: true
                }

                Label {
                    id: _songLabel
                    Layout.fillWidth: true
                    visible: _songLabel.text !== ""
                    text: control.available ? (titleTag in mprisManager.metadata) ? mprisManager.metadata[titleTag].toString() : "" : ""
                    elide: Text.ElideRight
                }

                Label {
                    id: _artistLabel
                    Layout.fillWidth: true
                    visible: _artistLabel.text !== ""
                    text: control.available ? (artistTag in mprisManager.metadata) ? mprisManager.metadata[artistTag].toString() : "" : ""
                    elide: Text.ElideRight
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }

        Item {
            id: _buttons
            Layout.fillHeight: true
            Layout.preferredWidth: _mainLayout.width / 3

            RowLayout {
                anchors.fill: parent

                IconButton {
                    width: 33
                    height: 33
                    source: "qrc:/svg/" + (HeeraUI.Theme.darkMode ? "dark" : "light") + "/media-skip-backward-symbolic.svg"
                    onLeftButtonClicked: if (mprisManager.canGoPrevious) mprisManager.previous()
                    visible: control.available ? mprisManager.canGoPrevious : false
                    Layout.alignment: Qt.AlignRight
                }

                IconButton {
                    width: 33
                    height: 33
                    source: control.isPlaying ? "qrc:/svg/" + (HeeraUI.Theme.darkMode ? "dark" : "light") + "/media-playback-pause-symbolic.svg"
                                              : "qrc:/svg/" + (HeeraUI.Theme.darkMode ? "dark" : "light") + "/media-playback-start-symbolic.svg"
                    Layout.alignment: Qt.AlignRight
                    visible: control.available ? mprisManager.canPause || mprisManager.canPlay : false
                    onLeftButtonClicked:
                        if ((control.isPlaying && mprisManager.canPause) || (!control.isPlaying && mprisManager.canPlay)) {
                            mprisManager.playPause()
                        }
                }

                IconButton {
                    width: 33
                    height: 33
                    source: "qrc:/svg/" + (HeeraUI.Theme.darkMode ? "dark" : "light") + "/media-skip-forward-symbolic.svg"
                    Layout.alignment: Qt.AlignRight
                    onLeftButtonClicked: if (mprisManager.canGoNext) mprisManager.next()
                    visible: control.available ? mprisManager.canGoNext : false
                }
            }
        }
    }
}
