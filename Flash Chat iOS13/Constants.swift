//
//  Constants.swift
//  Flash Chat iOS13
//
//  Created by Kaushal on 12/11/20.
//  Copyright © 2020 Kaushal Kumar. All rights reserved.
//

struct K {
    static let appName = "⚡️FlashChat"
    static let cellIdentifier = "ReusableCell"
    static let cellNibName = "MessageCell"
    static let registerSegue = "RegisterToChat"
    static let loginSegue = "LoginToChat"
    static let personalChat = "PersonelChat"
    
    struct BrandColors {
        static let purple = "BrandPurple"
        static let lightPurple = "BrandLightPurple"
        static let blue = "BrandBlue"
        static let lighBlue = "BrandLightBlue"
    }
    
    struct FStore {
        static let messageCollectionName = "messages"
        static let credentialsCollectionName = "details"
        static let emailField = "email"
        static let nameField = "name"
        static let textField = "text"
        static let dateField = "date"
        static let receiverField = "receiver"
    }
}
