//
//  NoteService.swift
//  Platform
//
//  Created by Siarhei Suliukou on 3/13/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

public protocol NoteService {
    func save(note: Note, completion: @escaping (Result<Note>) -> ())
    func get(completion: @escaping (Result<Note?>) -> ())
    func delete(completion: @escaping (Result<Note?>) -> ())
}

public struct SteemitNoteService {
    private let udsvc = UserDefaultsStorageService()
}

extension SteemitNoteService: NoteService {
    public func save(note: Note, completion: @escaping (Result<Note>) -> ()) {
        udsvc.save(value: note, key: Config.Storage.Keys.sharednote, completion: completion)
    }
    
    public func get(completion: @escaping (Result<Note?>) -> ()) {
        udsvc.get(key: Config.Storage.Keys.sharednote, completion: completion)
    }
    
    public func delete(completion: @escaping (Result<Note?>) -> ()) {
        udsvc.delete(key: Config.Storage.Keys.sharednote, completion: completion)
    }
}
