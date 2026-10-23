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

// Guidance banner: a dark floating card with the next maneuver,
// shown on top of the map while navigating
Item {
    id: block
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    height: visible ? card.y + card.height + (thenCard.visible ? thenCard.height - styler.cardRadius : 0) : 0
    visible: !app.modalDialog && app.mode === modes.navigate
    z: 400

    property string icon:      app.navigator.icon
    property string manDist:   app.navigator.manDist
    // margins used by RootPage to place other items around the banner.
    // in landscape, the banner covers only the left side and the right
    // side of the screen stays free
    property real   marginExtraLeft: 0
    property real   marginExtraLeftSide: app.portrait ? 1 : card.x + card.width
    property real   marginExtraRight: app.portrait ? 0 : -height
    property real   marginExtraRightSide: 1
    property string narrative: app.navigator.narrative
    property string nextIcon:  app.navigator.nextIcon
    property string nextManDist:  app.navigator.nextManDist
    property bool   notify:    app.navigator.notify
    property int    roundaboutExit: app.navigator.roundaboutExit
    property string street:    app.navigator.street ? app.navigator.street : ""

    property bool   _pressed: mouse.pressed

    Rectangle {
        // the maneuver after the next one, tucked under the main card
        id: thenCard
        anchors.left: card.left
        anchors.top: card.bottom
        anchors.topMargin: -styler.cardRadius
        color: _pressed ? Qt.lighter(styler.bannerBg, 1.8) : Qt.lighter(styler.bannerBg, 1.4)
        height: styler.cardRadius + thenRow.height + 2*styler.themePaddingMedium
        layer.enabled: true
        layer.effect: ShadowPL { }
        radius: styler.cardRadius
        visible: block.notify && block.nextIcon ? true : false
        width: thenRow.width + 2*styler.themePaddingLarge

        Row {
            id: thenRow
            anchors.bottom: parent.bottom
            anchors.bottomMargin: styler.themePaddingMedium
            anchors.left: parent.left
            anchors.leftMargin: styler.themePaddingLarge
            spacing: styler.themePaddingMedium

            LabelPL {
                anchors.verticalCenter: parent.verticalCenter
                color: styler.bannerFg
                font.pixelSize: styler.themeFontSizeMedium
                text: app.tr("Then")
            }

            Image {
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.Pad
                height: sourceSize.height
                smooth: true
                source: thenCard.visible ? "icons/navigation/%1-white.svg".arg(block.nextIcon) : ""
                sourceSize.height: styler.themeIconSizeSmall * 0.6
                sourceSize.width: styler.themeIconSizeSmall * 0.6
                width: sourceSize.width
            }

            LabelPL {
                anchors.verticalCenter: parent.verticalCenter
                color: styler.bannerFg
                font.bold: true
                font.pixelSize: styler.themeFontSizeMedium
                text: block.nextManDist
            }
        }
    }

    Rectangle {
        id: card
        color: _pressed ? Qt.lighter(styler.bannerBg, 1.4) : styler.bannerBg
        height: Math.max(iconImage.height, textColumn.height) + 2*styler.themePaddingLarge
        layer.enabled: true
        layer.effect: ShadowPL { }
        radius: styler.cardRadius
        width: app.portrait ? parent.width - 2*x : Math.round(parent.width * 0.42)
        x: styler.themePaddingMedium
        y: styler.themePaddingMedium

        Image {
            // icon for the next maneuver
            id: iconImage
            anchors.left: parent.left
            anchors.leftMargin: styler.themePaddingLarge
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.Pad
            height: visible ? sourceSize.height : 0
            smooth: true
            source: visible ? "icons/navigation/%1-white.svg".arg(block.icon || "flag") : ""
            sourceSize.height: (app.screenLarge ? 1.7 : 1) * styler.themeIconSizeLarge * 1.2
            sourceSize.width: (app.screenLarge ? 1.7 : 1) * styler.themeIconSizeLarge * 1.2
            visible: block.notify
            width: visible ? sourceSize.width : 0

            LabelPL {
                // roundabout exit if available
                anchors.centerIn: parent
                color: styler.bannerFg
                font.bold: true
                font.pixelSize: parent.height / 3
                text: block.roundaboutExit
                visible: block.roundaboutExit > 0
            }
        }

        Column {
            id: textColumn
            anchors.left: iconImage.right
            anchors.leftMargin: styler.themePaddingLarge
            anchors.right: parent.right
            anchors.rightMargin: styler.themePaddingLarge
            anchors.verticalCenter: parent.verticalCenter

            LabelPL {
                // shown while away from the route
                color: styler.bannerFg
                font.pixelSize: styler.themeFontSizeMedium
                opacity: 0.7
                text: app.tr("To route")
                visible: !block.notify
            }

            LabelPL {
                // distance to the next maneuver or to the route
                color: styler.bannerFg
                font.bold: true
                font.pixelSize: Math.round(styler.themeFontSizeHuge * 0.8)
                text: block.manDist
                truncMode: truncModes.fade
                width: parent.width
            }

            LabelPL {
                // street of the next maneuver
                color: styler.bannerFg
                elide: Text.ElideRight
                font.bold: true
                font.pixelSize: styler.themeFontSizeExtraLarge
                maximumLineCount: 2
                text: block.notify ? block.street : ""
                visible: text
                width: parent.width
                wrapMode: Text.WordWrap
            }

            LabelPL {
                // instruction, used when the street is not known
                color: styler.bannerFg
                font.pixelSize: styler.themeFontSizeLarge
                text: block.notify && !block.street ? block.narrative : ""
                visible: text
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }
    }

    MouseArea {
        id: mouse
        height: thenCard.visible ? thenCard.y + thenCard.height - card.y : card.height
        width: card.width
        x: card.x
        y: card.y
        onClicked: app.showNavigationPages()
    }
}
