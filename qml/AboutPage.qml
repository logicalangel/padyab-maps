/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018 Rinigus
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

PagePL {
    id: page
    title: app.tr("About Padyab Maps")

    Column {
        id: column
        spacing: styler.themePaddingLarge
        width: parent.width

        Image {
            // Banner
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            smooth: true
            source: "icons/banner.jpg"
            width: column.width

            Image {
                // Logo
                anchors.left: parent.left
                anchors.leftMargin: styler.themeHorizontalPageMargin
                anchors.top: parent.top
                anchors.topMargin: Math.min(parent.height/4, styler.themePaddingMedium)
                height: parent.height / 2
                smooth: true
                source: "icons/pure-maps.svg"
                sourceSize.height: height
                sourceSize.width: height
                width: height
            }
        }

        ListItemLabel {
            font.bold: true
            font.pixelSize: styler.cardTitleFontSize
            horizontalAlignment: Text.AlignHCenter
            text: "Padyab Maps"
        }

        ListItemLabel {
            color: styler.themeSecondaryHighlightColor
            height: implicitHeight
            horizontalAlignment: Text.AlignHCenter
            text: app.tr("version %1", programVersion)
        }

        ListItemLabel {
            height: styler.themeItemSizeExtraSmall
            horizontalAlignment: Text.AlignHCenter
            text: app.tr("This is a limited edition distributed through Jolla Store")
            visible: programVariantJollaStore
            wrapMode: Text.WordWrap
        }

        ListItemLabel {
            color: styler.themeSecondaryHighlightColor
            horizontalAlignment: Text.AlignHCenter
            text: app.tr('Based on <a href="https://github.com/rinigus/pure-maps">Pure Maps</a>')
        }

        ListItemLabel {
            horizontalAlignment: Text.AlignHCenter
            text: app.tr('GitHub <a href="https://github.com/logicalangel/pure-maps">project page</a>')
        }

        Rectangle {
            // credits and license
            anchors.horizontalCenter: parent.horizontalCenter
            color: styler.itemBg
            height: creditsColumn.height + 2*styler.themePaddingLarge
            radius: styler.cardRadius
            width: parent.width - 2*styler.themeHorizontalPageMargin

            Column {
                id: creditsColumn
                anchors.verticalCenter: parent.verticalCenter
                spacing: styler.themePaddingLarge
                width: parent.width

                Column {
                    id: credits
                    spacing: styler.themePaddingSmall
                    width: parent.width

                    ListItemLabel {
                        font.pixelSize: styler.themeFontSizeSmall
                        height: implicitHeight
                        text: "Copyright ©"
                    }

                    ListItemLabel {
                        font.pixelSize: styler.themeFontSizeSmall
                        height: implicitHeight
                        horizontalAlignment: Text.AlignRight
                        text: "2014–2018 Osmo Salomaa\n2018-2022 Rinigus\n2026 Parya Rastegar"
                    }

                    ListItemLabel {
                        font.pixelSize: styler.themeFontSizeSmall
                        height: implicitHeight
                        horizontalAlignment: Text.AlignRight
                        text: app.tr("Interface, icon and markers by %1\nBanner photo by %2 (Pexels License)", "Parya Rastegar", "Yaroslav Shuraev")
                        wrapMode: Text.WordWrap
                    }

                    ListItemLabel {
                        font.pixelSize: styler.themeFontSizeSmall
                        height: implicitHeight
                        horizontalAlignment: Text.AlignRight
                        text: app.tr('Transportation icons made by <a href="https://www.flaticon.com/authors/freepik" title="Freepik">Freepik</a> ' +
                                     'from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a>')
                        wrapMode: Text.WordWrap
                    }
                }

                ListItemLabel {
                    font.pixelSize: styler.themeFontSizeSmall
                    height: implicitHeight
                    horizontalAlignment: implicitWidth >
                                         parent.width - anchors.leftMargin - anchors.rightMargin ?
                                             Text.AlignLeft : Text.AlignHCenter
                    text: app.tr("Padyab Maps is free software released under the GNU General Public License (GPL), version 3 or later.")
                    wrapMode: Text.WordWrap
                }
            }
        }

        SectionLabel {
            text: app.tr("Translated by")
        }

        ListItemLabel {
            font.pixelSize: styler.themeFontSizeSmall
            height: visible ? styler.themeItemSizeExtraSmall : 0
            horizontalAlignment: Text.AlignHCenter
            // TRANSLATORS: This is a special message that shouldn't be translated
            // literally. It is used in the about page to give credits to the translators.
            // Thus, you should translate it to your name. You can also include other
            // translators who have contributed to this translation; in that case, please
            // write them on separate lines seperated by newlines (\n).
            text: app.tr("translator-credits")
            visible: text && text !== "translator-credits"
        }

        ListItemLabel {
            font.pixelSize: styler.themeFontSizeSmall
            height: implicitHeight
            horizontalAlignment: implicitWidth >
                                 parent.width - anchors.leftMargin - anchors.rightMargin ?
                                     Text.AlignLeft : Text.AlignHCenter
            text: app.tr("Translations come from Pure Maps, where you can add new ones or improve existing ones at Transifex.")
            wrapMode: Text.WordWrap
        }

        ListItemLabel {
            horizontalAlignment: Text.AlignHCenter
            text: app.tr('Translations at <a href="https://www.transifex.com/rinigus/pure-maps">Transifex page</a>')
        }
    }
}
