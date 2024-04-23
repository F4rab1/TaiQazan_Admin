//
//  DiscountsFirebaseService.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 23.04.2024.
//

import Firebase
import FirebaseDatabase
import FirebaseStorage

class DiscountsService {
    static let shared = DiscountsService()
    
    let db = Firestore.firestore()
    var discounts: [Discount] = []
    
    func updateDiscount(discountId: Int,image: UIImage, completion: @escaping ([Discount], Error?) -> Void) {
        guard let uploadData = image.jpegData(compressionQuality: 0.1) else { return }
        
        let filename = NSUUID().uuidString
        
        let storageRef = Storage.storage().reference().child("discountImages").child(filename)
        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
            
            if let err = err {
                print("Failed to upload discount image:", err)
                completion([], err)
                return
            }
            
            storageRef.downloadURL(completion: { (downloadURL, err) in
                if let err = err {
                    print("Failed to fetch downloadURL:", err)
                    completion([], err)
                    return
                }
                
                guard let discountImageURL = downloadURL?.absoluteString else { return }
                
                print("Successfully uploaded discount image:", discountImageURL)
                
                let collectionRef = self.db.collection("discounts")
                let query = collectionRef.whereField("id", isEqualTo: String(discountId))
                
                query.getDocuments { (querySnapshot, error) in
                    
                    if let error = error {
                        print("Error fetching documents: \(error)")
                        completion([], error)
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        print("No documents found")
                        return
                    }
                    
                    for document in documents {
                        document.reference.setData([
                            "id": String(discountId),
                            "imageLink": discountImageURL
                        ], merge: true) { error in
                            if let error = error {
                                print("Error updating document: \(error)")
                                completion([], error)
                            } else {
                                print("Document successfully updated")
                                completion([], nil)
                            }
                        }
                    }
                }
            })
        })
    }
    
}
