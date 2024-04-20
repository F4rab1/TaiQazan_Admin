//
//  ProductsFirebaseService.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 10.04.2024.
//

import Firebase
import FirebaseDatabase

class ProductService {
    static let shared = ProductService()
    
    let db = Firestore.firestore()
    var products: [Product] = []
    
    func fetchProducts(completion: @escaping ([Product], Error?) -> Void) {
        let collectionRef = db.collection("products")
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
            
            self.products = []
            
            for document in documents {
                do {
                    let data = document.data()
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let product = try JSONDecoder().decode(Product.self, from: jsonData)
                    self.products.append(product)
                } catch {
                    print("Error decoding product: \(error)")
                }
            }
            
            completion(self.products, nil)
        }
    }
    
    func fetchProductsWithSearchTerm(searchTerm: String, completion: @escaping ([Product], Error?) -> Void) {
        var filteredProducts: [Product] = []
        
        for product in products {
            if let name = product.name?.lowercased(), name.contains(searchTerm.lowercased()){
                filteredProducts.append(product)
            }
        }
        
        completion(filteredProducts, nil)
    }
    
    func deleteProduct(withId productId: String, completion: @escaping (Error?) -> Void) {
        let collectionRef = db.collection("products")
        
        collectionRef.whereField("id", isEqualTo: productId).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error querying product for deletion: \(error)")
                completion(error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found for deletion")
                completion(nil)
                return
            }
            
            if let document = documents.first {
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting product: \(error)")
                        completion(error)
                    } else {
                        print("Product deleted successfully")
                        completion(nil)
                    }
                }
            } else {
                print("Product not found for deletion")
                completion(nil)
            }
        }
    }
}
