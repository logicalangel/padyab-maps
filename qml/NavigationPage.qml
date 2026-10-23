/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2017 Osmo Salomaa, 2018 Rinigus
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

PagePL {
    id: page
    title: app.tr("Navigation")

    Column {
        id: column
        spacing: styler.themePaddingLarge
        width: parent.width

        property real cardWidth: width - 2*styler.themeHorizontalPageMargin

        Rectangle {
            // summary: remaining time and distance, arrival and progress
            anchors.horizontalCenter: parent.horizontalCenter
            color: styler.itemBg
            height: summary.height + 2*styler.themePaddingLarge
            radius: styler.cardRadius
            width: column.cardWidth

            Column {
                id: summary
                anchors.left: parent.left
                anchors.leftMargin: styler.themePaddingLarge
                anchors.right: parent.right
                anchors.rightMargin: styler.themePaddingLarge
                anchors.verticalCenter: parent.verticalCenter
                spacing: styler.themePaddingMedium

                LabelPL {
                    color: styler.itemFg
                    font.bold: true
                    font.pixelSize: Math.round(styler.themeFontSizeExtraLarge * 1.2)
                    text: {
                        if (app.mode === modes.navigatePost) return app.tr("Destination reached");
                        return app.navigator.destTime || app.navigator.totalTime || "";
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
                        var dist = app.navigator.destDist || app.navigator.totalDist;
                        if (dist && dist !== "-") parts.push(dist);
                        if (app.navigator.destEta && app.navigator.destEta !== "-")
                            parts.push(app.tr("%1 arrival").arg(app.navigator.destEta));
                        return parts.join(" · ");
                    }
                    truncMode: truncModes.fade
                    visible: app.mode !== modes.navigatePost && text
                    width: parent.width
                }

                Rectangle {
                    // progress along the route
                    color: Qt.rgba(_fg.r, _fg.g, _fg.b, 0.1)
                    height: Math.max(4, Math.round(styler.themePaddingSmall * 1.5))
                    radius: height / 2
                    width: parent.width

                    property color _fg: styler.itemFg

                    Rectangle {
                        color: styler.route
                        height: parent.height
                        radius: height / 2
                        width: Math.max(height, app.navigator.progress * parent.width)
                    }
                }

                LabelPL {
                    color: styler.itemFg
                    font.pixelSize: styler.themeFontSizeSmall
                    opacity: 0.6
                    text: {
                        if (!app.navigator.totalDist) return "";
                        if (app.navigator.hasTraffic && app.navigator.totalTimeInTraffic)
                            return app.tr("Total %1 · %2 (%3 with traffic)").arg(app.navigator.totalDist).
                                     arg(app.navigator.totalTime).arg(app.navigator.totalTimeInTraffic);
                        return app.tr("Total %1 · %2").arg(app.navigator.totalDist).arg(app.navigator.totalTime);
                    }
                    truncMode: truncModes.fade
                    visible: text
                    width: parent.width
                }
            }
        }

        Row {
            // actions as large tiles: start or pause, reroute and clear
            id: row
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: styler.themePaddingMedium
            width: column.cardWidth

            property bool running: app.mode === modes.navigate || app.mode === modes.navigatePost
            property real tileWidth: (width - 3*spacing) / 4

            ActionTile {
                label: row.running ? app.tr("Pause") : app.tr("Navigate")
                primary: true
                width: 2*row.tileWidth + row.spacing
                onClicked: {
                    app.hideNavigationPages();
                    app.navigator.running = !app.navigator.running;
                }
            }

            ActionTile {
                baseColor: styler.itemBg
                iconSource: app.getIcon("icons/ui/refresh")
                label: app.tr("Reroute")
                width: row.tileWidth
                onClicked: {
                    app.navigator.reroute();
                    app.hideNavigationPages();
                }
            }

            ActionTile {
                baseColor: styler.itemBg
                iconSource: app.getIcon("icons/ui/trash")
                label: app.tr("Clear")
                width: row.tileWidth
                onClicked: {
                    app.navigator.clearRoute();
                    app.showMap();
                }
            }
        }

        SectionLabel {
            text: app.tr("Destinations and waypoints")
            visible: locations.visible
        }

        Rectangle {
            id: locations
            anchors.horizontalCenter: parent.horizontalCenter
            color: styler.itemBg
            height: locColumn.height
            radius: styler.cardRadius
            visible: app.mode !== modes.navigatePost
            width: column.cardWidth

            Column {
                id: locColumn
                width: parent.width

                Repeater {
                    id: locRep
                    delegate: Rectangle {
                        // one location: tap to see it on the map
                        id: locItem
                        color: locMouse.pressed ? styler.itemPressed : "transparent"
                        height: Math.max(locTexts.height, removeButton.height) + 2*styler.themePaddingLarge
                        radius: styler.cardRadius
                        width: locColumn.width

                        property bool removable: !model.final && !model.origin && model.activeIndex > 0

                        MouseArea {
                            id: locMouse
                            anchors.fill: parent
                            onClicked: {
                                map.center = QtPositioning.coordinate(model.y, model.x);
                                map.zoomLevel < 15 && map.setZoomLevel(15);
                                app.hideNavigationPages();
                            }
                        }

                        Rectangle {
                            // origin blue, final destination red, others gray
                            id: dot
                            anchors.left: parent.left
                            anchors.leftMargin: styler.themePaddingLarge
                            anchors.verticalCenter: parent.verticalCenter
                            color: {
                                if (model.origin) return styler.route;
                                if (model.final) return styler.endBg;
                                return Qt.rgba(_fg.r, _fg.g, _fg.b, 0.4);
                            }
                            height: Math.round(styler.themeFontSizeMedium * 0.9)
                            opacity: model.arrived ? 0.4 : 1
                            radius: height / 2
                            width: height

                            property color _fg: styler.itemFg
                        }

                        Column {
                            id: locTexts
                            anchors.left: dot.right
                            anchors.leftMargin: styler.themePaddingLarge
                            anchors.right: removeButton.visible ? removeButton.left : parent.right
                            anchors.rightMargin: styler.themePaddingLarge
                            anchors.verticalCenter: parent.verticalCenter

                            LabelPL {
                                color: styler.itemFg
                                font.pixelSize: styler.themeFontSizeMedium
                                text: {
                                    if (model.text) return model.text;
                                    if (model.origin) return app.tr("Origin");
                                    if (model.final) return app.tr("Final destination");
                                    return model.destination ? app.tr("Destination") : app.tr("Waypoint");
                                }
                                truncMode: truncModes.fade
                                width: parent.width
                            }

                            LabelPL {
                                color: styler.itemFg
                                font.pixelSize: styler.themeFontSizeSmall
                                opacity: 0.6
                                text: {
                                    if (model.arrived) return app.tr("Arrived %1").arg(model.arrivedAt || "");
                                    var parts = [];
                                    if (model.dist) parts.push(model.time ? "%1 · %2".arg(model.dist).arg(model.time) : model.dist);
                                    if (model.eta) parts.push(app.tr("%1 arrival").arg(model.eta));
                                    if (model.legDist) parts.push(app.tr("leg %1").arg(model.legTime ? "%1 · %2".arg(model.legDist).arg(model.legTime) : model.legDist));
                                    return parts.join(" · ");
                                }
                                truncMode: truncModes.fade
                                visible: text
                                width: parent.width
                            }
                        }

                        CardButton {
                            // removes a destination or a waypoint and reroutes
                            id: removeButton
                            anchors.right: parent.right
                            anchors.rightMargin: styler.themePaddingLarge
                            anchors.verticalCenter: parent.verticalCenter
                            cross: true
                            size: Math.round(styler.themeIconSizeSmall)
                            visible: locItem.removable
                            onClicked: locRep.removeLocationAndReroute(model.activeIndex)
                        }

                        Rectangle {
                            // divider to the next location
                            anchors.bottom: parent.bottom
                            anchors.left: locTexts.left
                            anchors.right: parent.right
                            color: styler.itemFg
                            height: 1
                            opacity: 0.1
                            visible: model.index < locRep.count - 1
                        }
                    }
                    model: app.navigator.locationsModel

                    function removeLocationAndReroute(index) {
                        // has to be outside the location delegate as it will be destroyed
                        // on removal of location
                        if (!app.navigator.locationRemove(index)) return;
                        app.navigator.reroute();
                        app.hideNavigationPages();
                    }
                }
            }
        }

        SectionLabel {
            text: app.tr("Maneuvers")
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            color: styler.itemBg
            height: narrative.height
            radius: styler.cardRadius
            width: column.cardWidth

            NarrativeItem {
                id: narrative
            }
        }

        Spacer {
            height: styler.themePaddingLarge
        }
    }

    onPageStatusActivating: {
        if (!app.narrativePageSeen) {
            app.narrativePageSeen = true;
        }
    }
}
