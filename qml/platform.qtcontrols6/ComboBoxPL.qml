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

// Settings row: label on the left, the choice on the right and an
// optional description below
Item {
    id: item
    anchors.left: parent.left
    anchors.leftMargin: styler.themeHorizontalPageMargin
    anchors.right: parent.right
    anchors.rightMargin: styler.themeHorizontalPageMargin
    height: val.height + 2*styler.themePaddingSmall + desc.height + desc.anchors.topMargin

    property int   currentIndex
    property alias description: desc.text
    property alias model: val.model
    property alias label: lab.text
    property alias value: val.currentText

    Label {
        id: lab
        anchors.left: parent.left
        anchors.right: val.left
        anchors.rightMargin: styler.themePaddingMedium
        anchors.verticalCenter: val.verticalCenter
        elide: Text.ElideRight
        font.pixelSize: styler.themeFontSizeMedium
    }

    ComboBox {
        id: val
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: styler.themePaddingSmall
        font.pixelSize: styler.themeFontSizeMedium
        width: Math.min(Math.max(implicitWidth, item.width * 0.4), item.width * 0.6)

        property bool initialized: false

        onCurrentIndexChanged: {
            if (initialized && currentIndex != item.currentIndex)
                item.currentIndex = currentIndex;
        }

        Component.onCompleted: {
            currentIndex = item.currentIndex;
            initialized = true;
        }
    }

    Label {
        id: desc
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: val.bottom
        anchors.topMargin: text ? styler.themePaddingSmall : 0
        color: styler.themeSecondaryHighlightColor
        font.pixelSize: styler.themeFontSizeSmall
        height: text ? implicitHeight : 0
        visible: text
        wrapMode: Text.WordWrap
    }

    function activate() {
        // pass
    }
}
