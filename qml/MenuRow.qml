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

// Row of a grouped list on a sheet: icon, label and an arrow
Rectangle {
    id: row
    color: mouse.pressed ? styler.itemPressed : "transparent"
    height: Math.max(icon.height, label.height) + 2*styler.themePaddingLarge
    opacity: enabled ? 1 : 0.5
    width: parent.width

    property alias iconSource: icon.iconSource
    property alias label: label.text
    property bool  last: false

    signal clicked

    IconPL {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: styler.themePaddingLarge
        anchors.verticalCenter: parent.verticalCenter
        iconColorize: false
        iconHeight: Math.round(styler.themeIconSizeSmall * 0.8)
    }

    LabelPL {
        id: label
        anchors.left: icon.right
        anchors.leftMargin: styler.themePaddingLarge
        anchors.right: arrow.left
        anchors.rightMargin: styler.themePaddingMedium
        anchors.verticalCenter: parent.verticalCenter
        color: styler.itemFg
        font.pixelSize: styler.themeFontSizeMedium
        truncMode: truncModes.fade
    }

    LabelPL {
        id: arrow
        anchors.right: parent.right
        anchors.rightMargin: styler.themePaddingLarge
        anchors.verticalCenter: parent.verticalCenter
        color: styler.itemFg
        font.pixelSize: styler.themeFontSizeLarge
        opacity: 0.4
        text: "›"
    }

    Rectangle {
        // divider to the next row
        anchors.bottom: parent.bottom
        anchors.left: label.left
        anchors.right: parent.right
        color: styler.itemFg
        height: 1
        opacity: 0.1
        visible: !row.last
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: row.enabled
        onClicked: row.clicked()
    }
}
