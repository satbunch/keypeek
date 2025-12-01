//
//  KeyboardMonitor.swift
//  mycheatsheet
//
//  Created by Yoshio Satomi  on 2025/11/28.
//

import Cocoa
import Combine

class KeyboardMonitor: ObservableObject {
    @Published var showOverlay: Bool = false
    @Published var activeAppId: String = ""
    
    private var lastCommandPressTime: Date = Date.distantPast
    private var isCommandPressed: Bool = false
    private var holdTimer: Timer?
    
    private let doubleTapInterval: TimeInterval = 0.3
    private let holdDuration: TimeInterval = 0.5
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsChanged(event)
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsChanged(event)
            return event
        }
    }
    
    private func handleFlagsChanged(_ event: NSEvent) {
        let isCommandNow = event.modifierFlags.contains(.command)
        
        if isCommandNow == isCommandPressed { return }
        
        isCommandPressed = isCommandNow
        
        if isCommandPressed {
            let now = Date()
            let timeSinceLastPress = now.timeIntervalSince(lastCommandPressTime)
            
            if timeSinceLastPress < doubleTapInterval {
                startHoldTimer()
                checkActiveApp()
            } else {
                lastCommandPressTime = now
            }
        } else {
            holdTimer?.invalidate()
            holdTimer = nil
            
            if showOverlay {
                DispatchQueue.main.async {
                    self.showOverlay = false
                }
            }
        }
    }
    
    private func startHoldTimer() {
        holdTimer?.invalidate()
        
        holdTimer = Timer.scheduledTimer(withTimeInterval: holdDuration, repeats: false) { [weak self] _ in
            if let self = self, self.isCommandPressed {
                DispatchQueue.main.async {
                    self.showOverlay = true
                }
            }
        }
    }
    
    private func checkActiveApp() {
        if let frontApp = NSWorkspace.shared.frontmostApplication {
            let id = frontApp.bundleIdentifier ?? "default"
            DispatchQueue.main.async {
                self.activeAppId = id
                print("Active App ID: \(id)")
            }
        }
    }
}
