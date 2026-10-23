/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2019 Rinigus
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

// Location selector shown as a card row: colored dot, label and the
// selected place. Grouped rows are drawn without their own card, to be
// placed in a card together with other rows.
Item {
    id: point
    height: card.height
    width: parent.width

    property string comment
    property var    coordinates: null
    property color  dotColor: styler.route
    property bool   grouped: false
    property string label
    property string query
    property string text
    property string title

    signal updated;

    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        color: mouse.pressed ? styler.itemPressed : (grouped ? "transparent" : styler.itemBg)
        height: Math.max(texts.height + 2*styler.themePaddingLarge, styler.themeItemSizeSmall)
        radius: styler.cardRadius
        width: grouped ? parent.width : parent.width - 2*styler.themeHorizontalPageMargin

        Rectangle {
            id: dot
            anchors.left: parent.left
            anchors.leftMargin: styler.themePaddingLarge
            anchors.verticalCenter: parent.verticalCenter
            color: dotColor
            height: Math.round(styler.themeFontSizeMedium * 0.9)
            radius: height / 2
            width: height
        }

        Column {
            id: texts
            anchors.left: dot.right
            anchors.leftMargin: styler.themePaddingLarge
            anchors.right: busy.running ? busy.left : parent.right
            anchors.rightMargin: styler.themePaddingLarge
            anchors.verticalCenter: parent.verticalCenter

            LabelPL {
                color: styler.itemFg
                font.pixelSize: styler.themeFontSizeSmall
                opacity: 0.6
                text: point.label
                width: parent.width
            }

            LabelPL {
                color: styler.itemFg
                font.pixelSize: styler.themeFontSizeLarge
                opacity: point.text ? 1 : 0.4
                text: point.text ? point.text : app.tr("Choose")
                truncMode: truncModes.fade
                width: parent.width
            }
        }

        BusyIndicatorSmallPL {
            id: busy
            anchors.right: parent.right
            anchors.rightMargin: styler.themePaddingLarge
            anchors.verticalCenter: parent.verticalCenter
            running: point.text === app.tr("Current position") && !gps.coordinateValid
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            onClicked: activate()
        }
    }

    function activate() {
        var dialog = app.push(Qt.resolvedUrl("RoutePointPage.qml"), {
                                  "comment": comment,
                                  "currentSelection": text,
                                  "query": query,
                                  "title": title,
                                  "searchPlaceholderText": label
                              });
        dialog.accepted.connect(function() {
            query = dialog.query;
            if (dialog.selection.selectionType === dialog.selectionTypes.currentPosition) {
                coordinates = app.getPosition();
                text = app.tr("Current position");
            }
            else if (dialog.selection.coordinate) {
                coordinates = [dialog.selection.coordinate.longitude, dialog.selection.coordinate.latitude];
                text = dialog.selection.title || app.tr("Unnamed point");
            } else {
                console.log("RoutePoint: " + label + " selection error: " + JSON.stringify(dialog.selection))
            }
            updated();
        });
    }
}
