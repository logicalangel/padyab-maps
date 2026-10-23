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

// Settings row: label on the left, switch on the right and an
// optional description below
Item {
    id: item
    height: row.height + desc.height + desc.anchors.topMargin
    width: parent.width

    property alias checked: sw.checked
    property alias description: desc.text
    property alias text: lab.text
    property real leftMargin // ignoring this property

    Item {
        id: row
        anchors.left: parent.left
        anchors.right: parent.right
        height: Math.max(lab.height, sw.height) + 2*styler.themePaddingSmall

        Label {
            id: lab
            anchors.left: parent.left
            anchors.leftMargin: styler.themeHorizontalPageMargin
            anchors.right: sw.left
            anchors.rightMargin: styler.themePaddingMedium
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: styler.themeFontSizeMedium
            wrapMode: Text.WordWrap

            MouseArea {
                anchors.fill: parent
                enabled: item.enabled
                onClicked: sw.toggle()
            }
        }

        Switch {
            id: sw
            anchors.right: parent.right
            anchors.rightMargin: styler.themeHorizontalPageMargin
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Label {
        id: desc
        anchors.left: parent.left
        anchors.leftMargin: styler.themeHorizontalPageMargin
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin
        anchors.top: row.bottom
        anchors.topMargin: text ? styler.themePaddingSmall : 0
        color: styler.themeSecondaryHighlightColor
        font.pixelSize: styler.themeFontSizeSmall
        height: text ? implicitHeight : 0
        visible: text
        wrapMode: Text.WordWrap
    }
}
