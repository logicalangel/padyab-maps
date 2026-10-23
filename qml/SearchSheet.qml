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
import pm 1.0
import pm.platform 1.0

import "js/util.js" as Util

// Floating sheet at the bottom of the map while exploring. Collapsed, it
// shows a search field with buttons for route planning and the main
// menu. Tapping the field expands the sheet over the map to search
// with suggestions, recent searches and results.
Item {
    id: sheet
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    // the item keeps the collapsed size, the expanded card grows over the map
    height: visible ? collapsedHeight + styler.themePaddingMedium : 0
    visible: !app.modalDialog && !app.infoPanelOpen && app.mode === modes.explore
    width: app.portrait ? parent.width : Math.round(parent.width * 0.42) + styler.themePaddingMedium
    z: expanded ? 950 : 400

    property real   collapsedHeight: field.height + 2*styler.themePaddingLarge
    property bool   expanded: false
    // margins used by RootPage to place other items around the sheet.
    // in landscape, the sheet covers only the left side of the screen
    property real   marginExtraLeft: 0
    property real   marginExtraLeftSide: app.portrait ? 1 : width
    property real   marginExtraRight: app.portrait ? 0 : -height
    property real   marginExtraRightSide: 1

    // reopen the results when the place card shown from them is closed
    property bool   _reopen: false

    Connections {
        target: app
        onInfoPanelOpenChanged: {
            if (app.infoPanelOpen) return;
            if (sheet._reopen && geo.query) sheet.expand();
            sheet._reopen = false;
        }
    }

    Connections {
        target: geo
        onQueryChanged: if (input.text.trim() !== geo.query) input.text = geo.query;
    }

    CardShadow { target: card }

    Rectangle {
        id: card
        anchors.bottom: parent.bottom
        anchors.bottomMargin: styler.themePaddingMedium
        // expanded, use the background of the platform list items
        color: sheet.expanded ? styler.blockBg : styler.itemBg
        height: sheet.expanded ? sheet.parent.height - 2*styler.themePaddingLarge - anchors.bottomMargin :
                                 sheet.collapsedHeight
        radius: styler.cardRadius * 1.4
        width: parent.width - (app.portrait ? 2 : 1)*x
        x: styler.themePaddingMedium

        Behavior on height {
            NumberAnimation { duration: 2*app.conf.animationDuration; easing.type: Easing.OutCubic }
        }

        MouseArea {
            // keeps touches on the card away from the map
            anchors.fill: parent
        }

        Rectangle {
            // search field
            id: field
            anchors.left: parent.left
            anchors.leftMargin: styler.themePaddingLarge
            anchors.right: sheet.expanded ? cancelButton.left : routeButton.left
            anchors.rightMargin: styler.themePaddingMedium
            anchors.top: parent.top
            anchors.topMargin: styler.themePaddingLarge
            color: {
                if (sheet.expanded) return Qt.darker(styler.blockBg, 1.08);
                return fieldMouse.pressed ? styler.itemPressed : styler.sheetBg;
            }
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

            TextInput {
                id: input
                anchors.left: searchIcon.right
                anchors.leftMargin: styler.themePaddingMedium
                anchors.right: clearButton.visible ? clearButton.left : parent.right
                anchors.rightMargin: styler.themePaddingMedium
                anchors.verticalCenter: parent.verticalCenter
                clip: true
                color: styler.itemFg
                enabled: sheet.expanded
                font.family: styler.themeFontFamily
                font.pixelSize: styler.themeFontSizeLarge
                inputMethodHints: Qt.ImhNoPredictiveText
                selectByMouse: true
                selectionColor: styler.route
                onAccepted: geo.fetchResults()
                onTextChanged: geo.setText(text)
            }

            LabelPL {
                // placeholder
                anchors.left: input.left
                anchors.right: input.right
                anchors.verticalCenter: parent.verticalCenter
                color: styler.itemFg
                font.pixelSize: styler.themeFontSizeLarge
                opacity: 0.5
                text: app.tr("Search Maps")
                truncMode: truncModes.fade
                visible: !input.text
            }

            CardButton {
                // clears the typed text
                id: clearButton
                anchors.right: parent.right
                anchors.rightMargin: styler.themePaddingMedium
                anchors.verticalCenter: parent.verticalCenter
                cross: true
                size: Math.round(parent.height * 0.55)
                visible: sheet.expanded && input.text
                onClicked: {
                    input.text = "";
                    input.forceActiveFocus();
                }
            }

            MouseArea {
                id: fieldMouse
                anchors.fill: parent
                enabled: !sheet.expanded
                onClicked: sheet.expand()
            }
        }

        CardButton {
            // route planning
            id: routeButton
            anchors.right: menuButton.left
            anchors.rightMargin: styler.themePaddingMedium
            anchors.top: field.top
            iconName: styler.iconNavigate
            visible: !sheet.expanded
            onClicked: app.pushMain(Qt.resolvedUrl("RoutePage.qml"))
        }

        CardButton {
            id: menuButton
            anchors.right: parent.right
            anchors.rightMargin: styler.themePaddingLarge
            anchors.top: field.top
            iconName: styler.iconMenu
            visible: !sheet.expanded
            onClicked: app.showMenu()
        }

        LabelPL {
            // closes the search
            id: cancelButton
            anchors.right: parent.right
            anchors.rightMargin: styler.themePaddingLarge
            anchors.verticalCenter: field.verticalCenter
            color: styler.route
            font.pixelSize: styler.themeFontSizeLarge
            text: app.tr("Cancel")
            visible: sheet.expanded

            MouseArea {
                anchors.fill: parent
                anchors.margins: -styler.themePaddingMedium
                onClicked: sheet.collapse(true)
            }
        }

        Flickable {
            // suggestions, recent searches and results
            anchors.bottom: parent.bottom
            anchors.bottomMargin: styler.themePaddingMedium
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: field.bottom
            anchors.topMargin: styler.themePaddingMedium
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            contentHeight: geo.height
            contentWidth: width
            visible: sheet.expanded

            GeocodeItem {
                id: geo
                active: true
                fillModel: sheet.expanded
                searchFieldVisible: false
                selectionPlaceholderText: ""
                onSearchResultsChanged: {
                    if (!app.pois) return;
                    app.stateId = geo.stateId;
                    app.pois.addList(geo.searchResults, stateId);
                }
                onSelectionChanged: sheet.select(selection)
            }
        }
    }

    function collapse(clear) {
        expanded = false;
        input.focus = false;
        Qt.inputMethod.hide();
        if (clear) input.text = "";
    }

    function expand() {
        expanded = true;
        geo.activate();
        input.forceActiveFocus();
    }

    function select(selection) {
        // Show the selected place on the map, as the search page does.
        if (!selection || !selection.coordinate) return;
        var poi = Util.shallowCopy(selection);
        if (selection.selectionType === geo.selectionTypes.searchResult) {
            py.call_sync("poor.app.history.add_place", [geo.query]);
            var available_poi = app.pois.has(poi);
            if (available_poi && !available_poi.bookmarked)
                // assuming that if there is a temporary
                // poi its the same as the selected one
                poi = available_poi;
            else {
                // either add if its missing or show as a duplicate
                var new_poi = app.pois.add(poi, geo.stateId);
                if (new_poi) poi = new_poi;
                else poi.title = app.tr("%1 [duplicate]", poi.title);
            }
        }
        app.stateId = geo.stateId;
        collapse(false);
        sheet._reopen = true;
        app.pois.show(poi, true);
        map.autoCenter = false;
        map.setCenter(poi.coordinate.longitude, poi.coordinate.latitude);
    }
}
