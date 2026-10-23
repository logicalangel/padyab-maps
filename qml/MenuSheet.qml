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
import QtPositioning 5.4
import pm.platform 1.0

// Main menu as a sheet over the map, opened from the search sheet
MouseArea {
    id: master
    anchors.fill: parent
    enabled: openMenu
    visible: openMenu
    z: 9999

    property bool openMenu: false

    Rectangle {
        // dims the map behind the sheet
        anchors.fill: parent
        color: "black"
        opacity: 0.15
    }

    CardShadow { target: sheet }

    Rectangle {
        id: sheet
        anchors.bottom: parent.bottom
        anchors.bottomMargin: styler.themePaddingMedium
        color: styler.sheetBg
        height: Math.min(content.height + 2*padding, parent.height - 4*styler.themePaddingLarge)
        radius: styler.cardRadius * 1.4
        width: app.portrait ? parent.width - 2*x : Math.round(parent.width * 0.42)
        x: styler.themePaddingMedium

        property real padding: styler.themePaddingLarge

        MouseArea {
            // keeps taps on the sheet from closing it
            anchors.fill: parent
        }

        Flickable {
            anchors.fill: parent
            anchors.margins: sheet.padding
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            contentHeight: content.height
            contentWidth: width

            Column {
                id: content
                spacing: sheet.padding
                width: parent.width

                Item {
                    // header with close button
                    height: Math.max(title.height, closeButton.height)
                    width: parent.width

                    LabelPL {
                        id: title
                        anchors.left: parent.left
                        anchors.right: closeButton.left
                        anchors.verticalCenter: parent.verticalCenter
                        color: styler.itemFg
                        font.bold: true
                        font.pixelSize: styler.cardTitleFontSize
                        text: "Pure Maps"
                    }

                    CardButton {
                        id: closeButton
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        cross: true
                        size: Math.round(styler.cardButtonSize * 0.8)
                        onClicked: master.openMenu = false
                    }
                }

                Rectangle {
                    color: styler.itemBg
                    height: followRow.height
                    radius: styler.cardRadius
                    visible: app.mode === modes.followMe
                    width: parent.width

                    MenuRow {
                        id: followRow
                        iconSource: app.getIcon("icons/ui/follow")
                        label: app.tr("Stop following the movement")
                        last: true
                        onClicked: {
                            master.openMenu = false;
                            app.navigator.followMe = false;
                        }
                    }
                }

                Rectangle {
                    color: styler.itemBg
                    height: placesGroup.height
                    radius: styler.cardRadius
                    width: parent.width

                    Column {
                        id: placesGroup
                        width: parent.width

                        MenuRow {
                            iconSource: app.getIcon("icons/ui/bookmark")
                            label: app.tr("Bookmarks")
                            onClicked: master.push("PoiPage.qml")
                        }

                        MenuRow {
                            iconSource: app.getIcon("icons/ui/pin")
                            label: app.tr("Nearby venues")
                            onClicked: master.push("NearbyPage.qml")
                        }

                        MenuRow {
                            enabled: gps.coordinateValid
                            iconSource: app.getIcon("icons/ui/share")
                            label: gps.coordinateValid ? app.tr("Share current position") :
                                                         app.tr("Share current position (not ready)")
                            last: true
                            onClicked: {
                                if (!gps.coordinateValid) return;
                                var y = gps.coordinate.latitude;
                                var x = gps.coordinate.longitude;
                                master.push("SharePage.qml", {
                                                "coordinate": QtPositioning.coordinate(y, x),
                                                "title": app.tr("Share Current Position"),
                                                "poi": { "address": app.tr("Current position") }
                                            });
                            }
                        }
                    }
                }

                Rectangle {
                    color: styler.itemBg
                    height: mapsGroup.height
                    radius: styler.cardRadius
                    width: parent.width

                    Column {
                        id: mapsGroup
                        width: parent.width

                        MenuRow {
                            iconSource: app.getIcon("icons/route")
                            label: app.tr("Directions")
                            onClicked: master.push("RoutePage.qml")
                        }

                        MenuRow {
                            iconSource: app.getIcon("icons/map-layers")
                            label: app.tr("Maps")
                            last: true
                            onClicked: master.push("BasemapPage.qml")
                        }
                    }
                }

                LabelPL {
                    color: styler.itemFg
                    font.bold: true
                    font.pixelSize: styler.themeFontSizeMedium
                    opacity: 0.6
                    text: app.tr("Profile")
                }

                Row {
                    // profile as a segmented control
                    id: profiles
                    spacing: styler.themePaddingSmall
                    width: parent.width

                    property bool hereAvailable: py.evaluate("poor.key.has_here")
                    property var  items: {
                        var l = [{"name": "online", "text": app.tr("Online")},
                                 {"name": "offline", "text": app.tr("Offline")},
                                 {"name": "mixed", "text": app.tr("Mixed")}];
                        if (hereAvailable) l.push({"name": "HERE", "text": "HERE"});
                        return l;
                    }

                    Repeater {
                        model: profiles.items

                        Rectangle {
                            color: {
                                if (selected) return styler.route;
                                return profileMouse.pressed ? styler.itemPressed : styler.itemBg;
                            }
                            height: profileLabel.height + 2*styler.themePaddingMedium
                            radius: height / 2
                            width: (profiles.width - (profiles.items.length - 1)*profiles.spacing) / profiles.items.length

                            property bool selected: app.conf.profile === modelData.name

                            LabelPL {
                                id: profileLabel
                                anchors.centerIn: parent
                                color: parent.selected ? "white" : styler.itemFg
                                font.bold: parent.selected
                                font.pixelSize: styler.themeFontSizeMedium
                                text: modelData.text
                            }

                            MouseArea {
                                id: profileMouse
                                anchors.fill: parent
                                onClicked: py.call_sync("poor.app.set_profile", [modelData.name])
                            }
                        }
                    }
                }

                Rectangle {
                    color: styler.itemBg
                    height: appGroup.height
                    radius: styler.cardRadius
                    width: parent.width

                    Column {
                        id: appGroup
                        width: parent.width

                        MenuRow {
                            iconSource: app.getIcon("icons/ui/settings")
                            label: app.tr("Preferences")
                            onClicked: {
                                master.openMenu = false;
                                app.pushMain(Qt.resolvedUrl("PreferencesPage.qml"), {}, true);
                            }
                        }

                        MenuRow {
                            iconSource: app.getIcon("icons/ui/info")
                            label: app.tr("About Pure Maps")
                            last: true
                            onClicked: master.push("AboutPage.qml")
                        }
                    }
                }
            }
        }
    }

    onClicked: openMenu = false

    function open() {
        openMenu = true;
    }

    function push(page, options) {
        openMenu = false;
        app.pushMain(Qt.resolvedUrl(page), options);
    }
}
