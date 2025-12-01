//
//  CheatsheetView.swift
//  mycheatsheet
//
//  Created by Yoshio Satomi  on 2025/11/30.
//
import SwiftUI

struct CheatsheetRootView: View {
    @ObservedObject var keyMonitor: KeyboardMonitor
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        CheatsheetView(
            shortcuts: dataManager.allShortcuts[keyMonitor.activeAppId] ?? dataManager.allShortcuts["default"] ?? []
        )
        .background(Color.black.opacity(0.85))
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding(20)
    }
}

struct CheatsheetView: View {
    let shortcuts: [ShortcutItem]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Cheatsheet")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
            
            if shortcuts.isEmpty {
                Text("No shortcuts set")
                    .foregroundColor(.gray)
            } else {
                ForEach(shortcuts) { item in
                    ShortcutRow(title: item.title, keys: item.keys)
                }
            }
        }
        .padding(30)
        .frame(width: 350) // 幅を固定
    }
}

// 行のデザインをコンポーネント化
struct ShortcutRow: View {
    let title: String
    let keys: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(Color.white.opacity(0.8))
                .font(.system(size: 14))
            Spacer()
            Text(keys)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.yellow)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.1))
                .cornerRadius(6)
        }
    }
}
