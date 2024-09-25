TEMPLATE = app
TARGET = radio
QT = qml quickcontrols2
CONFIG += c++11 link_pkgconfig

PKGCONFIG += qtappfw-radio

HEADERS = PresetDataObject.h
SOURCES = main.cpp PresetDataObject.cpp

RESOURCES += \
    radio.qrc \
    images/images.qrc

target.path = /usr/bin
target.files += $${OUT_PWD}/$${TARGET}
target.CONFIG = no_check_exist executable

INSTALLS += target
