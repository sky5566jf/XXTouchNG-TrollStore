TARGET := iphone:clang:14.5:14.0
ARCHS = arm64 arm64e

ifeq ($(FINALPACKAGE),1)
export TARGET_CODESIGN := ldid
export TARGET_CODESIGN_FLAGS := -S
endif

export XXT_VERSION = 3.0.1-trollstore
include $(THEOS)/makefiles/common.mk

# Targets                    # Archs              # Dependencies
SUBPROJECTS = liblua         # arm64, arm64e      #
SUBPROJECTS += auth          # arm64, arm64e      # liblua
SUBPROJECTS += debug         # arm64, arm64e      # ellekit
SUBPROJECTS += core          # arm64              # liblua
SUBPROJECTS += ext           # arm64              # liblua
SUBPROJECTS += exstring      # arm64              # liblua
SUBPROJECTS += alert         # arm64, arm64e      # liblua, ellekit, auth
SUBPROJECTS += app           # arm64              # liblua, ext, alert
SUBPROJECTS += cookies       # arm64              # liblua, app
SUBPROJECTS += file          # arm64              # liblua
SUBPROJECTS += memory        # arm64              # liblua
SUBPROJECTS += monkey        # arm64, arm64e      # liblua, ellekit, auth
SUBPROJECTS += pasteboard    # arm64              # liblua
SUBPROJECTS += touch         # arm64              # liblua, debug
SUBPROJECTS += samba         # arm64              # liblua
SUBPROJECTS += screen        # arm64, arm64e      # liblua, ellekit, ext
SUBPROJECTS += device        # arm64, arm64e      # liblua, debug, ext, ellekit
SUBPROJECTS += proc          # arm64, arm64e      # liblua, ext
SUBPROJECTS += supervisor    # arm64, arm64e      # liblua, core, proc
SUBPROJECTS += hid           # arm64, arm64e      # liblua, proc, supervisor, ellekit
SUBPROJECTS += webserv       # arm64              # liblua, debug, alert, device, proc, screen, supervisor, monkey, app
SUBPROJECTS += add1s         # arm64              #
SUBPROJECTS += entitleme     # arm64, arm64e      # liblua, ellekit

include $(THEOS_MAKE_PATH)/aggregate.mk


before-all::
	sed 's/@TARGET_CODESIGN_CERT@/$(TARGET_CODESIGN_CERT)/g' 'ext/layout/usr/local/xxtouch/lib/xxtouch/init.lua.in' > 'ext/layout/usr/local/xxtouch/lib/xxtouch/init.lua'
	sed 's/@XXT_VERSION@/$(XXT_VERSION)/g' 'layout/DEBIAN/control.in' > 'layout/DEBIAN/control'
	touch layout/Applications/XXTExplorer.app/XXTExplorer

explorer::
	sed 's/@XXT_VERSION@/$(XXT_VERSION)/g' 'explorer/XXTExplorer/Defines/XXTEAppDefines.plist.in' > 'explorer/XXTExplorer/Defines/XXTEAppDefines.plist'
	sed 's/@XXT_VERSION@/$(XXT_VERSION)/g' 'explorer/XXTExplorer/Supporting Files/Base.lproj/Archive-Info.plist.in' > 'explorer/XXTExplorer/Supporting Files/Base.lproj/Archive-Info.plist'
	sed 's/@XXT_VERSION@/$(XXT_VERSION)/g' 'explorer/XXTExplorer/Supporting Files/Base.lproj/Info.plist.in' > 'explorer/XXTExplorer/Supporting Files/Base.lproj/Info.plist'
	cd 'explorer'; ./build.sh; cd -
	cp -rp 'explorer/Releases/XXTExplorer.xcarchive/Products/Applications/XXTExplorer.app' 'layout/Applications'
