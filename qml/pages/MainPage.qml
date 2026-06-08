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

    ListModel {
        id: upstreamsModel
    }

    ListModel {
        id: denylistModel
    }

    Component.onCompleted: loadPage()
    onStatusChanged: if (status === PageStatus.Active)
        loadPage()

    function loadPage() {
        loadUpstreams();
        loadDenylist();
        config.text = manager.readConfig();
    }

    function loadUpstreams() {
        upstreamsModel.clear();
        var list = manager.upstreams();
        for (var i = 0; i < list.length; i++) {
            upstreamsModel.append({
                "value": list[i]
            });
        }
    }

    function loadDenylist() {
        denylistModel.clear();
        var list = manager.denylist();
        for (var i = 0; i < list.length; i++) {
            denylistModel.append({
                "value": list[i]
            });
        }
    }

    function collectList(model) {
        var arr = [];
        for (var i = 0; i < model.count; i++) {
            var val = model.get(i).value.trim();
            if (val.length > 0) {
                arr.push(val);
            }
        }
        return arr;
    }

    Connections {
        target: appWindow
        onRestartError: {
            errorMsg.text = qsTr("ERROR! blocky start failed with: %1").arg(message);
            errorMsg.visible = true;
            saveBtn.enabled = true;
            busy.visible = busy.running = false;
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
        }

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: "Blocky"
            }

            SectionHeader {
                text: qsTr("DNS")
            }

            Repeater {
                model: upstreamsModel

                Row {
                    width: parent.width

                    TextField {
                        width: parent.width - removeUpstreamBtn.width - Theme.paddingMedium
                        text: value
                        placeholderText: qsTr("DNS server address")
                        inputMethodHints: Qt.ImhNoAutoUppercase
                        onTextChanged: upstreamsModel.set(index, {
                            "value": text
                        })
                    }

                    IconButton {
                        id: removeUpstreamBtn
                        icon.source: "image://theme/icon-m-clear"
                        onClicked: upstreamsModel.remove(index)
                    }
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Add DNS")
                onClicked: upstreamsModel.append({
                    "value": ""
                })
            }

            SectionHeader {
                text: qsTr("Denylists")
            }

            Repeater {
                model: denylistModel

                Row {
                    width: parent.width

                    TextField {
                        width: parent.width - removeDenylistBtn.width - Theme.paddingMedium
                        text: value
                        placeholderText: qsTr("Denylist URL")
                        inputMethodHints: Qt.ImhNoAutoUppercase
                        onTextChanged: denylistModel.set(index, {
                            "value": text
                        })
                    }

                    IconButton {
                        id: removeDenylistBtn
                        icon.source: "image://theme/icon-m-clear"
                        onClicked: denylistModel.remove(index)
                    }
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Add denylist")
                onClicked: denylistModel.append({
                    "value": ""
                })
            }

            Separator {
                width: parent.width
                color: Theme.highlightBackgroundColor
                horizontalAlignment: Qt.AlignHCenter
            }

            BusyIndicator {
                id: busy
                visible: false
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                id: errorMsg
                visible: false
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.errorColor
            }

            Button {
                id: saveBtn
                text: qsTr("Save and restart")
                anchors.horizontalCenter: parent.horizontalCenter

                onClicked: {
                    errorMsg.visible = false;
                    saveBtn.enabled = false;
                    busy.visible = busy.running = true;

                    manager.saveFromEntries(collectList(upstreamsModel), collectList(denylistModel));

                    appWindow.restartBlocky();

                    config.text = manager.readConfig();

                    saveBtn.enabled = true;
                    busy.visible = busy.running = false;
                }
            }

            SectionHeader {
                text: qsTr("Raw configuration")
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
                text: qsTr("The generated raw configuration:")
                wrapMode: Text.Wrap
            }

            TextArea {
                id: config
                width: parent.width
                readOnly: true
                text: manager.readConfig()
            }
        }

        VerticalScrollDecorator {}
    }
}
