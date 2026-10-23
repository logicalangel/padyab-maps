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

// Title of a section on a page, placed above a card
LabelPL {
    anchors.left: parent.left
    anchors.leftMargin: styler.themeHorizontalPageMargin + styler.themePaddingLarge
    anchors.right: parent.right
    anchors.rightMargin: styler.themeHorizontalPageMargin + styler.themePaddingLarge
    color: styler.themeHighlightColor
    font.bold: true
    font.pixelSize: styler.themeFontSizeMedium
    height: implicitHeight + styler.themePaddingSmall
    opacity: 0.6
    truncMode: truncModes.fade
    verticalAlignment: Text.AlignBottom
}
