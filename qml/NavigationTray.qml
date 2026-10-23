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

// Floating card at the bottom of the screen while navigating: remaining
// time, distance and arrival time, with buttons to end navigation and
// to open the navigation pages
Item {
    id: tray
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    height: visible ? card.height + styler.themePaddingMedium : 0
    visible: !app.modalDialog && app.mode === modes.navigate
    width: app.portrait ? parent.width : Math.round(parent.width * 0.42) + styler.themePaddingMedium
    z: 400

    property string destDist: showNextLocation ? app.navigator.nextLocationDist : app.navigator.destDist
    property string destEta:  showNextLocation ? app.navigator.nextLocationEta : app.navigator.destEta
    property string destTime: showNextLocation ? app.navigator.nextLocationTime : app.navigator.destTime
    // margins used by RootPage to place other items around the tray.
    // in landscape, the tray covers only the left side of the screen
    property real   marginExtraLeft: 0
    property real   marginExtraLeftSide: app.portrait ? 1 : width
    property real   marginExtraRight: app.portrait ? 0 : -height
    property real   marginExtraRightSide: 1
    property bool   showNextLocation: app.navigator.hasNextLocation
    property real   textScale: app.conf.navigationInfoScale

    CardShadow { target: card }

    Rectangle {
        id: card
        anchors.bottom: parent.bottom
        anchors.bottomMargin: styler.themePaddingMedium
        color: styler.itemBg
        height: Math.max(endButton.height, info.height) + 2*styler.themePaddingLarge
        radius: styler.cardRadius
        width: parent.width - (app.portrait ? 2 : 1)*x
        x: styler.themePaddingMedium

        MouseArea {
            anchors.fill: parent
            onClicked: app.showNavigationPages()
        }

        Rectangle {
            // ends navigation and clears the route
            id: endButton
            anchors.left: parent.left
            anchors.leftMargin: styler.themePaddingLarge
            anchors.verticalCenter: parent.verticalCenter
            color: endMouse.pressed ? Qt.darker(styler.endBg, 1.2) : styler.endBg
            height: listButton.size
            radius: height / 2
            width: height

            Rectangle {
                anchors.centerIn: parent
                color: "white"
                height: Math.max(2, Math.round(parent.height * 0.07))
                radius: height / 2
                rotation: 45
                width: parent.width * 0.42
            }

            Rectangle {
                anchors.centerIn: parent
                color: "white"
                height: Math.max(2, Math.round(parent.height * 0.07))
                radius: height / 2
                rotation: -45
                width: parent.width * 0.42
            }

            MouseArea {
                id: endMouse
                anchors.fill: parent
                onClicked: app.remorse.execute(app.tr("Ending navigation"), function() {
                    app.navigator.clearRoute();
                })
            }
        }

        Column {
            id: info
            anchors.left: endButton.right
            anchors.leftMargin: styler.themePaddingLarge
            anchors.right: listButton.left
            anchors.rightMargin: styler.themePaddingLarge
            anchors.verticalCenter: parent.verticalCenter

            LabelPL {
                // remaining time
                color: styler.itemFg
                font.bold: true
                font.pixelSize: Math.round(styler.themeFontSizeExtraLarge * tray.textScale)
                horizontalAlignment: Text.AlignHCenter
                text: tray.destTime
                truncMode: truncModes.fade
                width: parent.width
            }

            LabelPL {
                // remaining distance and arrival time
                color: styler.itemFg
                font.pixelSize: Math.round(styler.themeFontSizeMedium * tray.textScale)
                horizontalAlignment: Text.AlignHCenter
                opacity: 0.6
                text: {
                    var parts = [];
                    if (tray.showNextLocation && !app.navigator.nextLocationDestination)
                        parts.push(app.tr("to waypoint"));
                    // "-" marks values not known yet
                    if (tray.destDist && tray.destDist !== "-") parts.push(tray.destDist);
                    if (tray.destEta && tray.destEta !== "-") parts.push(app.tr("%1 arrival").arg(tray.destEta));
                    return parts.join(" · ");
                }
                truncMode: truncModes.fade
                width: parent.width
            }
        }

        CardButton {
            // opens the list of maneuvers and other navigation pages
            id: listButton
            anchors.right: parent.right
            anchors.rightMargin: styler.themePaddingLarge
            anchors.verticalCenter: parent.verticalCenter
            iconName: styler.iconManeuvers
            onClicked: app.showNavigationPages()
        }
    }
}
