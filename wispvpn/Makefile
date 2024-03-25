TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = wispvpn

include $(THEOS)/makefiles/common.mk

APPEX_NAME = wispvpn

wispvpn_FILES = PacketTunnelProvider.swift
wispvpn_INSTALL_PATH = /Applications/Whisper.app/PlugIns
wispvpn_FRAMEWORKS = NetworkExtension
wispvpn_CODESIGN_FLAGS = -Sentitlements.xml
wispvpn_SWIFT_BRIDGING_HEADER = bridging.h
wispvpn_OBJ_FILES = libwhisper.a
wispvpn_LD_FLAGS = -lwhisper

include $(THEOS_MAKE_PATH)/appex.mk
