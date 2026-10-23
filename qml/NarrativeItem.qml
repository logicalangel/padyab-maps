/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018 Rinigus
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
import pm 1.0
import pm.platform 1.0

import "js/util.js" as Util

// List of maneuvers as rows of a card: icon, instruction and the
// distance to the next maneuver. Tap a row to see the place on the map.
Column {
    width: parent.width

    Repeater {
        id: list
        width: parent.width

        delegate: Rectangle {
            id: listItem
            color: mouse.pressed ? styler.itemPressed : "transparent"
            height: texts.height + 2*styler.themePaddingLarge
            radius: styler.cardRadius
            width: parent.width

            property bool active: list.activeItem === model.index

            MouseArea {
                id: mouse
                anchors.fill: parent
                onClicked: {
                    list.activeItem = model.index;
                    map.center = model.coordinate;
                    map.zoomLevel < 15 && map.setZoomLevel(15);
                    app.hideNavigationPages();
                }
            }

            Rectangle {
                // maneuver icon in a tinted circle
                id: badge
                anchors.left: parent.left
                anchors.leftMargin: styler.themePaddingLarge
                anchors.top: texts.top
                color: listItem.active ? styler.route : Qt.rgba(_fg.r, _fg.g, _fg.b, 0.08)
                height: Math.round(styler.themeIconSizeSmall * 1.2)
                radius: height / 2
                width: height

                property color _fg: styler.itemFg

                Image {
                    anchors.centerIn: parent
                    height: sourceSize.height
                    smooth: true
                    source: "icons/navigation/%1-%2.svg".arg(model.icon).
                                arg(listItem.active || styler.iconVariant === "white" ? "white" : "black")
                    sourceSize.height: Math.round(parent.height * 0.65)
                    sourceSize.width: Math.round(parent.height * 0.65)
                    width: sourceSize.width
                }
            }

            Column {
                id: texts
                anchors.left: badge.right
                anchors.leftMargin: styler.themePaddingLarge
                anchors.right: parent.right
                anchors.rightMargin: styler.themePaddingLarge
                anchors.verticalCenter: parent.verticalCenter
                spacing: styler.themePaddingSmall

                LabelPL {
                    color: styler.itemFg
                    font.bold: listItem.active
                    font.pixelSize: styler.themeFontSizeMedium
                    text: model.narrative
                    width: parent.width
                    wrapMode: Text.WordWrap
                }

                LabelPL {
                    color: styler.itemFg
                    font.pixelSize: styler.themeFontSizeSmall
                    opacity: 0.6
                    text: model.depart ? model.depart : ""
                    visible: text
                    width: parent.width
                    wrapMode: Text.WordWrap
                }

                LabelPL {
                    color: styler.itemFg
                    font.pixelSize: styler.themeFontSizeSmall
                    opacity: 0.6
                    text: model.arrive ? model.arrive : ""
                    visible: text
                    width: parent.width
                    wrapMode: Text.WordWrap
                }

                LabelPL {
                    color: styler.itemFg
                    font.pixelSize: styler.themeFontSizeSmall
                    opacity: 0.6
                    text: {
                        if (model.index >= list.model.count - 1)
                            return "";
                        if (model.duration)
                            return app.tr("Continue for %1 (%2).", model.length, model.duration);
                        return app.tr("Continue for %1.", model.length);
                    }
                    truncMode: truncModes.fade
                    visible: text
                    width: parent.width
                }
            }

            Rectangle {
                // divider to the next maneuver
                anchors.bottom: parent.bottom
                anchors.left: texts.left
                anchors.right: parent.right
                color: styler.itemFg
                height: 1
                opacity: 0.1
                visible: model.index < list.model.count - 1
            }
        }
        model: app.navigator.maneuvers
        property int activeItem: -1
    }
}
