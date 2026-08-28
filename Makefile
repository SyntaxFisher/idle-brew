APP       = IdleTyping
BUNDLE_ID = com.jona.idle-typing
BUILD     = build
BUNDLE    = $(BUILD)/$(APP).app
DEST      = $(HOME)/Applications

install: bundle
	@pkill -x $(APP) 2>/dev/null || true
	mkdir -p "$(DEST)"
	rm -rf "$(DEST)/$(APP).app"
	cp -R "$(BUNDLE)" "$(DEST)/"
	@$(MAKE) --no-print-directory clean-legacy
	open "$(DEST)/$(APP).app"

bundle: $(BUILD)/$(APP)
	rm -rf "$(BUNDLE)"
	mkdir -p "$(BUNDLE)/Contents/MacOS"
	cp Info.plist "$(BUNDLE)/Contents/"
	cp "$(BUILD)/$(APP)" "$(BUNDLE)/Contents/MacOS/"
	codesign --force --sign - --identifier $(BUNDLE_ID) "$(BUNDLE)"

$(BUILD)/$(APP): main.swift
	mkdir -p $(BUILD)
	swiftc -O -o "$@" main.swift

# Remove leftovers from the old CLI version (bash launcher + Python venv)
clean-legacy:
	@for link in /opt/homebrew/bin/idle /usr/local/bin/idle; do \
		if [ -L "$$link" ] && readlink "$$link" | grep -Eq "$(CURDIR)|idle-typing"; then \
			rm -f "$$link" && echo "Removed legacy CLI symlink: $$link"; \
		fi; \
	done
	@if [ -d .venv ]; then rm -rf .venv && echo "Removed legacy .venv/"; fi
	@if [ -d __pycache__ ]; then rm -rf __pycache__ && echo "Removed legacy __pycache__/"; fi
	@for rc in "$$HOME/.zshrc" "$$HOME/.zprofile"; do \
		if [ -f "$$rc" ] && grep -nE "alias idle=|idle-typing" "$$rc" 2>/dev/null; then \
			echo "Note: $$rc still references the old idle CLI (lines above) — remove manually."; \
		fi; \
	done

reset-tcc:
	tccutil reset Accessibility $(BUNDLE_ID)

uninstall:
	@pkill -x $(APP) 2>/dev/null || true
	rm -rf "$(DEST)/$(APP).app"

clean:
	rm -rf $(BUILD)

.PHONY: install bundle clean-legacy reset-tcc uninstall clean
