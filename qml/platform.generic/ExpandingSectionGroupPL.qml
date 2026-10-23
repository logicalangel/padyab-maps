/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018-2019 Rinigus, 2019 Purism SPC
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

import QtQuick 2.9
import pm.platform 1.0
import pm 1.0

Column {
    // sections are cards with a header row; one section is open at a time
    id: section
    width: parent.width
    spacing: styler.themePaddingLarge

    property int currentIndex // ignored
    property list<QtObject> selections
    default property alias  content: section.selections

    signal closeAll

    Item {
        width: parent.width
        height: styler.themePaddingSmall
    }

    Repeater {
        delegate: Rectangle {
            id: del
            anchors.horizontalCenter: parent.horizontalCenter
            color: styler.itemBg
            height: col.height
            radius: styler.cardRadius
            width: section.width - 2*styler.themeHorizontalPageMargin

            property bool expanded: false

            Column {
                id: col
                width: parent.width

                Rectangle {
                    // header: title and an arrow, tap to open or close
                    color: headerMouse.pressed ? styler.itemPressed : "transparent"
                    height: title.height + 2*styler.themePaddingLarge
                    radius: styler.cardRadius
                    width: parent.width

                    LabelPL {
                        id: title
                        anchors.left: parent.left
                        anchors.leftMargin: styler.themePaddingLarge
                        anchors.right: arrow.left
                        anchors.rightMargin: styler.themePaddingMedium
                        anchors.verticalCenter: parent.verticalCenter
                        color: styler.itemFg
                        font.bold: del.expanded
                        font.pixelSize: styler.themeFontSizeLarge
                        text: selections[model.index].title
                    }

                    LabelPL {
                        id: arrow
                        anchors.right: parent.right
                        anchors.rightMargin: styler.themePaddingLarge
                        anchors.verticalCenter: parent.verticalCenter
                        color: styler.itemFg
                        font.pixelSize: styler.themeFontSizeLarge
                        opacity: 0.4
                        rotation: del.expanded ? 90 : 0
                        text: "\u203A"
                    }

                    MouseArea {
                        id: headerMouse
                        anchors.fill: parent
                        onClicked: {
                            if (!del.expanded) closeAll();
                            del.expanded = !del.expanded;
                        }
                    }
                }

                Item {
                    id: item
                    anchors.left: parent.left
                    anchors.right: parent.right
                    data: selections[model.index]
                    height: childrenRect.height
                    visible: del.expanded
                }

                Item {
                    height: styler.themePaddingLarge
                    visible: del.expanded
                    width: parent.width
                }
            }

            Connections {
                target: section
                function onCloseAll() { del.expanded = false; }
            }
        }
        model: selections.length
    }

    Item {
        width: parent.width
        height: styler.themePaddingSmall
    }
}
