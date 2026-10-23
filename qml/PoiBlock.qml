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

import QtQuick 2.0
import QtPositioning 5.4
import pm 1.0
import pm.platform 1.0

// POI information shown in a panel under the map
Column {
    id: item
    anchors.left: parent.left
    anchors.right: parent.right
    height: visible ? implicitHeight : 0
    visible: false

    // properties of the item
    property bool  active: false
    property bool  navigationControls: false

    // poi properties
    property string address
    property bool   bookmarked: false
    property var    coordinate
    property string email
    property string link
    property string phone
    property string poiId
    property string poiType
    property string postcode
    property bool   shortlisted: false
    property string text
    property string title
    property var    poi

    // internal properties
    property bool  _fullMode: true
    property bool  _multipleIntermediatePossible: {
        if (!navigator.hasDestination) return false;
        if (navigator.hasOrigin)
            return navigator.locations.length > 2;
        return navigator.locations.length > 1;
    }
    property alias _optionalHeight: optional.height

    property var    poiAsRoutingDestination: {
        "text": title,
        "x": coordinate ? coordinate.longitude : 0,
        "y": coordinate ? coordinate.latitude : 0,
        "destination": true
    }
    property var    poiAsRoutingOrigin: {
        "text": title,
        "x": coordinate ? coordinate.longitude : 0,
        "y": coordinate ? coordinate.latitude : 0,
        "origin": true
    }

    Item {
        // title with a close button
        anchors.left: parent.left
        anchors.right: parent.right
        height: Math.max(titleLabel.height, closeButton.height) + styler.themePaddingMedium

        LabelPL {
            id: titleLabel
            anchors.left: parent.left
            anchors.leftMargin: styler.themeHorizontalPageMargin
            anchors.right: closeButton.left
            anchors.rightMargin: styler.themePaddingMedium
            anchors.top: parent.top
            color: styler.itemFg
            font.bold: true
            font.pixelSize: Math.round(styler.themeFontSizeExtraLarge * 1.1)
            text: item.title
            wrapMode: Text.WordWrap
        }

        CardButton {
            id: closeButton
            anchors.right: parent.right
            anchors.rightMargin: styler.themeHorizontalPageMargin
            anchors.top: parent.top
            cross: true
            size: Math.round(styler.themeIconSizeSmall * 1.2)
            onClicked: app.infoPanel.hidePoi()
        }
    }

    Column {
        id: optional
        anchors.left: parent.left
        anchors.right: parent.right
        visible: _fullMode

        ListItemLabel {
            color: styler.itemFg
            height: text ? implicitHeight + styler.themePaddingSmall: 0
            font.pixelSize: styler.themeFontSizeMedium
            opacity: 0.7
            text: {
                if (item.poiType && item.address)
                    return app.tr("%1; %2", item.poiType, item.address);
                else if (item.poiType)
                    return item.poiType;
                else if (item.address)
                    return item.address;
                return "";
            }
            truncMode: truncModes.none
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }

        ListItemLabel {
            color: styler.itemFg
            font.pixelSize: styler.themeFontSizeSmall
            height: text ? implicitHeight + styler.themePaddingSmall: 0
            opacity: 0.5
            text: app.portrait && item.coordinate? app.tr("Latitude: %1; Longitude: %2", item.coordinate.latitude, item.coordinate.longitude) : ""
            truncMode: truncModes.fade
            verticalAlignment: Text.AlignTop
        }

        ListItemLabel {
            id: textItem
            color: styler.itemFg
            font.pixelSize: styler.themeFontSizeSmall
            height: text ? implicitHeight + styler.themePaddingSmall: 0
            maximumLineCount: app.portrait ? 3 : 1;
            text: item.text
            truncMode: truncModes.elide
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }

        ListItemLabel {
            color: styler.themeSecondaryHighlightColor
            font.pixelSize: styler.themeFontSizeSmall
            height: text ? implicitHeight + styler.themePaddingSmall: 0
            horizontalAlignment: Text.AlignRight
            text: {
                var info = "";
                if (item.postcode) info += app.tr("Postal code") + "  ";
                if (item.link) info += app.tr("Web") + "  ";
                if (item.phone) info += app.tr("Phone") + "  ";
                if (item.email) info += app.tr("Email") + "  ";
                if (item.shortlisted) info += app.tr("Shortlisted") + "  ";
                if (item.text && textItem.truncated) info += app.tr("Text") + "  ";
                if (info)
                    return app.tr("More info: %1", info);
                return "";
            }
            truncMode: truncModes.fade
            verticalAlignment: Text.AlignTop
        }
    }

    Spacer {
        id: splitterItem
        height: styler.themePaddingLarge - styler.themePaddingSmall
    }

    Row {
        // actions: directions as the main one, then save, nearby, details and remove
        id: buttonRow
        anchors.left: parent.left
        anchors.leftMargin: styler.themeHorizontalPageMargin
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin
        spacing: styler.themePaddingMedium
        visible: !navigationControls

        property real tileWidth: Math.round((width - 5*spacing) / 6)

        ActionTile {
            label: app.tr("Directions")
            primary: true
            width: 2*buttonRow.tileWidth + buttonRow.spacing
            onClicked: {
                if (coordinate === undefined) return;
                // with a route already planned, ask how to use this place
                if (navigator.hasDestination || navigator.hasOrigin) {
                    navigationControls = true;
                    return;
                }
                var loc = navigator.locations;
                loc.push(poiAsRoutingDestination);
                navigator.locations = loc;
                finalizeRouting();
            }
        }

        ActionTile {
            enabled: item.active
            iconSource: app.getIcon(bookmarked ? "icons/ui/bookmark-filled" : "icons/ui/bookmark")
            label: bookmarked ? app.tr("Saved") : app.tr("Save")
            width: buttonRow.tileWidth
            onClicked: {
                bookmarked = !bookmarked;
                pois.bookmark(poiId, bookmarked);
            }
        }

        ActionTile {
            iconSource: app.getIcon("icons/ui/pin")
            label: app.tr("Nearby")
            width: buttonRow.tileWidth
            onClicked: {
                if (coordinate === undefined) return;
                app.showMenu(Qt.resolvedUrl("NearbyPage.qml"), {
                                 "near": [coordinate.longitude, coordinate.latitude],
                                 "nearText": title,
                             });
            }
        }

        ActionTile {
            iconSource: app.getIcon("icons/ui/info")
            label: app.tr("Details")
            width: buttonRow.tileWidth
            onClicked: {
                app.push(Qt.resolvedUrl("PoiInfoPage.qml"), {
                             "active": active,
                             "poi": item.poi,
                         });
            }
        }

        ActionTile {
            enabled: item.active
            iconSource: app.getIcon("icons/ui/trash")
            label: app.tr("Remove")
            width: buttonRow.tileWidth
            onClicked: {
                if (coordinate === undefined) return;
                pois.remove(poiId, true);
                hide();
            }
        }
    }

    // Navigation controls
    SectionLabel {
        text: navigator.hasDestination || navigator.hasOrigin ? app.tr("Set as or Replace") : app.tr("Set as")
        visible: navigationControls
    }

    Grid {
        id: gridRepl
        columns: landscape ? 2 : 1
        anchors.left: parent.left
        anchors.right: parent.right
        visible: navigationControls

        property int  availableHalfWidth: width/2
        property bool landscape: gdest.visible && gorig.visible &&
                                 gdest.minWidth < availableHalfWidth &&
                                 gorig.minWidth < availableHalfWidth
        property int  cellTextSpace: width/2 - styler.themeHorizontalPageMargin -
                                     styler.themePaddingLarge

        ListItemLabelActive {
            id: gorig
            contentHeight: styler.themeItemSizeSmall
            label: app.tr("Origin")
            labelX: gridRepl.landscape ? styler.themePaddingLarge +
                                         gridRepl.cellTextSpace/2 - labelImplicitWidth/2 :
                                         styler.themeHorizontalPageMargin
            width: Math.max(minWidth, gridRepl.width / 2)
            property int minWidth: labelImplicitWidth + styler.themeHorizontalPageMargin +
                                   styler.themePaddingLarge

            onClicked: {
                var loc = navigator.locations;
                if (navigator.hasOrigin) loc[0] = poiAsRoutingOrigin;
                else loc.splice(0, 0, poiAsRoutingOrigin);
                navigator.locations = loc;
                finalizeRouting();
            }
        }

        ListItemLabelActive {
            id: gdest
            contentHeight: styler.themeItemSizeSmall
            label: app.tr("Final destination")
            labelX: gridRepl.landscape ? styler.themeHorizontalPageMargin +
                                         gridRepl.cellTextSpace/2 - labelImplicitWidth/2 :
                                         styler.themeHorizontalPageMargin
            width: Math.max(minWidth, gridRepl.width / 2)
            property int minWidth: labelImplicitWidth + styler.themeHorizontalPageMargin +
                                   styler.themePaddingLarge

            onClicked: {
                var loc = navigator.locations;
                if (navigator.hasDestination) loc[loc.length-1] = poiAsRoutingDestination;
                else loc.push(poiAsRoutingDestination);
                navigator.locations = loc;
                finalizeRouting();
            }
        }
    }

    SectionLabel {
        text: app.tr("Insert as")
        visible: navigationControls && (navigator.hasOrigin || navigator.hasDestination)
    }

    ListItemLabelActive {
        label: app.tr("New origin")
        labelX: styler.themeHorizontalPageMargin
        visible: navigationControls && navigator.hasOrigin
        onClicked: {
            var loc = navigator.locations;
            loc[0].destination = true;
            loc.splice(0, 0, poiAsRoutingOrigin);
            navigator.locations = loc;
            finalizeRouting();
        }
    }

    ListItemLabelActive {
        label: app.tr("New final destination")
        labelX: styler.themeHorizontalPageMargin
        visible: navigationControls && navigator.hasDestination
        onClicked: {
            var loc = navigator.locations;
            loc.push(poiAsRoutingDestination);
            navigator.locations = loc;
            finalizeRouting();
        }
    }

    ListItemLabelActive {
        label: app.tr("First intermediate destination")
        labelX: styler.themeHorizontalPageMargin
        visible: navigationControls && _multipleIntermediatePossible
        onClicked: {
            var loc = navigator.locations;
            var i = navigator.hasOrigin ? 1 : 0;
            loc.splice(i, 0, poiAsRoutingDestination);
            navigator.locations = loc;
            finalizeRouting();
        }
    }

    ListItemLabelActive {
        label: _multipleIntermediatePossible ? app.tr("Last intermediate destination") :
                                               app.tr("Intermediate destination")
        labelX: styler.themeHorizontalPageMargin
        visible: navigationControls && navigator.hasDestination
        onClicked: {
            var loc = navigator.locations;
            loc.splice(loc.length-1, 0, poiAsRoutingDestination);
            navigator.locations = loc;
            finalizeRouting();
        }
    }


    Connections {
        target: pois
        onPoiChanged: {
            if (!poiId || item.poiId !== poiId) return;
            item.show(pois.getById(poiId));
        }
    }

    Connections {
        target: map
        onHeightChanged: checkMode()
    }

    onHeightChanged: checkMode()
    on_OptionalHeightChanged: checkMode()

    function checkMode() {
        // check if we have space to show all information
        var h = item.height + 2*styler.themePaddingLarge;
        if (_fullMode && h > map.height)
            _fullMode = false;
        else if (!_fullMode && h + _optionalHeight < map.height)
            _fullMode = true;
    }

    function finalizeRouting() {
        if (navigator.hasDestination)
            navigator.findRoute( false, {"save": true, "fitToView": true} );
        pois.hide();
    }

    function hide() {
        item.visible = false;
        item.active = false;
        item.poiId = "";
        navigationControls = false;
        app.poiActive = false;
        map.setSelectedPoi()
    }

    function show(poi) {
        if (!poi) {
            hide();
            return;
        }
        app.poiActive = true;
        // fill poi data
        item.address = poi.address || "";
        item.bookmarked = poi.bookmarked || false;
        item.coordinate = poi.coordinate || QtPositioning.coordinate(poi.y, poi.x);
        item.email = poi.email || "";
        item.link = poi.link || "";
        item.phone = poi.phone || "";
        item.poiId = poi.poiId || "";
        item.poiType = poi.poiType || "";
        item.postcode = poi.postcode || "";
        item.shortlisted = poi.shortlisted || false;
        item.text = poi.text || "";
        item.title = poi.title || app.tr("Unnamed point");
        item.poi = poi;
        // fill item vars
        item.active = (item.poiId.length > 0);
        item.visible = true;
        map.setSelectedPoi(item.coordinate)
    }
}
