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

// Soft shadow drawn behind a floating card or button: a few rounded
// rectangles with low opacity, growing outwards. Place it before the
// target so that the target covers its center.
Item {
    id: shadow
    anchors.fill: target
    anchors.topMargin: offset
    anchors.bottomMargin: -offset
    visible: target ? target.visible : false

    property real offset: Math.max(1, Math.round(styler.themePaddingSmall / 2))
    property real spread: styler.themePaddingLarge
    property real strength: 0.12
    property Item target

    Repeater {
        model: 5
        Rectangle {
            anchors.fill: parent
            anchors.margins: -(index + 1) * shadow.spread / 5
            color: styler.shadowColor
            opacity: shadow.strength / 5
            radius: (shadow.target ? shadow.target.radius : 0) + (index + 1) * shadow.spread / 5
        }
    }
}
