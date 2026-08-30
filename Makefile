APP_NAME  = Idle Brew
EXECUTABLE = IdleBrew
BUNDLE_ID = com.jona.idle-brew
BUILD     = build
BUNDLE    = $(BUILD)/$(APP_NAME).app
DEST      = /Applications
ICON      = AppIcon.icns

install: $(BUILD)/$(EXECUTABLE)
	@pkill -x "$(EXECUTABLE)" 2>/dev/null || true
	rm -rf "$(BUNDLE)"
	mkdir -p "$(BUNDLE)/Contents/MacOS" "$(BUNDLE)/Contents/Resources"
	cp Info.plist "$(BUNDLE)/Contents/"
	cp "$(BUILD)/$(EXECUTABLE)" "$(BUNDLE)/Contents/MacOS/"
	cp "$(ICON)" "$(BUNDLE)/Contents/Resources/"
	codesign --force --sign - --identifier $(BUNDLE_ID) "$(BUNDLE)"
	mkdir -p "$(DEST)"
	rm -rf "$(DEST)/$(APP_NAME).app"
	cp -R "$(BUNDLE)" "$(DEST)/"
	open "$(DEST)/$(APP_NAME).app"

$(BUILD)/$(EXECUTABLE): main.swift
	mkdir -p $(BUILD)
	swiftc -O -o "$@" main.swift

.PHONY: install
