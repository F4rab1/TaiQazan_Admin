//
//  ChatFirebaseService.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 08.04.2024.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit

class ChatViewModel {
    
    static let shared = ChatViewModel()
    
    var messages = [MockMessage]()
    
    func getDataFromFirbase(currentUser: MockUser, chatID: Int, completion: @escaping () -> Void) {
        ChatFirebaseService.shared.observeMessages(forSenderId: currentUser.senderId, chatID: chatID) { [weak self] result in
            switch result {
            case .success(let messages):
                self?.messages = messages
                completion()
            case .failure(let error):
                print("Error observing messages: \(error)")
            }
        }
    }
}


class ChatFirebaseService {
    
    static let shared = ChatFirebaseService()
    
    func getAllUsers(completion: @escaping([String]) -> (Void)) {
        let collectionReference = Database.database().reference().child("supportMessages")
        
        collectionReference.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                let keys = snapshot.children.allObjects.compactMap { ($0 as? DataSnapshot)?.key }
                completion(keys)
            } else {
                print("Collection is empty or does not exist.")
            }
        }
    }
    
    func saveMessageToFirebase(_ message: MockMessage) {
        var messageData: [String: Any] = [
            "senderId": message.sender.senderId,
            "displayName": message.sender.displayName,
            "messageId": message.messageId,
            "sentDate": ServerValue.timestamp(),
            "isManager": message.isManager,
            "isSeen": false,
        ]
        
        switch message.kind {
        case .text(let text):
            messageData["text"] = text
            self.saveMessage(messageData: messageData)
        case .photo(let mediaItem):
            if let imageData = mediaItem.image?.jpegData(compressionQuality: 0.8)    {
                let storageRef = Storage.storage().reference().child("messageImages/\(UUID().uuidString).jpg")
                storageRef.putData(imageData, metadata: nil) { (_, error) in
                    if let error = error {
                        print("Error saving image to Firebase: \(error.localizedDescription)")
                    } else {
                        storageRef.downloadURL { (url, _) in
                            if let url = url {
                                messageData["imageURL"] = url.absoluteString
                                // Save the message data to Firebase Realtime Database
                                self.saveMessage(messageData: messageData)
                            }
                        }
                    }
                }
                
            }
        case .custom(let data):
            let storageRef = Storage.storage().reference().child("messageFiles/\(UUID().uuidString).pdf")
            storageRef.putData(data as! Data, metadata: nil) { (_, error) in
                if let error = error {
                    print("Error saving data to Firebase: \(error.localizedDescription)")
                } else {
                    storageRef.downloadURL { (url, _) in
                        if let url = url {
                            messageData["fileURL"] = url.absoluteString
                            self.saveMessage(messageData: messageData)
                        }
                    }
                }
            }
        default:
            fatalError("error with saving message")
        }
    }
    
    private func saveMessage(messageData: [String: Any]) {
        let senderMessagesRef =  Database.database().reference().child("supportMessages").child(messageData["senderId"] as! String)
        senderMessagesRef.child(messageData["messageId"] as! String).setValue(messageData) { (error, _) in
            if let error = error {
                print("Error saving message to Firebase: \(error.localizedDescription)")
            } else {
                print("Message saved successfully!")
            }
        }
        
        senderMessagesRef.child("isCompleted").setValue(false)
    }
    
    
    func observeMessages(forSenderId senderId: String, chatID: Int, completion: @escaping (Swift.Result<[MockMessage], Error>) -> Void) {
        let senderMessagesRef = Database.database().reference().child("supportMessages")
        senderMessagesRef.child(senderId).observe(.value) { [weak self] (snapshot) in
            var messages: [MockMessage] = []
            
            for child in snapshot.children.allObjects {
                if let childSnapshot = child as? DataSnapshot, let messageData = childSnapshot.value as? [String: Any] {
                    self?.createMessage(from: messageData) { result in
                        switch result {
                        case .success(let message):
                            if let message = message {
                                messages.append(message)
                                
                            }
                        case .failure(let error):
                            print("Error creating message: \(error)")
                        }
                    }
                    
                    if var userDidSee = messageData["userDidSee"] as? Bool, !userDidSee {
                        userDidSee = true
                        childSnapshot.ref.updateChildValues(["userDidSee": userDidSee])
                    }
                }
            }
            completion(.success(messages.sorted { $0.sentDate < $1.sentDate }))
        }
    }
    
    
    // Helper method to create a MockMessage from data
    private func createMessage(from data: [String: Any], completion: @escaping (Swift.Result<MockMessage?, Error>) -> Void) {
        guard let senderId = data["senderId"] as? String,
              let displayName = data["displayName"] as? String,
              let messageId = data["messageId"] as? String,
              let sentDateTimestamp = data["sentDate"] as? Double,
              let isManager = data["isManager"] as? Bool else
        {
            completion(.failure(NSError(domain: "Invalid message data", code: 0, userInfo: nil)))
            return
        }
        
        let sentDate = Date(timeIntervalSince1970: sentDateTimestamp / 1000)
        
        if let image = data["imageURL"] as? String, let imageURL = URL(string: image) {
            let message = MockMessage(
                imageURL: imageURL,
                user: MockUser(
                    senderId: !isManager ? "Manager1" : senderId,
                    displayName: !isManager ? "Клиент" : displayName
                ),
                messageId: messageId,
                date: sentDate,
                isManager: !isManager
            )
            
            completion(.success(message))
            
        } else if let text = data["text"] as? String {
            let message = MockMessage(
                text: text,
                user: MockUser(
                    senderId: !isManager ? "Manager1" : senderId,
                    displayName: !isManager ? "Клиент" : displayName
                ),
                messageId: messageId,
                date: sentDate,
                isManager: !isManager
            )
            
            completion(.success(message))
            
        } else if let _ = data["fileURL"] as? String {
            let message = MockMessage(
                emoji: "📄",
                user: MockUser(
                    senderId: !isManager ? "Manager1" : senderId,
                    displayName: !isManager ? "Клиент" : displayName
                ),
                messageId: messageId,
                date: sentDate,
                isManager: !isManager
            )
            
            completion(.success(message))
        }
        
        else {
            completion(.failure(NSError(domain: "Invalid message data", code: 0, userInfo: nil)))
        }
    }
    
    func getManagerMessageCount(forSenderId senderId: String, completion: @escaping (Int) -> Void) {
        let senderMessagesRef = Database.database().reference().child("messages").child(senderId)
        let query = senderMessagesRef.queryOrdered(byChild: "userDidSee").queryEqual(toValue: false)
        query.observe(.value) { snapshot in
            completion(Int(snapshot.childrenCount))
        }
    }
    
    func getSupportMessageCount(forSenderId senderId: String, completion: @escaping (Int) -> Void) {
        let senderMessagesRef = Database.database().reference().child("supportMessages").child(senderId)
        let query = senderMessagesRef.queryOrdered(byChild: "userDidSee").queryEqual(toValue: false)
        query.observe(.value) { snapshot in
            completion(Int(snapshot.childrenCount))
        }
    }
    
    //    func getAvatar(completion: @escaping (UIImage?) -> Void) {
    //        profileVM.getProfileData { profileData in
    //            if let photoLink = profileData?.photoLink, let url = URL(string: photoLink) {
    //                URLSession.shared.dataTask(with: url) { (data, response, error) in
    //                    if let error = error {
    //                        print("Error fetching image data: \(error)")
    //                    } else if let data = data, let image = UIImage(data: data) {
    //                        DispatchQueue.main.async {
    //                            completion(image)
    //                        }
    //                    }
    //                }.resume()
    //            }
    //        }
    //    }
    
}
