//
//  SettingsView.swift
//  mycheatsheet
//
//  Created by Yoshio Satomi  on 2025/11/30.
//


import SwiftUI

struct SettingsView: View {
    @ObservedObject var dataManager: DataManager
    @State private var selectedAppId: String?
    @State private var newAppId: String = ""
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedAppId) {
                Section(header: Text("Apps")) {
                    ForEach(Array(dataManager.allShortcuts.keys.sorted()), id: \.self) { key in
                        Text(key).tag(key)
                    }
                }
                
                Section(header: Text("Add New App ID")) {
                    HStack {
                        TextField("com.example.app", text: $newAppId)
                        Button("Add") {
                            if !newAppId.isEmpty {
                                dataManager.addApp(id: newAppId)
                                selectedAppId = newAppId
                                newAppId = ""
                            }
                        }
                        .disabled(newAppId.isEmpty)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min:200, ideal: 250)
        } detail: {
            if let appId = selectedAppId, let shortcuts = dataManager.allShortcuts[appId] {
                ShortcutEditorList(appId: appId, shortcuts: shortcuts, dataManager: dataManager)
            } else {
                Text("Select an app to edit")
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 700, height: 400)
    }
}

struct ShortcutEditorList: View {
    let appId: String
    let shortcuts: [ShortcutItem]
    @ObservedObject var dataManager: DataManager
    
    @State private var newTitle = ""
    @State private var newKeys = ""
    
    var body: some View {
        VStack {
            Text("Editing: \(appId)")
                .font(.headline)
                .padding()
            
            List {
                ForEach(shortcuts) { item in
                    HStack {
                        Text(item.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Divider()
                        Text(item.keys)
                            .frame(width: 100, alignment: .trailing)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete { indexSet in
                    dataManager.deleteShortcut(at: indexSet, in: appId)
                }
            }
            
            Divider()
            
            HStack {
                TextField("Title (e.g. Save)", text: $newTitle)
                TextField("Keys (e.g. ⌘S", text: $newKeys)
                    .frame(width: 100)
                
                Button("Add") {
                    if !newTitle.isEmpty, !newKeys.isEmpty {
                        dataManager.addShortcut(to: appId, title: newTitle, keys: newKeys)
                        newTitle = ""
                        newKeys = ""
                    }
                }
                .disabled(newTitle.isEmpty || newKeys.isEmpty)
            }
            .padding()
        }
    }
}
