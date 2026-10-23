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

// Action button of the place card: icon above a short label on a
// rounded tile. The primary tile is colored and shows only the label.
Rectangle {
    id: tile
    color: {
        if (primary) return mouse.pressed ? Qt.darker(styler.route, 1.2) : styler.route;
        return mouse.pressed ? styler.itemPressed : styler.sheetBg;
    }
    height: Math.round(styler.themeIconSizeSmall * 2)
    opacity: enabled ? 1 : 0.5
    radius: styler.cardRadius * 0.75

    property alias iconName: icon.iconName
    property alias label: label.text
    property bool  primary: false

    signal clicked

    Column {
        anchors.centerIn: parent
        spacing: styler.themePaddingSmall

        IconPL {
            id: icon
            anchors.horizontalCenter: parent.horizontalCenter
            iconHeight: Math.round(tile.height * 0.36)
            visible: !tile.primary
        }

        LabelPL {
            id: label
            anchors.horizontalCenter: parent.horizontalCenter
            color: tile.primary ? "white" : styler.itemFg
            font.bold: tile.primary
            font.pixelSize: tile.primary ? styler.themeFontSizeLarge : styler.themeFontSizeExtraSmall
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: tile.enabled
        onClicked: tile.clicked()
    }
}
