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

// Map controls grouped in a pill at the top right: map layers and
// location tracking, with a compass shown below while the map is rotated
Item {
    id: controls
    anchors.right: parent.right
    anchors.rightMargin: styler.themePaddingLarge
    height: pill.height + (compassButton.visible ? compassButton.height + styler.themePaddingLarge : 0)
    opacity: hidden ? 0 : 1
    visible: opacity > 0
    width: buttonSize
    y: navigationSign.y + navigationSign.height + styler.themePaddingLarge
    z: 500

    property real buttonSize: Math.round(styler.themeIconSizeSmall * 1.6)
    // always shown while exploring, hidden in the clean mode while moving
    property bool hidden: app.modalDialog || app.infoPanelOpen ||
                          (map.cleanMode && app.mode !== modes.explore &&
                           app.mode !== modes.exploreRoute &&
                           !app.conf.mapModeCleanShowBasemap && !app.conf.mapModeCleanShowCenter)

    Behavior on opacity { NumberAnimation { duration: app.conf.animationDuration } }

    Connections {
        target: map
        onAutoCenterChanged: if (!map.autoCenter) map.autoRotate = false;
    }

    CardShadow { target: pill }

    Rectangle {
        id: pill
        color: styler.itemBg
        height: 2*controls.buttonSize + 1
        radius: controls.buttonSize / 2
        width: controls.buttonSize

        Rectangle {
            // pressed feedback for the button under the finger
            color: styler.itemPressed
            height: controls.buttonSize
            radius: controls.buttonSize / 2
            visible: layersMouse.pressed || locateMouse.pressed
            width: controls.buttonSize
            y: locateMouse.pressed ? controls.buttonSize + 1 : 0
        }

        Image {
            anchors.centerIn: layersMouse
            height: sourceSize.height
            smooth: true
            source: app.getIcon("icons/map-layers")
            sourceSize.height: Math.round(controls.buttonSize * 0.5)
            sourceSize.width: Math.round(controls.buttonSize * 0.5)
            width: sourceSize.width
        }

        MouseArea {
            id: layersMouse
            height: controls.buttonSize
            width: controls.buttonSize
            onClicked: basemapButton.open()
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            color: styler.itemFg
            height: 1
            opacity: 0.15
            width: controls.buttonSize * 0.6
            y: controls.buttonSize
        }

        Image {
            anchors.centerIn: locateMouse
            height: sourceSize.height
            opacity: gps.coordinateValid ? 1 : 0.4
            smooth: true
            source: {
                if (map.autoCenter && map.autoRotate) return app.getIcon("icons/locate-heading");
                if (map.autoCenter) return app.getIcon("icons/locate-follow");
                return app.getIcon("icons/locate");
            }
            sourceSize.height: Math.round(controls.buttonSize * 0.5)
            sourceSize.width: Math.round(controls.buttonSize * 0.5)
            width: sourceSize.width
        }

        MouseArea {
            // cycles between free map, following the position and
            // following with the map rotated to the travel direction
            id: locateMouse
            enabled: gps.coordinateValid
            height: controls.buttonSize
            width: controls.buttonSize
            y: controls.buttonSize + 1
            onClicked: {
                if (!map.autoCenter) {
                    map.centerOnPosition();
                    map.autoCenter = true;
                } else if (!map.autoRotate) {
                    map.autoRotate = true;
                } else {
                    map.autoRotate = false;
                }
            }
        }
    }

    CardShadow { target: compassButton }

    Rectangle {
        // shown while the map is rotated, tap to turn north up
        id: compassButton
        anchors.top: pill.bottom
        anchors.topMargin: styler.themePaddingLarge
        color: compassMouse.pressed ? styler.itemPressed : styler.itemBg
        height: controls.buttonSize
        radius: controls.buttonSize / 2
        visible: map.autoRotate || Math.abs(_bearing) > 1
        width: controls.buttonSize

        property real _bearing: ((map.bearing % 360) + 540) % 360 - 180

        Image {
            anchors.centerIn: parent
            height: sourceSize.height
            rotation: -map.bearing
            smooth: true
            source: app.getIcon("icons/north")
            sourceSize.height: Math.round(controls.buttonSize * 0.6)
            sourceSize.width: Math.round(controls.buttonSize * 0.6)
            width: sourceSize.width
        }

        MouseArea {
            id: compassMouse
            anchors.fill: parent
            onClicked: {
                map.autoRotate = false;
                map.bearing = 0;
            }
        }
    }
}
