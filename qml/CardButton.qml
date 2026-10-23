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

// Round button used on floating cards
Rectangle {
    id: button
    color: mouse.pressed ? Qt.rgba(_fg.r, _fg.g, _fg.b, 0.18) : Qt.rgba(_fg.r, _fg.g, _fg.b, 0.08)
    height: size
    radius: size / 2
    width: size

    property alias iconName: icon.iconName
    property real  size: Math.round(styler.themeIconSizeSmall * 1.3)

    property color _fg: styler.itemFg

    signal clicked

    IconPL {
        id: icon
        anchors.centerIn: parent
        iconHeight: Math.round(button.size * 0.5)
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: button.clicked()
    }
}
