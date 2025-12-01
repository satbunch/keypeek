//
//  mycheatsheetApp.swift
//  mycheatsheet
//
//  Created by Yoshio Satomi  on 2025/11/28.
//

import SwiftUI

@main
struct keypeakApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
