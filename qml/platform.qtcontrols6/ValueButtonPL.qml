/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018 Rinigus
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

import QtQuick
import QtQuick.Controls

// Settings row: label on the left, the value and an arrow on the right,
// an optional description below. Tap to change the value.
Item {
    id: row
    anchors.left: parent.left
    anchors.right: parent.right
    implicitHeight: val.height + desc.height + desc.anchors.topMargin

    property alias description: desc.text
    property alias label: lab.text
    property alias value: valueLabel.text

    signal clicked

    ItemDelegate {
        id: val
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Math.max(styler.themeItemSizeSmall, lab.implicitHeight + 2*styler.themePaddingMedium)
        onClicked: row.clicked()

        Label {
            id: lab
            anchors.left: parent.left
            anchors.leftMargin: styler.themeHorizontalPageMargin
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            font.pixelSize: styler.themeFontSizeMedium
            width: Math.min(implicitWidth, parent.width * 0.5)
        }

        Label {
            id: valueLabel
            anchors.left: lab.right
            anchors.leftMargin: styler.themePaddingMedium
            anchors.right: arrow.left
            anchors.rightMargin: styler.themePaddingMedium
            anchors.verticalCenter: parent.verticalCenter
            color: styler.themeSecondaryHighlightColor
            elide: Text.ElideRight
            font.pixelSize: styler.themeFontSizeMedium
            horizontalAlignment: Text.AlignRight
        }

        Label {
            id: arrow
            anchors.right: parent.right
            anchors.rightMargin: styler.themeHorizontalPageMargin
            anchors.verticalCenter: parent.verticalCenter
            color: styler.themeSecondaryHighlightColor
            font.pixelSize: styler.themeFontSizeLarge
            text: "\u203A"
        }
    }

    Label {
        id: desc
        anchors.left: parent.left
        anchors.leftMargin: styler.themeHorizontalPageMargin
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin
        anchors.top: val.bottom
        anchors.topMargin: text ? styler.themePaddingSmall : 0
        color: styler.themeSecondaryHighlightColor
        font.pixelSize: styler.themeFontSizeSmall
        height: text ? implicitHeight : 0
        visible: text
        wrapMode: Text.WordWrap
    }
}
