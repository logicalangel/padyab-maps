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

// Current speed shown in a round badge above the navigation tray
Rectangle {
    id: badge
    anchors.bottom: referenceBlockBottomLeft.top
    anchors.bottomMargin: styler.themePaddingLarge
    anchors.left: parent.left
    anchors.leftMargin: styler.themePaddingLarge
    color: styler.itemBg
    height: width
    layer.enabled: true
    layer.effect: ShadowPL { }
    radius: width / 2
    visible: !app.modalDialog && app.mode === modes.navigate && speed.text ? true : false
    width: Math.round(Math.max(column.width, column.height) + 2*styler.themePaddingMedium)
    z: 400

    Column {
        id: column
        anchors.centerIn: parent

        LabelPL {
            id: speed
            anchors.horizontalCenter: parent.horizontalCenter
            color: styler.itemFg
            font.bold: true
            font.pixelSize: styler.themeFontSizeLarge
            text: {
                if (!gps.speedValid)
                    return "";
                if (app.conf.units === "american" || app.conf.units === "british")
                    return "%1".arg(Math.round(gps.speed * 2.23694));
                return "%1".arg(Math.round(gps.speed * 3.6)); // km/h
            }
        }

        LabelPL {
            anchors.horizontalCenter: parent.horizontalCenter
            color: styler.itemFg
            font.pixelSize: styler.themeFontSizeExtraSmall
            opacity: 0.6
            text: app.conf.units === "american" || app.conf.units === "british" ?
                      app.tr("mph") : app.tr("km/h")
        }
    }
}
