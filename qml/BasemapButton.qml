/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2019-2021 Rinigus, 2019 Purism SPC
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

import "js/util.js" as Util

// Sheet for choosing the map: type, light and transport mode as large
// tiles, the map style and the map scale. Opened from the map controls.
MouseArea {
    id: master
    anchors.fill: parent
    enabled: openMenu
    visible: openMenu
    z: 9999

    property bool   openMenu: false

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
                        font.pixelSize: Math.round(styler.themeFontSizeExtraLarge * 1.2)
                        text: app.tr("Choose Map")
                        truncMode: truncModes.fade
                    }

                    CardButton {
                        id: closeButton
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        cross: true
                        size: Math.round(styler.themeIconSizeSmall * 1.2)
                        onClicked: master.openMenu = false
                    }
                }

                Flow {
                    // available map styles with previews
                    id: styleGrid
                    spacing: styler.themePaddingMedium
                    width: parent.width

                    Repeater {
                        model: styleGrid.model

                        Rectangle {
                            id: styleTile
                            border.color: styler.route
                            border.width: model.active ? Math.max(2, Math.round(styler.themePaddingSmall*0.75)) : 0
                            color: styleMouse.pressed ? styler.itemPressed : styler.itemBg
                            height: preview.height + styleName.height + 3*styler.themePaddingSmall + border.width
                            radius: styler.cardRadius
                            width: Math.floor((content.width - 2*styleGrid.spacing) / 3)

                            Image {
                                id: preview
                                anchors.horizontalCenter: parent.horizontalCenter
                                fillMode: Image.PreserveAspectCrop
                                height: Math.round(width * 0.75)
                                smooth: true
                                source: {
                                    var name = model.pid.toLowerCase().replace(/ /g, "-");
                                    if (styleGrid.previews.indexOf(name) < 0) return "";
                                    return "icons/basemap/preview/%1.jpg".arg(name);
                                }
                                width: parent.width - 2*Math.max(styler.themePaddingSmall, parent.border.width)
                                y: Math.max(styler.themePaddingSmall, parent.border.width)
                            }

                            IconPL {
                                // used when there is no preview for the style
                                anchors.centerIn: preview
                                iconColorize: false
                                iconHeight: Math.round(preview.height * 0.6)
                                iconSource: app.getIcon("icons/basemap/type-default")
                                visible: preview.status !== Image.Ready
                            }

                            LabelPL {
                                id: styleName
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: preview.bottom
                                anchors.topMargin: styler.themePaddingSmall
                                color: styler.itemFg
                                font.bold: model.active
                                font.pixelSize: styler.themeFontSizeSmall
                                horizontalAlignment: Text.AlignHCenter
                                text: model.name
                                truncMode: truncModes.fade
                                width: parent.width - 2*styler.themePaddingSmall
                            }

                            MouseArea {
                                id: styleMouse
                                anchors.fill: parent
                                onClicked: {
                                    py.call_sync("poor.app.set_basemap", [model.pid]);
                                    master.fillMenu();
                                }
                            }
                        }
                    }

                    property var model: ListModel {}
                    // styles with a preview in icons/basemap/preview
                    property var previews: ["openfreemap-bright", "openfreemap-liberty",
                                            "openfreemap-positron", "opentopomap"]
                }

                Component {
                    id: tileDelegate
                    Rectangle {
                        // one choice as a large tile, framed when in use
                        id: tile
                        border.color: styler.route
                        border.width: model.current ? Math.max(2, Math.round(styler.themePaddingSmall*0.75)) : 0
                        color: mouse.pressed ? styler.itemPressed : styler.itemBg
                        height: Math.round(width * 0.8)
                        opacity: model.enabled ? 1 : 0.5
                        radius: styler.cardRadius
                        width: Math.floor((content.width - 2*view.spacing) / 3)

                        property var view: parent

                        Column {
                            anchors.centerIn: parent
                            spacing: styler.themePaddingSmall
                            width: parent.width - 2*styler.themePaddingMedium

                            IconPL {
                                anchors.horizontalCenter: parent.horizontalCenter
                                iconColorize: false
                                iconHeight: Math.round(tile.height * 0.42)
                                iconSource: app.getIcon("icons/basemap/%1-%2".arg(tile.view.iconPrefix).arg(model.name))
                            }

                            LabelPL {
                                color: styler.itemFg
                                font.bold: model.active
                                font.pixelSize: styler.themeFontSizeSmall
                                horizontalAlignment: Text.AlignHCenter
                                text: tile.view.tr[model.name] || model.name
                                truncMode: truncModes.fade
                                width: parent.width
                            }
                        }

                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            enabled: model.enabled
                            onClicked: tile.view.apply(model.name, model.active, model.enabled)
                        }
                    }
                }

                LabelPL {
                    color: styler.itemFg
                    font.bold: true
                    font.pixelSize: styler.themeFontSizeMedium
                    opacity: 0.6
                    text: app.tr("Type")
                    visible: typeGrid.model.count > 1
                }

                Flow {
                    id: typeGrid
                    spacing: styler.themePaddingMedium
                    visible: model.count > 1
                    width: parent.width

                    Repeater {
                        delegate: tileDelegate
                        model: parent.model
                    }

                    property string iconPrefix: "type"
                    property var    model: ListModel {}
                    property var    tr: {
                        "default": app.tr("Default"),
                        "guidance": app.tr("Guidance"),
                        "hybrid": app.tr("Hybrid"),
                        "preview": app.tr("Preview"),
                        "satellite": app.tr("Satellite"),
                        "terrain": app.tr("Terrain"),
                        "traffic": app.tr("Traffic")
                    }

                    function apply(name, active, enabled) {
                        if (!enabled) return;
                        app.conf.set("basemap_type", active ? "" : name);
                        py.call_sync("poor.app.basemap.update", []);
                        master.fillMenu();
                    }
                }

                LabelPL {
                    color: styler.itemFg
                    font.bold: true
                    font.pixelSize: styler.themeFontSizeMedium
                    opacity: 0.6
                    text: app.tr("Light")
                    visible: lightGrid.model.count > 1
                }

                Flow {
                    id: lightGrid
                    spacing: styler.themePaddingMedium
                    visible: model.count > 1
                    width: parent.width

                    Repeater {
                        delegate: tileDelegate
                        model: parent.model
                    }

                    property string iconPrefix: "light"
                    property var    model: ListModel {}
                    property var    tr: {
                        "day": app.tr("Day"),
                        "night": app.tr("Night")
                    }

                    function apply(name, active, enabled) {
                        if (!enabled) return;
                        app.conf.set("basemap_light", active ? "" : name);
                        py.call_sync("poor.app.basemap.update", []);
                        master.fillMenu();
                    }
                }

                LabelPL {
                    color: styler.itemFg
                    font.bold: true
                    font.pixelSize: styler.themeFontSizeMedium
                    opacity: 0.6
                    text: app.tr("Transport")
                    visible: transGrid.model.count > 1
                }

                Flow {
                    id: transGrid
                    spacing: styler.themePaddingMedium
                    visible: model.count > 1
                    width: parent.width

                    Repeater {
                        delegate: tileDelegate
                        model: parent.model
                    }

                    property string iconPrefix: "transport"
                    property var    model: ListModel {}
                    property var    tr: {
                        "bicycle": app.tr("Bicycle"),
                        "car": app.tr("Car"),
                        "foot": app.tr("Walking"),
                        "transit": app.tr("Public transport")
                    }

                    function apply(name, active, enabled) {
                        if (!enabled) return;
                        app.conf.set("basemap_vehicle", active ? "" : name);
                        py.call_sync("poor.app.basemap.update", []);
                        master.fillMenu();
                    }
                }

                Rectangle {
                    // opens the list of all maps, including the ones needing API keys
                    color: moreMouse.pressed ? styler.itemPressed : styler.itemBg
                    height: moreLabel.height + 2*styler.themePaddingLarge
                    radius: styler.cardRadius
                    width: parent.width

                    LabelPL {
                        id: moreLabel
                        anchors.left: parent.left
                        anchors.leftMargin: styler.themePaddingLarge
                        anchors.right: moreArrow.left
                        anchors.rightMargin: styler.themePaddingMedium
                        anchors.verticalCenter: parent.verticalCenter
                        color: styler.itemFg
                        font.pixelSize: styler.themeFontSizeMedium
                        text: app.tr("More maps")
                    }

                    LabelPL {
                        id: moreArrow
                        anchors.right: parent.right
                        anchors.rightMargin: styler.themePaddingLarge
                        anchors.verticalCenter: parent.verticalCenter
                        color: styler.itemFg
                        font.pixelSize: styler.themeFontSizeLarge
                        opacity: 0.5
                        text: "\u203A"
                    }

                    MouseArea {
                        id: moreMouse
                        anchors.fill: parent
                        onClicked: {
                            master.openMenu = false;
                            app.pushMain(Qt.resolvedUrl("BasemapPage.qml"));
                        }
                    }
                }

                Rectangle {
                    // map scale
                    color: styler.itemBg
                    height: sliders.height + 2*styler.themePaddingMedium
                    radius: styler.cardRadius
                    width: parent.width

                    Column {
                        id: sliders
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: styler.themePaddingLarge
                        width: parent.width

                        SliderPL {
                            id: scaleSlider
                            label: app.tr("Map scale")
                            maximumValue: 2.0
                            minimumValue: 0.5
                            stepSize: 0.1
                            value: app.conf.get("map_scale")
                            valueText: value
                            visible: !scaleSliderNav.visible
                            width: parent.width
                            onValueChanged: {
                                app.conf.set("map_scale", value);
                            }
                        }

                        SliderPL {
                            id: scaleSliderNav
                            label: app.tr("Map scale during navigation")
                            maximumValue: 4.0
                            minimumValue: 0.5
                            stepSize: 0.1
                            value: app.transportMode ? app.conf.get("map_scale_navigation_" + app.transportMode) : 1
                            valueText: value
                            visible: (app.mode === modes.followMe || app.mode === modes.navigate || app.mode === modes.navigatePost) && app.transportMode
                            width: parent.width
                            onValueChanged: {
                                if (!app.transportMode) return;
                                app.conf.set("map_scale_navigation_" + app.transportMode, value);
                            }
                        }

                        SliderPL {
                            id: scaleSliderInfo
                            label: app.tr("Route info scale during navigation")
                            maximumValue: 2.0
                            minimumValue: 0.5
                            stepSize: 0.1
                            value: app.transportMode ? app.conf.get("navigation_info_scale_" + app.transportMode) : 1
                            valueText: value
                            visible: app.mode === modes.navigate && app.transportMode
                            width: parent.width
                            onValueChanged: {
                                if (!app.transportMode) return;
                                app.conf.set("navigation_info_scale_" + app.transportMode, value);
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: py
        onBasemapChanged: if (openMenu) fillMenu();
    }

    onClicked: openMenu = false

    function open() {
        master.fillMenu();
        openMenu = true;
    }

    function fillMenu() {
        py.call("poor.app.basemap.list", [], function(basemaps) {
            styleGrid.model.clear();
            Util.appendAll(styleGrid.model, basemaps.filter(function (b) {
                return b.available;
            }));
        });
        py.call("poor.app.basemap.options", [], function(options) {
            typeGrid.model.clear();
            Util.appendAll(typeGrid.model, options.type);
            lightGrid.model.clear();
            Util.appendAll(lightGrid.model, options.light);
            transGrid.model.clear();
            Util.appendAll(transGrid.model, options.vehicle);
        });
    }
}
