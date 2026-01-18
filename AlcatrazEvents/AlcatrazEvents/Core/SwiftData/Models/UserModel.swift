//
//  UserModel.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

import SwiftData

@Model
final class UserModel {
    @Attribute(.unique) var id: String
    var name: String
    var email: String

    init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}
