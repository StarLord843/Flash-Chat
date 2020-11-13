//
//  PersonalChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Kaushal on 11/11/20.
//  Copyright © 2020 Kaushal Kumar. All rights reserved.
//

import UIKit
import Firebase

class PersonalChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var users: [User] = []
    let db = Firestore.firestore()
    var person: String = ""
    var userEmail: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        tableView.rowHeight = 70
        tableView.dataSource = self
        tableView.delegate = self
        loadChats()
    }
    
    func loadChats() {
        users = []
        db.collection(K.FStore.credentialsCollectionName).getDocuments { (querySnapshot, error) in
            if let e = error {
                print("There was an issue retrieving data from firestore. \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let messageSender = data[K.FStore.nameField] as? String, let messageEmail = data[K.FStore.emailField] as? String {
                            if messageEmail != self.userEmail {
                                let newUser = User(email: messageEmail, name: messageSender)
                                self.users.append(newUser)
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
}

extension PersonalChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }
    
}

extension PersonalChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        person = users[indexPath.row].name
        performSegue(withIdentifier: K.personalChat, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ChatViewController
        destinationVC.sender = person
        destinationVC.userEmail = userEmail
    }
}
