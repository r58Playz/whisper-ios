TARGET = iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = Whisper

# theos discord people say apps are only arm64 and arm64e spams warnings
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = Whisper

Whisper_FILES = $(wildcard *.swift)
Whisper_FRAMEWORKS = SwiftUI NetworkExtension
Whisper_CODESIGN_FLAGS = -Swispvpn/entitlements.xml

include $(THEOS_MAKE_PATH)/application.mk
SUBPROJECTS += wispvpn
include $(THEOS_MAKE_PATH)/aggregate.mk
