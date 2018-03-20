GO_EASY_ON_ME = 1
ADDITIONAL_CFLAGS = -fobjc-arc

include theos/makefiles/common.mk

TWEAK_NAME = CustomSound
CustomSound_FILES = Tweak.xm
CustomSound_FRAMEWORKS = UIKit AVFoundation AudioToolbox CoreMedia MediaPlayer
CustomSound_PRIVATE_FRAMEWORKS = ToneKit
#CustomSound_LIBRARIES = nosand
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += customsoundprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
