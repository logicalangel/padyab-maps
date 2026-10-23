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

// Floating sheet at the bottom of the screen when a route is shown but
// navigation is not running: origin and destination, the found routes
// with their time and distance, and a button to start navigation
Item {
    id: sheet
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    height: visible ? card.height + styler.themePaddingMedium : 0
    // also shown while the first route is searched for and when it fails
    visible: !app.modalDialog && (app.mode === modes.exploreRoute ||
                                  (app.mode === modes.explore && !app.infoPanelOpen &&
                                   (app.navigator.routing || app.navigator.routingError)))
    width: app.portrait ? parent.width : Math.round(parent.width * 0.42) + styler.themePaddingMedium
    z: 400

    // margins used by RootPage to place other items around the sheet.
    // in landscape, the sheet covers only the left side of the screen
    property real   marginExtraLeft: 0
    property real   marginExtraLeftSide: app.portrait ? 1 : width
    property real   marginExtraRight: app.portrait ? 0 : -height
    property real   marginExtraRightSide: 1
    property string origin: {
        var loc = app.navigator.locations;
        if (!loc || loc.length < 2) return "";
        return loc[0].text || "";
    }
    property string destination: {
        // before routing from the current position, only the destination is known
        var loc = app.navigator.locations;
        if (!loc || loc.length < 1) return "";
        return loc[loc.length - 1].text || "";
    }
    property real   padding: styler.themePaddingLarge
    property bool   pending: app.mode !== modes.exploreRoute
    property var    routes: {
        var alternatives = app.navigator.alternatives;
        if (alternatives.length > 1) {
            var fastest = Math.min.apply(null, alternatives.map(function (r) {
                return r.summary ? r.summary.duration : 0;
            }));
            return alternatives.map(function (r, i) {
                var s = r.summary || {};
                // compare rounded minutes, as shown to the user
                var extra = Math.round(s.duration / 60) - Math.round(fastest / 60);
                return {"index": i, "time": s.time, "dist": s.dist, "via": s.via,
                        "eta": sheet.eta(s.duration),
                        "extra": extra > 0 ? app.tr("%1 min slower").arg(extra) : ""};
            });
        }
        // single route, possibly partly driven already
        var started = app.navigator.progress > 0 && app.navigator.destTime;
        var summary = app.navigator.summary;
        return [{"index": 0,
                 "time": started ? app.navigator.destTime : app.navigator.totalTime,
                 "dist": started ? app.navigator.destDist : app.navigator.totalDist,
                 "via": summary.via || "",
                 "eta": started ? app.navigator.destEta : sheet.eta(summary.duration),
                 "extra": ""}];
    }

    CardShadow { target: card }

    Rectangle {
        id: card
        anchors.bottom: parent.bottom
        anchors.bottomMargin: styler.themePaddingMedium
        color: styler.sheetBg
        height: column.height + 2*sheet.padding
        radius: styler.cardRadius * 1.4
        width: parent.width - (app.portrait ? 2 : 1)*x
        x: styler.themePaddingMedium

        Column {
            id: column
            anchors.left: parent.left
            anchors.leftMargin: sheet.padding
            anchors.right: parent.right
            anchors.rightMargin: sheet.padding
            anchors.top: parent.top
            anchors.topMargin: sheet.padding
            spacing: sheet.padding

            Item {
                // header with close button
                height: Math.max(title.height, closeButton.height)
                width: parent.width

                LabelPL {
                    id: title
                    anchors.left: parent.left
                    anchors.right: closeButton.left
                    anchors.rightMargin: styler.themePaddingMedium
                    anchors.verticalCenter: parent.verticalCenter
                    color: styler.itemFg
                    font.bold: true
                    font.pixelSize: styler.cardTitleFontSize
                    text: app.tr("Directions")
                    truncMode: truncModes.fade
                }

                CardButton {
                    id: closeButton
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    cross: true
                    size: Math.round(styler.cardButtonSize * 0.8)
                    onClicked: {
                        notification.flash(app.tr("Route removed"), "navigationClear");
                        app.navigator.clearRoute();
                    }
                }
            }

            Rectangle {
                // origin and destination, tap to edit the route
                color: placesMouse.pressed ? styler.itemPressed : styler.itemBg
                height: places.height
                radius: styler.cardRadius
                visible: sheet.destination ? true : false
                width: parent.width

                Column {
                    id: places
                    width: parent.width

                    Repeater {
                        model: [
                            {"text": sheet.origin || app.tr("Current position"), "color": styler.route},
                            {"text": sheet.destination, "color": styler.endBg}
                        ]

                        Item {
                            height: placeLabel.height + 2*styler.themePaddingLarge
                            width: places.width

                            Rectangle {
                                id: dot
                                anchors.left: parent.left
                                anchors.leftMargin: styler.themePaddingLarge
                                anchors.verticalCenter: parent.verticalCenter
                                color: modelData.color
                                height: Math.round(styler.themeFontSizeMedium * 0.9)
                                radius: height / 2
                                width: height
                            }

                            LabelPL {
                                id: placeLabel
                                anchors.left: dot.right
                                anchors.leftMargin: styler.themePaddingLarge
                                anchors.right: parent.right
                                anchors.rightMargin: styler.themePaddingLarge
                                anchors.verticalCenter: parent.verticalCenter
                                color: styler.itemFg
                                font.pixelSize: styler.themeFontSizeLarge
                                text: modelData.text
                                truncMode: truncModes.fade
                            }

                            Rectangle {
                                // divider between the two places
                                anchors.bottom: parent.bottom
                                anchors.left: placeLabel.left
                                anchors.right: parent.right
                                color: styler.itemFg
                                height: 1
                                opacity: 0.1
                                visible: index === 0
                            }
                        }
                    }
                }

                MouseArea {
                    id: placesMouse
                    anchors.fill: parent
                    onClicked: app.pushMain(Qt.resolvedUrl("RoutePage.qml"))
                }
            }

            Rectangle {
                // progress or failure of the route search
                color: styler.itemBg
                height: statusColumn.height + 2*styler.themePaddingLarge
                radius: styler.cardRadius
                visible: sheet.pending
                width: parent.width

                Column {
                    id: statusColumn
                    anchors.left: parent.left
                    anchors.leftMargin: styler.themePaddingLarge
                    anchors.right: parent.right
                    anchors.rightMargin: styler.themePaddingLarge
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: styler.themePaddingLarge

                    Row {
                        spacing: styler.themePaddingLarge
                        width: parent.width

                        BusyIndicatorSmallPL {
                            anchors.verticalCenter: parent.verticalCenter
                            running: app.navigator.routing
                            visible: running
                        }

                        LabelPL {
                            anchors.verticalCenter: parent.verticalCenter
                            color: styler.itemFg
                            font.pixelSize: styler.themeFontSizeMedium
                            text: app.navigator.routing ? app.tr("Finding routes…") :
                                                          app.tr("No route found: %1").arg(app.navigator.routingError)
                            width: parent.width - (app.navigator.routing ? parent.spacing + styler.themeIconSizeSmall : 0)
                            wrapMode: Text.WordWrap
                        }
                    }

                    ActionTile {
                        label: app.tr("Try again")
                        primary: true
                        visible: !app.navigator.routing
                        width: parent.width
                        onClicked: app.navigator.findRoute(null, {"fitToView": true})
                    }
                }
            }

            Repeater {
                model: sheet.pending ? [] : sheet.routes

                Rectangle {
                    // one route: tap to select it, tap the selected one for details
                    border.color: styler.route
                    border.width: selected && sheet.routes.length > 1 ? Math.max(2, Math.round(styler.themePaddingSmall / 2)) : 0
                    color: rowMouse.pressed ? styler.itemPressed : styler.itemBg
                    height: Math.max(texts.height, goButton.height) + 2*styler.themePaddingLarge
                    radius: styler.cardRadius
                    width: column.width

                    property bool selected: modelData.index === app.navigator.alternativeSelected

                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        onClicked: {
                            if (parent.selected) app.showNavigationPages();
                            else app.navigator.selectAlternative(modelData.index);
                        }
                    }

                    Column {
                        id: texts
                        anchors.left: parent.left
                        anchors.leftMargin: styler.themePaddingLarge
                        anchors.right: goButton.left
                        anchors.rightMargin: styler.themePaddingLarge
                        anchors.verticalCenter: parent.verticalCenter

                        LabelPL {
                            color: styler.itemFg
                            font.bold: true
                            font.pixelSize: styler.cardValueFontSize
                            text: modelData.time || ""
                        }

                        LabelPL {
                            color: styler.itemFg
                            font.pixelSize: styler.themeFontSizeMedium
                            opacity: 0.6
                            text: {
                                var parts = [];
                                if (modelData.eta) parts.push(app.tr("%1 arrival").arg(modelData.eta));
                                if (modelData.dist) parts.push(modelData.dist);
                                return parts.join(" · ");
                            }
                            truncMode: truncModes.fade
                            width: parent.width
                        }

                        LabelPL {
                            color: styler.itemFg
                            font.pixelSize: styler.themeFontSizeMedium
                            opacity: 0.6
                            text: {
                                var parts = [];
                                if (modelData.via) parts.push(app.tr("via %1").arg(modelData.via));
                                if (modelData.extra) parts.push(modelData.extra);
                                return parts.join(" · ");
                            }
                            truncMode: truncModes.fade
                            visible: text
                            width: parent.width
                        }
                    }

                    Rectangle {
                        // starts navigation along this route
                        id: goButton
                        anchors.right: parent.right
                        anchors.rightMargin: styler.themePaddingLarge
                        anchors.verticalCenter: parent.verticalCenter
                        color: goMouse.pressed ? Qt.darker(styler.goBg, 1.2) : styler.goBg
                        height: styler.cardTileHeight
                        radius: styler.cardRadius * 0.75
                        width: Math.max(goLabel.width + 2*styler.themePaddingLarge, Math.round(height * 1.2))

                        LabelPL {
                            id: goLabel
                            anchors.centerIn: parent
                            color: "white"
                            font.bold: true
                            font.capitalization: Font.AllUppercase
                            font.pixelSize: Math.round(styler.themeFontSizeLarge * 1.2)
                            text: app.tr("Go")
                        }

                        MouseArea {
                            id: goMouse
                            anchors.fill: parent
                            onClicked: {
                                app.navigator.selectAlternative(modelData.index);
                                notification.flash(app.tr("Navigation started"), "navigationStartPause");
                                app.navigator.running = true;
                            }
                        }
                    }
                }
            }
        }
    }

    function eta(duration) {
        // arrival time when starting now
        if (!duration) return "";
        return Qt.formatTime(new Date(Date.now() + duration*1000),
                             Qt.locale().timeFormat(Locale.ShortFormat));
    }
}
