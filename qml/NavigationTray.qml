/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2026 Parya Rastegar
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import pm.platform 1.0
import pm 1.0

// Tray at the bottom of the screen while navigating: arrival time,
// remaining time and remaining distance. Opens navigation pages on tap.
Item {
    id: tray
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    height: visible ? (app.portrait ? bg.height - styler.cardRadius : bg.height + styler.themePaddingMedium) : 0
    visible: !app.modalDialog && app.mode === modes.navigate
    width: app.portrait ? parent.width : Math.round(parent.width * 0.42) + styler.themePaddingMedium
    z: 400

    property string destDist: showNextLocation ? app.navigator.nextLocationDist : app.navigator.destDist
    property string destEta:  showNextLocation ? app.navigator.nextLocationEta : app.navigator.destEta
    property string destTime: showNextLocation ? app.navigator.nextLocationTime : app.navigator.destTime
    property int    labelSize: Math.round(styler.themeFontSizeSmall * textScale)
    // margins used by RootPage to place other items around the tray.
    // in landscape, the tray covers only the left side of the screen
    property real   marginExtraLeft: 0
    property real   marginExtraLeftSide: app.portrait ? 1 : width
    property real   marginExtraRight: app.portrait ? 0 : -height
    property real   marginExtraRightSide: 1
    property bool   showNextLocation: app.navigator.hasNextLocation
    property real   textScale: app.conf.navigationInfoScale
    property int    valueSize: Math.round(styler.themeFontSizeLarge * 1.3 * textScale)

    // remaining distance split into value and unit, "12.5 km" -> ["12.5", "km"]
    property var    _dist: {
        var i = destDist.lastIndexOf(" ");
        if (i > 0) return [destDist.substring(0, i), destDist.substring(i + 1)];
        return [destDist, ""];
    }
    // remaining time as "1:05" with "h" or "25" with "min"
    property var    _time: {
        var n = destTime.match(/\d+/g);
        if (n && n.length === 2)
            return [n[0] + ":" + (n[1].length < 2 ? "0" + n[1] : n[1]), app.tr("h")];
        if (n && n.length === 1) return [n[0], app.tr("min")];
        return [destTime, ""];
    }

    Rectangle {
        id: bg
        anchors.top: parent.top
        color: mouse.pressed ? styler.itemPressed : styler.itemBg
        height: grabber.anchors.topMargin + grabber.height + row.anchors.topMargin + row.height +
                styler.themePaddingLarge + (app.portrait ? styler.cardRadius : 0)
        layer.enabled: true
        layer.effect: ShadowPL { }
        radius: styler.cardRadius
        width: parent.width - x
        x: app.portrait ? 0 : styler.themePaddingMedium

        Rectangle {
            id: grabber
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: styler.themePaddingMedium
            color: styler.itemFg
            height: Math.max(3, Math.round(styler.themePaddingSmall))
            opacity: 0.2
            radius: height / 2
            width: 3 * styler.themePaddingLarge
        }

        Row {
            id: row
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: grabber.bottom
            anchors.topMargin: styler.themePaddingSmall

            property real cellWidth: width / 3

            Column {
                width: row.cellWidth
                LabelPL {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: styler.itemFg
                    font.bold: true
                    font.pixelSize: tray.valueSize
                    text: tray.destEta
                }
                LabelPL {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: styler.itemFg
                    font.pixelSize: tray.labelSize
                    opacity: 0.6
                    text: tray.showNextLocation && !app.navigator.nextLocationDestination ?
                              app.tr("waypoint") : app.tr("arrival")
                }
            }

            Column {
                width: row.cellWidth
                LabelPL {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: styler.itemFg
                    font.bold: true
                    font.pixelSize: tray.valueSize
                    text: tray._time[0]
                }
                LabelPL {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: styler.itemFg
                    font.pixelSize: tray.labelSize
                    opacity: 0.6
                    text: tray._time[1]
                }
            }

            Column {
                width: row.cellWidth
                LabelPL {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: styler.itemFg
                    font.bold: true
                    font.pixelSize: tray.valueSize
                    text: tray._dist[0]
                }
                LabelPL {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: styler.itemFg
                    font.pixelSize: tray.labelSize
                    opacity: 0.6
                    text: tray._dist[1]
                }
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            onClicked: app.showNavigationPages()
        }
    }
}
