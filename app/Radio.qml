/*
 * Copyright (C) 2016 The Qt Company Ltd.
 * Copyright (C) 2017 Konsulko Group
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import AGL.Demo.Controls 1.0

import QtQuick.Window 2.13

ApplicationWindow {
    id: root

    width: container.width * container.scale
    height: container.height * container.scale

    property string title

    function freq2str(freq) {
        if (freq > 5000000) {
            return '%1 MHz'.arg((freq / 1000000).toFixed(1))
        } else {
            return '%1 kHz'.arg((freq / 1000).toFixed(0))
        }
    }

    Item {
        id: container
        anchors.centerIn: parent
        width: Window.width
        height: Window.height
        //scale: screenInfo.scale_factor()
        scale: 1

    ColumnLayout {
        anchors.fill: parent
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 1080
            clip: true

            Image {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: controls.top
                fillMode: Image.Stretch
                source: './images/HMI_Radio_Equalizer.svg'
            }
            Item {
                id: controls
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height :307
                Rectangle {
                    anchors.fill: parent
                    color: 'black'
                    opacity: 0.75
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: container.width * 0.02
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Row {
                            spacing: 20
                            Image {
                                source: './images/FM_Icons_FM.svg'
                            }
//                            ToggleButton {
//                                offImage: './images/FM_Icons_FM.svg'
//                                onImage: './images/FM_Icons_AM.svg'
//                                onCheckedChanged: {
//                                    radio.band = checked ? radio.amBand : radio.fmBand
//                                    radio.frequency = radio.minFrequency
//                                }
//                            }
                        }
                        ColumnLayout {
                            anchors.fill: parent
                            Label {
                                id: label
                                Layout.alignment: Layout.Center
                                text: freq2str(radio.frequency)
                                horizontalAlignment: Label.AlignHCenter
                                verticalAlignment: Label.AlignVCenter
                            }
                            Label {
                                id: artist
                                Layout.alignment: Layout.Center
                                text: root.title
                                horizontalAlignment: Label.AlignHCenter
                                verticalAlignment: Label.AlignVCenter
                                font.pixelSize: label.font.pixelSize * 0.6
                            }
                        }
                    }
                    Slider {
                        id: slider
                        Layout.fillWidth: true
                        from: radio.minFrequency
                        to: radio.maxFrequency
                        stepSize: radio.frequencyStep
                        snapMode: Slider.SnapOnRelease
                        value: radio.frequency
                        onPressedChanged: {
                            radio.frequency = value
                            root.title = ''
                        }
                        Label {
                            anchors.left: parent.left
                            anchors.bottom: parent.top
                            font.pixelSize: 30
                            text: freq2str(radio.minFrequency)
                        }
                        Label {
                            anchors.right: parent.right
                            anchors.bottom: parent.top
                            font.pixelSize: 30
                            text: freq2str(radio.maxFrequency)
                        }
                    }
                    RowLayout {
                        Layout.fillHeight: true

                        Label {
                            text: 'TEXT'
                        }

                        ImageButton {
                            offImage: './images/AGL_MediaPlayer_BackArrow.svg'
                            Timer {
                                running: parent.pressed
                                triggeredOnStart: true
                                interval: 100
                                repeat: true
                                onTriggered: {
                                    if(radio.frequency > radio.minFrequency) {
                                        radio.frequency -= radio.frequencyStep
                                        root.title = ''
                                    }
                                }
                            }
                        }

                        ImageButton {
                            offImage: './images/AGL_MediaPlayer_ForwardArrow.svg'
                            Timer {
                                running: parent.pressed
                                triggeredOnStart: true
                                interval: 100
                                repeat: true
                                onTriggered: {
                                    if(radio.frequency < radio.maxFrequency) {
                                        radio.frequency += radio.frequencyStep
                                        root.title = ''
                                    }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        ImageButton {
                            id: play
                            offImage: './images/AGL_MediaPlayer_Player_Play.svg'
                            onClicked: {
                                radio.start()
                            }
                            states: [
                                State {
                                    when: radio.playing
                                    PropertyChanges {
                                        target: play
                                        offImage: './images/AGL_MediaPlayer_Player_Pause.svg'
                                        onClicked: radio.stop()
                                    }
                                }
                            ]
                        }

                        Item { Layout.fillWidth: true }

                        Label {
                            id: scanLabel
                            text: 'TEST'
                            color: radio.scanning ? '#59FF7F' : '#FFFFFF'
                        }

                        ImageButton {
                            id: scanBackwardBtn
                            offImage: './images/AGL_MediaPlayer_BackArrow.svg'
                            states: [
                                State {
                                    when: radio.playing
                                    PropertyChanges {
                                        target: scanBackwardBtn
                                        onClicked: {
                                            radio.scanBackward()
                                            root.title = ''
                                        }
                                    }
                                }
                            ]
                        }

                        ImageButton {
                            id: scanForwardBtn
                            offImage: './images/AGL_MediaPlayer_ForwardArrow.svg'
                            states: [
                                State {
                                    when: radio.playing
                                    PropertyChanges {
                                        target: scanForwardBtn
                                        onClicked: {
                                            radio.scanForward()
                                            root.title = ''
                                        }
                                    }
                                }
                            ]
                        }
                    }
                }
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 480

            ListView {
                anchors.fill: parent
                anchors.leftMargin: 50
                anchors.rightMargin: 50
                clip: true
                header: Label { text: 'PRESETS'; opacity: 0.5 }
                model: presetModel

                delegate: MouseArea {
                    width: ListView.view.width
                    height: ListView.view.height / 4

                    onClicked: {
                        radio.band = model.modelData.band
                        radio.frequency = model.modelData.frequency
                        root.title = model.modelData.title
                    }

                    RowLayout {
                        anchors.fill: parent
                        ColumnLayout {
                            Layout.fillWidth: true
                            Label {
                                Layout.fillWidth: true
                                text: model.title
                            }
                            Label {
                                Layout.fillWidth: true
                                text: freq2str(model.frequency)
                                color: '#59FF7F'
                                font.pixelSize: 32
                            }
                        }
                        Image {
                            source: {
                                switch (model.modelData.band) {
                                case radio.fmBand:
                                    return './images/FM_Icons_FM.svg'
                                case radio.amBand:
                                    return './images/FM_Icons_AM.svg'
                                }
                                return null
                            }
                        }
                    }
                }
            }
        }
    }
}
}
