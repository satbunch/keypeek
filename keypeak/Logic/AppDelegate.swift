//
//  AppDelegate.swift
//  mycheatsheet
//
//  Created by Yoshio Satomi  on 2025/11/30.
//

import Cocoa
import Combine
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var overlayWindow: NSPanel!
    var settingsWindow: NSWindow?
    var keyMonitor = KeyboardMonitor()
    var dataManager = DataManager()
    var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupOverlayWindow()
        keyMonitor.$showOverlay
            .sink { [weak self] show in
                if show {
                    self?.showWindow()
                } else {
                    self?.hideWindow()
                }
            }
            .store(in: &cancellables)
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "command", accessibilityDescription: "Cheatsheet")
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Reload JSON", action: #selector(reloadJSON), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    func setupOverlayWindow() {
        let contentView = CheatsheetRootView(keyMonitor: keyMonitor, dataManager: dataManager)
        let hostingController = NSHostingController(rootView: contentView)
        
        overlayWindow = NSPanel(
            contentRect: NSRect(x: 0, y:0, width: 400, height: 300),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered, defer: false
        )
        
        overlayWindow.contentViewController = hostingController
        overlayWindow.isOpaque = false
        overlayWindow.backgroundColor = .clear
        overlayWindow.level = .floating
        overlayWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        overlayWindow.center()
        overlayWindow.orderOut(nil)
    }
    
    func showWindow() {
        dataManager.loadJSON()
        overlayWindow.center()
        overlayWindow.orderFront(nil)
    }
    
    func hideWindow() {
        overlayWindow.orderOut(nil)
    }
    
    @objc func openJSON() {
        if let url = dataManager.jsonURL {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func reloadJSON() {
        dataManager.loadJSON()
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc func openSettings() {
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            return
        }
        
        let settingsView = SettingsView(dataManager: dataManager)
        let hostingController = NSHostingController(rootView: settingsView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered, defer: false
        )
        window.title = "Cheatsheet Settings"
        window.contentViewController = hostingController
        window.center()
        
        // ウィンドウが閉じられたら変数を空にする処理
        window.isReleasedWhenClosed = false
        
        self.settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true) // アプリをアクティブにする
    }
}
