import AppKit
import ApplicationServices
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let enabledKey = "idleEnabled"
    private var statusItem: NSStatusItem!
    private var menu: NSMenu!
    private var timer: Timer?
    private var permissionTimer: Timer?
    private var lastTrusted: Bool?

    private var isIdling: Bool {
        get { UserDefaults.standard.bool(forKey: enabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: enabledKey) }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        promptForAccessibility()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        menu = NSMenu()
        menu.autoenablesItems = false
        menu.delegate = self
        if let button = statusItem.button {
            button.target = self
            button.action = #selector(statusItemClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        if isIdling && AXIsProcessTrusted() {
            startTimer()
        } else {
            isIdling = false
        }
        updateIcon()
        startPermissionMonitor()
    }

    @objc private func statusItemClicked() {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp || event?.modifierFlags.contains(.control) == true {
            // Temporarily attach the menu so the status item opens it with
            // native positioning/highlighting, then detach so left clicks
            // keep toggling instead of opening it.
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            toggleIdling()
        }
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        let trusted = AXIsProcessTrusted()

        let toggle = NSMenuItem(title: isIdling ? "Stop Idling" : "Start Idling",
                                action: #selector(toggleIdling), keyEquivalent: "")
        toggle.target = self
        toggle.isEnabled = trusted
        menu.addItem(toggle)

        let login = NSMenuItem(title: "Launch at Login",
                               action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        login.target = self
        login.state = SMAppService.mainApp.status == .enabled ? .on : .off
        login.isEnabled = trusted
        menu.addItem(login)

        if !trusted {
            let grant = NSMenuItem(title: "Grant Accessibility…",
                                   action: #selector(openAccessibilitySettings), keyEquivalent: "")
            grant.target = self
            menu.addItem(grant)
        }

        menu.addItem(.separator())
        // Routed through a local selector: macOS auto-assigns an icon to terminate:
        let quit = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quit.target = self
        quit.image = nil
        menu.addItem(quit)
    }

    @objc private func toggleIdling() {
        guard AXIsProcessTrusted() else {
            promptForAccessibility()
            return
        }
        isIdling.toggle()
        if isIdling {
            startTimer()
        } else {
            stopTimer()
        }
        updateIcon()
    }

    @objc private func toggleLaunchAtLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            NSLog("launch-at-login toggle failed: \(error)")
        }
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    @objc private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    private func updateIcon() {
        let trusted = AXIsProcessTrusted()
        let image: NSImage?
        if trusted {
            let color: NSColor = isIdling ? .systemGreen : .white
            let config = NSImage.SymbolConfiguration(pointSize: 15, weight: .regular)
                .applying(NSImage.SymbolConfiguration(paletteColors: [color]))
            image = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: "IdleTyping")?
                .withSymbolConfiguration(config)
        } else {
            image = NSImage(size: NSSize(width: 14, height: 14), flipped: false) { rect in
                NSColor.systemOrange.setFill()
                NSBezierPath(ovalIn: rect).fill()
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: NSFont.boldSystemFont(ofSize: 10),
                    .foregroundColor: NSColor.black,
                ]
                let mark = "!" as NSString
                let size = mark.size(withAttributes: attrs)
                mark.draw(at: NSPoint(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2),
                          withAttributes: attrs)
                return true
            }
        }
        image?.isTemplate = false
        statusItem.button?.image = image
        statusItem.button?.toolTip = trusted
            ? "IdleTyping — \(isIdling ? "idling" : "inactive")"
            : "IdleTyping — Accessibility permission missing, idling won't work"
    }

    // TCC changes don't notify the app, so poll. If the grant disappears at any
    // point, idling is force-disabled and must be re-enabled manually.
    private func startPermissionMonitor() {
        permissionTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            guard let self else { return }
            let trusted = AXIsProcessTrusted()
            if !trusted && self.isIdling {
                self.isIdling = false
                self.stopTimer()
                self.updateIcon()
            }
            if trusted != self.lastTrusted {
                self.lastTrusted = trusted
                self.updateIcon()
            }
        }
    }

    @discardableResult
    private func promptForAccessibility() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    private func startTimer() {
        wiggle()
        let t = Timer(timeInterval: 30, repeats: true) { [weak self] _ in self?.wiggle() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func wiggle() {
        guard let current = CGEvent(source: nil)?.location else { return }
        postMove(to: CGPoint(x: current.x + 1, y: current.y))
        postMove(to: current)
    }

    private func postMove(to point: CGPoint) {
        CGEvent(mouseEventSource: nil, mouseType: .mouseMoved,
                mouseCursorPosition: point, mouseButton: .left)?
            .post(tap: .cghidEventTap)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
