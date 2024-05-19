//
//  OrdersFirebaseService.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 18.05.2024.
//

import Firebase
import FirebaseDatabase

class OrderService {
    static let shared = OrderService()
    
    let db = Firestore.firestore()
    var orders: [Order] = []
    
    func fetchOrders(by status: Int, completion: @escaping ([Order], Error?) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM dd, yyyy hh:mm a"
        
        let collectionRef = db.collection("orders").whereField("status", isEqualTo: status)
        collectionRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion([], error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                completion([], nil)
                return
            }
            
            self.orders = documents.compactMap { document in
                do {
                    var order = try document.data(as: Order.self)
                    if let timestamp = document.get("createdDate") as? Timestamp {
                        let dateString = formatter.string(from: timestamp.dateValue())
                        order.formattedCreatedDate = dateString
                    }
                    return order
                } catch {
                    print("Error decoding order: \(error)")
                    return nil
                }
            }
            
            completion(self.orders, nil)
        }
    }
}
