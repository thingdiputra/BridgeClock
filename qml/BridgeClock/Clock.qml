/*
Copyright (c) 2013 Pauli Nieminen <suokkos@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import QtQuick 2.0
import QtWebKit 3.0
import QtWebKit.experimental 1.0
import QtQuick.Window 2.0

Window {
    id: clockWindow
    property double zoomFactor: height/480
    width: 640
    height: 480
    visible: true
    title: "Aika näkymä"
    flags: Qt.FramelessWindowHint

    Rectangle {
        id: timeView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: current.font.pixelSize + time.font.pixelSize + 12*zoomFactor

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.margins: 3*zoomFactor
            visible: timeController.roundInfo.playing < 2
            id: current
            text: timeController.roundInfo.name;
            font.pixelSize: 40*zoomFactor;
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: current.bottom
            anchors.margins: 3*zoomFactor
            id: time
            text: timeController.roundInfo.playing < 2 ?
                      timeController.roundInfo.timeLeft :
                      timeController.roundInfo.name;
            font.pixelSize: 90*zoomFactor;
        }

        Column {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 10*zoomFactor
            Text {
                id: nextHeading
                visible: timeController.roundInfo.playing < 2
                text: "Seuraavaksi:"
                font.pixelSize: 18*zoomFactor
            }

            Text {
                id: next
                visible: timeController.roundInfo.playing < 2
                text: timeController.roundInfo.nextName;
                font.pixelSize: 30*zoomFactor
            }
        }
    }
    WebView {
        id: results
        anchors.top: timeView.bottom
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        clip: true
        pixelAligned: true
        interactive: true
        url: "http://www.bridgefinland.fi"
        property bool animationDown: true
        Connections {
            target: timeController
            onUpdateResults: {
                console.log(url)
                if (results.url == url) {
                    results.reload.trigger();
                } else {
                    results.url = url;
                }
            }
        }

        onLoadingChanged: {
            switch (loadRequest.status)
            {
            case WebView.LoadSucceededStatus:
                var size = results.experimental.test.contentsSize;
                results.width = clockWindow.width < size.width ? clockWindow.width : size.width
                if (contentY != 0)
                    fixAnimation();
                else
                    scrollTimer.running = true
                break
            case WebView.LoadStartedStatus:
            case WebView.LoadStoppedStatus:
                break
            case WebView.LoadFailedStatus:
                console.log("Failed to load " + url);
                break
            }
        }

       Timer {
            id: scrollTimer
            running: false
            repeat: false
            interval: 2000
            onTriggered: {
                if (results.contentY == 0) {
                    if (results.contentHeight > results.height) {
                        results.animationDown = true
                        results.contentY = results.contentHeight - results.height
                    }
                } else {
                    results.animationDown = false
                    results.contentY = 0;
                }
            }
        }
        function fixAnimation() {
            if (results.animationDown && !scrollTimer.running) {
                results.contentY = results.contentHeight - results.height
            }
        }

        onHeightChanged: fixAnimation();

        Behavior on contentY {
            NumberAnimation {
                duration: results.animationDown ?
                              results.contentHeight > results.height ?
                                  (results.contentHeight - results.height) * 20 :
                                  0 :
                              200
                easing.type: Easing.Linear
                onRunningChanged: {
                    if (!running)
                        scrollTimer.running = true
                }
            }
        }
    }

    MouseArea {
        id: mover
        anchors.fill: parent
        anchors.margins: 50
        property variant startPosition

        signal windowState
        onDoubleClicked: {
            if (clockWindow.visibility == Qt.WindowFullScreen)
                clockWindow.visibility = Qt.WindowMaximized;
            else
                clockWindow.visibility = Qt.WindowFullScreen;
            mover.windowState();
        }
        onPressed: {
            startPosition = Qt.point(mouseX, mouseY)
        }
        onPositionChanged: {
            if (pressedButtons == Qt.LeftButton) {
                var dx = mouseX - startPosition.x
                var dy = mouseY - startPosition.y
                timeController.moveWindow(clockWindow, dx, dy)
            }
        }
        Component.onCompleted: {
            timeController.setItemCursor(mover, "move");
        }
    }

    onWidthChanged: {
        var size = results.experimental.test.contentsSize;
        results.width = clockWindow.width < size.width ? clockWindow.width : size.width
    }

    Resizer {
        anchors.top: parent.top
        anchors.bottom: mover.top
        anchors.left: mover.left
        anchors.right: mover.right
        direction: "T"
    }
    Resizer {
        anchors.top: mover.bottom
        anchors.bottom: parent.bottom
        anchors.left: mover.left
        anchors.right: mover.right
        direction: "B"
    }
    Resizer {
        anchors.top: mover.top
        anchors.bottom: mover.bottom
        anchors.left: parent.left
        anchors.right: mover.left
        direction: "L"
    }
    Resizer {
        anchors.top: mover.top
        anchors.bottom: mover.bottom
        anchors.left: mover.right
        anchors.right: parent.right
        direction: "R"
    }
    Resizer {
        anchors.top: parent.top
        anchors.bottom: mover.top
        anchors.left: parent.left
        anchors.right: mover.left
        direction: "TL"
    }
    Resizer {
        anchors.top: parent.top
        anchors.bottom: mover.top
        anchors.left: mover.right
        anchors.right: parent.right
        direction: "TR"
    }
    Resizer {
        anchors.top: mover.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: mover.left
        direction: "BL"
    }

    Resizer {
        anchors.top: mover.bottom
        anchors.bottom: parent.bottom
        anchors.left: mover.right
        anchors.right: parent.right
        direction: "BR"
    }
}
