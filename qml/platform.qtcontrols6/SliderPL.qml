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

// Settings row: label and value on top, the slider below it and an
// optional description under the slider
Item {
    height: lab.height + val.height + 2*styler.themePaddingSmall +
            desc.height + desc.anchors.topMargin

    property alias description: desc.text
    property alias label: lab.text
    property alias maximumValue: val.to
    property alias minimumValue: val.from
    property alias stepSize: val.stepSize
    property alias value: val.value
    property real  valueText
    property int   valueTextDecimalPlaces: stepSize > 1 ? 0 : Math.round( Math.log(1.0 / stepSize) / Math.LN10 )

    Label {
        id: lab
        anchors.left: parent.left
        anchors.leftMargin: styler.themeHorizontalPageMargin
        anchors.right: valTxt.left
        anchors.rightMargin: styler.themePaddingMedium
        anchors.top: parent.top
        anchors.topMargin: styler.themePaddingSmall
        elide: Text.ElideRight
        font.pixelSize: styler.themeFontSizeMedium
    }

    Label {
        id: valTxt
        anchors.baseline: lab.baseline
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin
        color: styler.themeSecondaryHighlightColor
        font.pixelSize: styler.themeFontSizeMedium
        text: valueText.toFixed(valueTextDecimalPlaces)
    }

    Slider {
        id: val
        anchors.left: parent.left
        anchors.leftMargin: styler.themeHorizontalPageMargin
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin
        anchors.top: lab.bottom
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
