//
//  User.swift
//  trafie
//
//  Created by mathiou on 5/16/15.
//  Copyright (c) 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation

class User {
    //variables
    let firstname: String
    let lastname: String
    let about: String
    let gender: String
    let mainDiscipline: String
    let profileIsPrivate: Bool
    let birthday: String //needs upgrade to proper type

    
    //init function
    init() {
        self.firstname = ""
        self.lastname = ""
        self.about = ""
        self.gender = ""
        self.mainDiscipline = ""
        self.profileIsPrivate = true
        self.birthday = ""
    }
}