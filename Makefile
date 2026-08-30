APP       = IdleTyping
BUNDLE_ID = com.jona.idle-typing
BUILD     = build
BUNDLE    = $(BUILD)/$(APP).app
DEST      = /Applications

install: $(BUILD)/$(APP)
	@pkill -x $(APP) 2>/dev/null || true
	rm -rf "$(BUNDLE)"
	mkdir -p "$(BUNDLE)/Contents/MacOS"
	cp Info.plist "$(BUNDLE)/Contents/"
	cp "$(BUILD)/$(APP)" "$(BUNDLE)/Contents/MacOS/"
	codesign --force --sign - --identifier $(BUNDLE_ID) "$(BUNDLE)"
	mkdir -p "$(DEST)"
	rm -rf "$(DEST)/$(APP).app"
	cp -R "$(BUNDLE)" "$(DEST)/"
	open "$(DEST)/$(APP).app"

$(BUILD)/$(APP): main.swift
	mkdir -p $(BUILD)
	swiftc -O -o "$@" main.swift

.PHONY: install
