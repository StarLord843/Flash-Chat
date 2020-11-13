//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    var sender: String = ""
    var userEmail: String = ""
    var userName: String = ""
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = sender
        tableView.dataSource = self
        messageTextfield.delegate = self
        
        // Register the custom Message Cell to the table view
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        getUserName()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadMessages()
    }
    
    func getUserName() {
        db.collection(K.FStore.credentialsCollectionName).getDocuments { (querySnapshot, error) in
            if let e = error {
                print("There was an issue retrieving data from firestore. \(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let email = data[K.FStore.emailField] as? String, let name = data[K.FStore.nameField] as? String {
                            if email == self.userEmail {
                                self.userName = name
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadMessages() {
        db.collection(K.FStore.messageCollectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { (querySnapshot, error) in
            self.messages = []
            if let e = error {
                print("There was an issue retrieving data from firestore. \(e).")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let messageSender = data[K.FStore.nameField] as? String,
                            let messageEmail = data[K.FStore.emailField] as? String,
                            let messageReceiver = data[K.FStore.receiverField] as? String,
                            let messageBody = data[K.FStore.textField] as? String {
                            
                            if (messageSender == self.sender && messageReceiver == self.userName) || (messageSender == self.userName && messageReceiver == self.sender) {
                                let newMessage = Message(email: messageEmail, sender: messageSender, receiver: messageReceiver, text: messageBody)
                                self.messages.append(newMessage)
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                }
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageText = messageTextfield.text, let messageEmail = Auth.auth().currentUser?.email {
            if messageText == "" {
                messageTextfield.placeholder = "Type Something"
                return
            }
            
            db.collection(K.FStore.messageCollectionName).addDocument(data: [
                K.FStore.emailField: messageEmail,
                K.FStore.nameField: userName,
                K.FStore.receiverField: self.sender,
                K.FStore.textField: messageText,
                K.FStore.dateField: Date().timeIntervalSince1970
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e).")
                } else {
                    print("Successfully saved the data.")
                    self.messageTextfield.text = ""
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

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = messages[indexPath.row].text
        if message.email == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        } else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        return cell
    }
    
    
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        messageTextfield.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

       if let messageText = messageTextfield.text, let messageEmail = Auth.auth().currentUser?.email {
            db.collection(K.FStore.messageCollectionName).addDocument(data: [
                K.FStore.emailField: messageEmail,
                K.FStore.nameField: userName,
                K.FStore.receiverField: self.sender,
                K.FStore.textField: messageText,
                K.FStore.dateField: Date().timeIntervalSince1970
            ]) { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e).")
                } else {
                    print("Successfully saved the data.")
                    self.messageTextfield.text = ""
                }
            }
        }
        

        textField.placeholder = "Write a message"
        messageTextfield.text = ""
    }
}
