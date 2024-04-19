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
}
