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

// TODO: Remove shared note
final class SharedNote {
    static let shared = SharedNote()
    private(set) var note: Note?
    private let noteSvc = ServiceLocator.Application.noteService()
    
    func save() {
        guard let note = note else { return }
        checkImages()
        
        noteSvc.save(note: note) { (result) in
            print(result)
        }
    }
    
    func checkImages() {
        note?.assets.forEach({ (key, _) in
            if self.note?.body?.range(of: key) == nil {
                note?.assets.removeValue(forKey: key)
            }
        })
    }
    
    func get(onexists: @escaping (Note) -> (), onabsent: @escaping () -> ()) {
        noteSvc.get { result in
            if case .success(let someNote) = result {
                if let theNote = someNote {
                    onexists(theNote)
                } else {
                    onabsent()
                }
            }
        }
    }
    
    func delete(completion: @escaping () -> ()) {
        noteSvc.delete(completion: { _ in
            completion()
        })
    }
    
    func title(set title: String) {
        note?.title = title
    }
    
    func body(set txt: String) {
        note?.body = txt
    }
    
    func tags(set tags: [String]) {
        note?.tags = tags
    }
    
    func create(with someNote: Note?) {
        note = someNote ?? Note()
    }
    
    var validQ: Bool {
        let emptyTitleQ = (note?.title ?? "").isEmpty
        let emptyBodyQ = (note?.body ?? "").isEmpty
        let emptyTagsQ = note?.tags.isEmpty
        
        return (emptyTitleQ == false) && (emptyBodyQ == false) && (emptyTagsQ == false)
    }
}
