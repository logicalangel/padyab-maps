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

// Floating card at the bottom of the screen when a route is shown but
// navigation is not running: the found routes with their time and
// distance, a button to start navigation and buttons to edit or clear
Item {
    id: sheet
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    height: visible ? card.height + styler.themePaddingMedium : 0
    visible: !app.modalDialog && app.mode === modes.exploreRoute
    width: app.portrait ? parent.width : Math.round(parent.width * 0.42) + styler.themePaddingMedium
    z: 400

    // margins used by RootPage to place other items around the sheet.
    // in landscape, the sheet covers only the left side of the screen
    property real   marginExtraLeft: 0
    property real   marginExtraLeftSide: app.portrait ? 1 : width
    property real   marginExtraRight: app.portrait ? 0 : -height
    property real   marginExtraRightSide: 1
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
                        "extra": extra > 0 ? app.tr("+%1 min").arg(extra) : ""};
            });
        }
        // single route, possibly partly driven already
        var started = app.navigator.progress > 0 && app.navigator.destTime;
        return [{"index": 0,
                 "time": started ? app.navigator.destTime : app.navigator.totalTime,
                 "dist": started ? app.navigator.destDist : app.navigator.totalDist,
                 "via": app.navigator.summary.via || "",
                 "extra": ""}];
    }
    property string destination: {
        var loc = app.navigator.locations;
        if (!loc || loc.length < 2) return "";
        return loc[loc.length - 1].text || "";
    }

    Rectangle {
        id: card
        anchors.bottom: parent.bottom
        anchors.bottomMargin: styler.themePaddingMedium
        color: styler.itemBg
        height: column.height + styler.themePaddingLarge + styler.themePaddingMedium
        layer.enabled: true
        layer.effect: ShadowPL { }
        radius: styler.cardRadius
        width: parent.width - (app.portrait ? 2 : 1)*x
        x: styler.themePaddingMedium

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: styler.themePaddingLarge

            Item {
                // header: destination with edit and close buttons
                height: Math.max(title.height, closeButton.height)
                width: parent.width

                LabelPL {
                    id: title
                    anchors.left: parent.left
                    anchors.leftMargin: styler.themePaddingLarge
                    anchors.right: editButton.left
                    anchors.rightMargin: styler.themePaddingMedium
                    anchors.verticalCenter: parent.verticalCenter
                    color: styler.itemFg
                    font.bold: true
                    font.pixelSize: styler.themeFontSizeLarge
                    text: sheet.destination ? app.tr("To %1").arg(sheet.destination) : app.tr("Route")
                    truncMode: truncModes.fade
                }

                CardButton {
                    id: editButton
                    anchors.right: closeButton.left
                    anchors.rightMargin: styler.themePaddingMedium
                    anchors.verticalCenter: parent.verticalCenter
                    iconName: styler.iconEdit
                    size: closeButton.size
                    onClicked: app.pushMain(Qt.resolvedUrl("RoutePage.qml"))
                }

                CardButton {
                    id: closeButton
                    anchors.right: parent.right
                    anchors.rightMargin: styler.themePaddingLarge
                    anchors.verticalCenter: parent.verticalCenter
                    iconName: styler.iconClose
                    size: Math.round(styler.themeIconSizeSmall)
                    onClicked: {
                        notification.flash(app.tr("Route removed"), "navigationClear");
                        app.navigator.clearRoute();
                    }
                }
            }

            Item {
                height: styler.themePaddingMedium
                width: parent.width
            }

            Repeater {
                model: sheet.routes

                Item {
                    // one route: tap to select it, tap the selected one for details
                    height: row.height + 2*styler.themePaddingMedium
                    width: column.width

                    property bool selected: modelData.index === app.navigator.alternativeSelected

                    Rectangle {
                        anchors.fill: parent
                        anchors.leftMargin: styler.themePaddingMedium
                        anchors.rightMargin: styler.themePaddingMedium
                        color: Qt.rgba(_route.r, _route.g, _route.b, rowMouse.pressed ? 0.2 : 0.1)
                        radius: styler.cardRadius - styler.themePaddingMedium
                        visible: parent.selected && sheet.routes.length > 1 || rowMouse.pressed

                        property color _route: styler.route
                    }

                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        onClicked: {
                            if (parent.selected) app.showNavigationPages();
                            else app.navigator.selectAlternative(modelData.index);
                        }
                    }

                    Item {
                        id: row
                        anchors.left: parent.left
                        anchors.leftMargin: styler.themePaddingLarge
                        anchors.right: parent.right
                        anchors.rightMargin: styler.themePaddingLarge
                        anchors.verticalCenter: parent.verticalCenter
                        height: Math.max(texts.height, goButton.height)

                        Column {
                            id: texts
                            anchors.left: parent.left
                            anchors.right: goButton.left
                            anchors.rightMargin: styler.themePaddingLarge
                            anchors.verticalCenter: parent.verticalCenter

                            Row {
                                spacing: styler.themePaddingMedium

                                LabelPL {
                                    id: timeLabel
                                    color: styler.itemFg
                                    font.bold: true
                                    font.pixelSize: styler.themeFontSizeExtraLarge
                                    text: modelData.time || ""
                                }

                                LabelPL {
                                    anchors.baseline: timeLabel.baseline
                                    color: styler.itemFg
                                    font.pixelSize: styler.themeFontSizeMedium
                                    opacity: 0.6
                                    text: modelData.extra
                                    visible: text
                                }
                            }

                            LabelPL {
                                color: styler.itemFg
                                font.pixelSize: styler.themeFontSizeMedium
                                opacity: 0.6
                                text: {
                                    var parts = [];
                                    if (modelData.dist) parts.push(modelData.dist);
                                    if (modelData.via) parts.push(app.tr("via %1").arg(modelData.via));
                                    return parts.join(" · ");
                                }
                                truncMode: truncModes.fade
                                width: parent.width
                            }
                        }

                        Rectangle {
                            // starts navigation along this route
                            id: goButton
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            color: goMouse.pressed ? Qt.darker(styler.goBg, 1.2) : styler.goBg
                            height: goLabel.height + 2*styler.themePaddingMedium
                            radius: height / 2
                            width: Math.max(goLabel.width + 3*styler.themePaddingLarge, 2*height)

                            LabelPL {
                                id: goLabel
                                anchors.centerIn: parent
                                color: "white"
                                font.bold: true
                                font.pixelSize: styler.themeFontSizeLarge
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
    }
}
