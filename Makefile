TARGET = iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = Whisper

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = Whisper

Whisper_FILES = ContentView.swift WhisperApp.swift
Whisper_FRAMEWORKS = SwiftUI NetworkExtension
Whisper_CODESIGN_FLAGS = -Sentitlements.xml

include $(THEOS_MAKE_PATH)/application.mk
SUBPROJECTS += wispvpn
include $(THEOS_MAKE_PATH)/aggregate.mk
