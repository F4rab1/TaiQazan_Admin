//
//  ProductModel.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 10.04.2024.
//

import Foundation

struct Product: Decodable {
    let id: String?
    let name: String?
    let price: Int?
    let brand: String?
    let description: String?
    let imageLink: String?
}
