GO_EASY_ON_ME = 1

export MODULES=congruence

ADDITIONAL_CFLAGS = -fobjc-arc

include theos/makefiles/common.mk

BUNDLE_NAME = CustomSoundPrefs
CustomSoundPrefs_FILES = $(wildcard *.mm) $(wildcard *.m) $(wildcard *.c)
CustomSoundPrefs_INSTALL_PATH = /Library/PreferenceBundles
CustomSoundPrefs_FRAMEWORKS = UIKit Foundation QuartzCore CoreGraphics AVFoundation MediaPlayer AudioToolbox CoreMedia MessageUI Social GLKit OpenGLES CFNetwork AudioToolbox CoreAudio MobileCoreServices SystemConfiguration
CustomSoundPrefs_PRIVATE_FRAMEWORKS = Preferences
#CustomSoundPrefs_XIBS = $(wildcard LisSongDownladed/*.xib)
CustomSoundPrefs_LIBRARIES = sqlite3
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/CustomSoundPrefs.plist$(ECHO_END)
