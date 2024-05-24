//
//  OrderModel.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 18.05.2024.
//

import Foundation
import FirebaseFirestore

struct Order: Decodable {
    let id: String
    let address: Address
    let createdDate: Date
    var formattedCreatedDate: String? 
    let orderContact: OrderContact
    let paymentType: Int?
    let products: [ProductModel]
    var status: Int
    let totalPrice: Int
    let userID: String
    
    enum CodingKeys: String, CodingKey {
        case id, address, createdDate, orderContact, paymentType, products, status, totalPrice, userID
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        address = try container.decode(Address.self, forKey: .address)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        orderContact = try container.decode(OrderContact.self, forKey: .orderContact)
        paymentType = try container.decode(Int.self, forKey: .paymentType)
        products = try container.decode([ProductModel].self, forKey: .products)
        status = try container.decode(Int.self, forKey: .status)
        totalPrice = try container.decode(Int.self, forKey: .totalPrice)
        userID = try container.decode(String.self, forKey: .userID)
    }
}

struct Address: Decodable {
    let apartment: String
    let city: String
    let comment: String
    let entrance: String
    let floor: String
    let phoneNumber: String
    let street: String
}

struct OrderContact: Decodable {
    let advice: String
    let comment: String
    let name: String
}

struct ProductModel: Decodable {
    let count: Int
    let id: String
}
