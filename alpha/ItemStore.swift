//
//  ItemStore.swift
//  alpha
//
//  Created by Christophe Vichery on 9/30/26.
//

import Foundation

actor ItemStore {
    private let fileURL:URL
    
    init(fileURL: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "items.json")){
        self.fileURL =  fileURL
    }
    
    func save(items: [Item]) throws {
        let data = try JSONEncoder().encode(items)
        try data.write(to: fileURL, options: .atomic)
    }
    
    func load() throws -> [Item] {
        let data = try Data(contentsOf: fileURL)
        let items = try JSONDecoder().decode([Item].self, from: data)
        return items
    }
}
