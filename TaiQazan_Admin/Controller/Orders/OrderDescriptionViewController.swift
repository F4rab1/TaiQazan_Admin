//
//  OrderDescriptionViewController.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 18.02.2024.
//

import UIKit

class OrderDescriptionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var selectedOrder: Order?
    
    private let productsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(OrderProductCell.self, forCellReuseIdentifier: "OrderProductCell")
        
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setDelegates()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(productsTableView)
    }
    
    private func setDelegates() {
        productsTableView.dataSource = self
        productsTableView.delegate = self
    }
    
    private func setupConstraints() {
        productsTableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedOrder?.products.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderProductCell", for: indexPath) as! OrderProductCell
        let rowNumber = indexPath.row
        let idOfProduct = selectedOrder?.products[rowNumber].id ?? "0"
        
        ProductService.shared.fetchProductWithId(id: idOfProduct) { product, error in
            if let error = error {
                print("Failed to fetch product:", error)
                return
            }

            if let product = product {
                DispatchQueue.main.async {
                    cell.product = product
                    cell.quantity = self.selectedOrder?.products[rowNumber].count
                }
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = OrderProductDetailController()
        let rowNumber = indexPath.row
        let idOfProduct = selectedOrder?.products[rowNumber].id ?? "0"
        
        ProductService.shared.fetchProductWithId(id: idOfProduct) { product, error in
            if let error = error {
                print("Failed to fetch product:", error)
                return
            }

            if let product = product {
                vc.selectedProduct = product
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
