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

CoverBackground {

    property int remainingSeconds: 0
    property bool blockingDisabled: false

    function formatTime(seconds) {
        if (seconds >= 60) {
            var m = Math.floor(seconds / 60);
            var s = seconds % 60;
            if (s > 0) {
                return qsTr("%1m %2s").arg(m).arg(s);
            }
            return qsTr("%1m").arg(m);
        }
        return qsTr("%1s").arg(seconds);
    }

    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        onTriggered: {
            if (remainingSeconds > 0) {
                remainingSeconds--;
            }
            if (remainingSeconds <= 0) {
                stop();
                blockingDisabled = false;
            }
        }
    }

    CoverPlaceholder {
        id: placeholder
        text: blockingDisabled ? qsTr("Blocking disabled for:\n%1").arg(formatTime(remainingSeconds)) : "Blocky"
        icon.source: "/usr/share/icons/hicolor/86x86/apps/harbour-blocky.png"
    }

    CoverActionList {
        id: coverAction
        enabled: manager.apiEnabled

        CoverAction {
            iconSource: blockingDisabled ? "image://theme/icon-cover-cancel" : "image://theme/icon-cover-pause"
            onTriggered: {
                if (blockingDisabled) {
                    if (client.enableBlocking()) {
                        countdownTimer.stop();
                        remainingSeconds = 0;
                        blockingDisabled = false;
                    }
                } else {
                    var duration = manager.disableDuration();
                    if (client.disableBlocking(duration)) {
                        remainingSeconds = duration;
                        blockingDisabled = true;
                        countdownTimer.start();
                    }
                }
            }
        }
    }
}
