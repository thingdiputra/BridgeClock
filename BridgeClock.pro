# Add more folders to ship with the application, here
# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
# CONFIG += mobility
# MOBILITY +=

# Speed up launching on MeeGo/Harmattan when using applauncherd daemon
# CONFIG += qdeclarative-boostable

TARGET = BridgeClock

linux {

	QMAKE_LFLAGS += -Wl,--rpath=\\\$\$ORIGIN/lib
}

QMAKE_CXXFLAGS += -g

QT += quick webkit

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    timecontroller.cpp \
    timemodel.cpp \
    roundinfo.cpp \
    globalmousearea.cpp \
    mouseevent.cpp

# Installation path
# target.path =

# Please do not modify the following two lines. Required for deployment.

OTHER_FILES += \
    bonjour/LICENSE.bonjour.helper \
    LICENSE \
    qml/BridgeClock/ResultView.qml \
    qml/BridgeClock/fn.js \
    qml/BridgeClock/circularSliderHandle.png \
    qml/BridgeClock/circularSlider.png \
    qml/BridgeClock/tournamentTime.qml \
    qml/BridgeClock/tournamentStart.qml \
    qml/BridgeClock/tournamentResults.qml \
    qml/BridgeClock/Resizer.qml \
    qml/BridgeClock/PseudoTime.qml \
    qml/BridgeClock/main.qml \
    qml/BridgeClock/DatePicker.qml \
    qml/BridgeClock/Clock.qml \
    qml/BridgeClock/CircularSlider.qml \
    qml/BridgeClock/tournamentConnection.qml \
    user.settings.pri

HEADERS += \
    timecontroller.h \
    timemodel.h \
    roundinfo.h \
    globalmousearea.h \
    mouseevent.h
