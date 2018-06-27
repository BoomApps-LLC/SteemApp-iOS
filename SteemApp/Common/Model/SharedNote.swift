//
//  SharedNote.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 2/7/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation
import Photos
import Platform

final class Note {
    static let shared = Note()
    private(set) var sharedNote: SomeNote = SomeNote()
    //private let svc = ServiceLocator.Application.Note
    
    func save() {
        
    }
    
    func title(set title: String) {
        sharedNote.title = title
    }
    
    func body(set txt: String) {
        sharedNote.body = txt
    }
    
    func tags(set tags: [String]) {
        sharedNote.tags = tags
    }
    
    func create() {
        sharedNote = SomeNote()
    }
    
    var validQ: Bool {
        let emptyTitleQ = (sharedNote.title ?? "").isEmpty
        let emptyBodyQ = (sharedNote.body ?? "").isEmpty
        let emptyTagsQ = sharedNote.tags.isEmpty
        
        return (emptyTitleQ == false) && (emptyBodyQ == false) && (emptyTagsQ == false)
    }
}
