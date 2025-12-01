//
//  DataManager.swift
//  mycheatsheet
//
//  Created by Yoshio Satomi  on 2025/11/30.
//
import Foundation
import Combine
import SwiftUI

class DataManager: ObservableObject {
    @Published var allShortcuts: [String: [ShortcutItem]] = [:]
    
    var jsonURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent("cheatsheet.json")
    }
    
    init() {
        loadJSON()
    }
    
    func loadJSON() {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsURL.appendingPathComponent("cheatsheet.json")
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decodedData = try JSONDecoder().decode([String: [ShortcutItem]].self, from: data)
            self.allShortcuts = decodedData
            print("JSON Loaded Successfully!")
        } catch {
            print("JSON Load Error: \(error)")
            self.allShortcuts = ["default": [ShortcutItem(title: "Load Error", keys: "Check JSON")]]
        }
    }
    
    func saveJSON() {
        guard let url = jsonURL else { return }
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(allShortcuts)
            try data.write(to: url)
            print("Saved Successfully!")
        } catch {
            print("Save Error: \(error)")
        }
    }
    
    func addApp(id: String) {
        if allShortcuts[id] == nil {
            allShortcuts[id] = []
            saveJSON()
        }
    }
    
    func addShortcut(to appId: String, title: String, keys: String) {
        let newItem = ShortcutItem(title: title, keys: keys)
        allShortcuts[appId]?.append(newItem)
        saveJSON()
    }
    
    func deleteShortcut(at offsets: IndexSet, in appId: String) {
        allShortcuts[appId]?.remove(atOffsets: offsets)
        saveJSON()
    }
}
