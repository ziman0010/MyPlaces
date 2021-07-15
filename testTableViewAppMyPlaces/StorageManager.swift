//
//  StorageManager.swift
//  testTableViewAppMyPlaces
//
//  Created by Алексей Черанёв on 15.07.2021.
//

import RealmSwift

let realm =  try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
}
