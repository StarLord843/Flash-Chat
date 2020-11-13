//
//  RegisterViewController.swift
//  Flash Chat iOS13
//
//  Created by Kaushal on 21/10/2019.
//  Copyright © 2019 Kaushal Kumar. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var nameTextfield: UITextField!
    
    let db = Firestore.firestore()
    var email: String = ""
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text, let name = nameTextfield.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    self.db.collection(K.FStore.credentialsCollectionName).addDocument(data: [
                        K.FStore.emailField: email,
                        K.FStore.nameField: name
                    ]) { (error) in
                        if let e = error {
                            print("Error while registering, \(e).")
                        } else {
                            print("Successfully saved the user data.")
                        }
                    }
                    self.email = email
                    self.performSegue(withIdentifier: K.registerSegue, sender: self)
                }
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! PersonalChatViewController
        destinationVC.userEmail = email
    }
    
}
