//
//  ShortcutItem.swift
//  mycheatsheet
//
//  Created by Yoshio Satomi  on 2025/11/30.
//
import Foundation

struct ShortcutItem: Codable, Identifiable {
    var id = UUID()
    let title: String
    let keys: String
    
    enum CodingKeys: String, CodingKey {
        case title, keys
    }
}
