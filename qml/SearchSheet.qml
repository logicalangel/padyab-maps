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

// Floating sheet at the bottom of the map while exploring: search field,
// route planning and the main menu
Item {
    id: sheet
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    height: visible ? card.height + styler.themePaddingMedium : 0
    visible: !app.modalDialog && !app.infoPanelOpen && app.mode === modes.explore
    width: app.portrait ? parent.width : Math.round(parent.width * 0.42) + styler.themePaddingMedium
    z: 400

    // margins used by RootPage to place other items around the sheet.
    // in landscape, the sheet covers only the left side of the screen
    property real   marginExtraLeft: 0
    property real   marginExtraLeftSide: app.portrait ? 1 : width
    property real   marginExtraRight: app.portrait ? 0 : -height
    property real   marginExtraRightSide: 1

    CardShadow { target: card }

    Rectangle {
        id: card
        anchors.bottom: parent.bottom
        anchors.bottomMargin: styler.themePaddingMedium
        color: styler.itemBg
        height: field.height + 2*styler.themePaddingLarge
        radius: styler.cardRadius * 1.4
        width: parent.width - (app.portrait ? 2 : 1)*x
        x: styler.themePaddingMedium

        Rectangle {
            // looks like a search field, opens the search page
            id: field
            anchors.left: parent.left
            anchors.leftMargin: styler.themePaddingLarge
            anchors.right: routeButton.left
            anchors.rightMargin: styler.themePaddingMedium
            anchors.verticalCenter: parent.verticalCenter
            color: fieldMouse.pressed ? styler.itemPressed : styler.sheetBg
            height: routeButton.size
            radius: styler.cardRadius * 0.8

            Image {
                id: searchIcon
                anchors.left: parent.left
                anchors.leftMargin: styler.themePaddingLarge
                anchors.verticalCenter: parent.verticalCenter
                height: sourceSize.height
                opacity: 0.6
                smooth: true
                source: app.getIcon("icons/search")
                sourceSize.height: Math.round(parent.height * 0.45)
                sourceSize.width: Math.round(parent.height * 0.45)
                width: sourceSize.width
            }

            LabelPL {
                anchors.left: searchIcon.right
                anchors.leftMargin: styler.themePaddingMedium
                anchors.right: parent.right
                anchors.rightMargin: styler.themePaddingLarge
                anchors.verticalCenter: parent.verticalCenter
                color: styler.itemFg
                font.pixelSize: styler.themeFontSizeLarge
                opacity: 0.5
                text: app.tr("Search Maps")
                truncMode: truncModes.fade
            }

            MouseArea {
                id: fieldMouse
                anchors.fill: parent
                onClicked: app.pushMain(Qt.resolvedUrl("GeocodePage.qml"))
            }
        }

        CardButton {
            // route planning
            id: routeButton
            anchors.right: menuButton.left
            anchors.rightMargin: styler.themePaddingMedium
            anchors.verticalCenter: parent.verticalCenter
            iconName: styler.iconNavigate
            onClicked: app.pushMain(Qt.resolvedUrl("RoutePage.qml"))
        }

        CardButton {
            id: menuButton
            anchors.right: parent.right
            anchors.rightMargin: styler.themePaddingLarge
            anchors.verticalCenter: parent.verticalCenter
            iconName: styler.iconMenu
            onClicked: app.showMenu()
        }
    }
}
