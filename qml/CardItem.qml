import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15
import HeeraUI 1.0 as HeeraUI

Item {
    id: control

    property bool checked: false
    property alias icon: _image.source
    property alias label: _titleLabel.text
    property alias text: _label.text

    signal clicked
    
    MouseArea {
        id: _mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: control.clicked()
    }

    HeeraUI.RoundedRect {
        anchors.fill: parent
        radius: HeeraUI.Units.largeRadius
        opacity: control.checked ? 1 : _mouseArea.containsMouse ? 0.7 : 0.3
        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutCubic
            }
        }
        color: control.checked ? HeeraUI.Theme.highlightColor : HeeraUI.Theme.tertiaryBackgroundColor
        Behavior on color {
            ColorAnimation {
                duration: 250
                easing.type: Easing.InOutCubic
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Image {
            id: _image
            Layout.preferredWidth: control.height / 3
            Layout.preferredHeight: control.height / 3
            sourceSize: Qt.size(width, height)
            asynchronous: true
            Layout.alignment: Qt.AlignCenter
            Layout.topMargin: HeeraUI.Units.largeSpacing

            ColorOverlay {
                anchors.fill: _image
                source: _image
                color: control.checked ? HeeraUI.Theme.highlightedTextColor : HeeraUI.Theme.disabledTextColor
                Behavior on color {
                    ColorAnimation {
                        duration: 125
                        easing.type: Easing.InOutCubic
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Label {
            id: _titleLabel
            color: control.checked ? HeeraUI.Theme.highlightedTextColor : HeeraUI.Theme.disabledTextColor
            Layout.alignment: Qt.AlignHCenter
        }

        Label {
            id: _label
            Layout.maximumWidth: control.width * 0.9
            color: control.checked ? HeeraUI.Theme.highlightedTextColor : HeeraUI.Theme.textColor
            clip: true
            elide: Label.ElideRight
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: HeeraUI.Units.largeSpacing
        }

        Item {
            height: HeeraUI.Units.largeSpacing
        }
    }
}
