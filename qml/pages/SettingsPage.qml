/*
    Copyright (C) 2023 Andrea Scarpino <andrea@scarpino.dev>
    All rights reserved.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("REST API")
            }

            TextSwitch {
                id: apiSwitch
                text: qsTr("Enable")
                onCheckedChanged: manager.setApiEnabled(checked)
                Component.onCompleted: checked = manager.apiEnabled
            }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("Enables the REST API on port 4000. Required to disable blocking from the Cover. Also, the service must be restarted for this change to take effect.")
                wrapMode: Text.Wrap
            }

            SectionHeader {
                text: qsTr("Blocking settings")
            }

            TextField {
                id: durationField
                width: parent.width
                text: manager.disableDuration()
                label: qsTr("Default duration (seconds)")
                placeholderText: "300"
                inputMethodHints: Qt.ImhDigitsOnly
                onTextChanged: {
                    var val = parseInt(text)
                    if (!isNaN(val) && val > 0) {
                        manager.setDisableDuration(val)
                    }
                }
            }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("Default duration for temporarily disabling blocking from the Cover.")
                wrapMode: Text.Wrap
            }

            SectionHeader {
                text: qsTr("Rescue")
            }

            Button {
                id: resetBtn
                text: qsTr("Restore default configuration")
                anchors.horizontalCenter: parent.horizontalCenter

                onClicked: {
                    Remorse.popupAction(resetBtn, qsTr(
                                            "Restoring default configuration"),
                                        function () {
                                            manager.resetConfig()
                                            appWindow.restartBlocky()
                                        })
                }
            }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("Restores the Blocky configuration to the default shipped with the app and restarts the service.")
                wrapMode: Text.Wrap
            }
        }

        VerticalScrollDecorator {}
    }
}
