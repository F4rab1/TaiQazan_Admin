//
//  OrderDescriptionViewController.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 18.02.2024.
//

import UIKit

class OrderDescriptionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var selectedOrder: Order? {
        didSet {
            guard let order = selectedOrder else { return }
            addressLabel.text = "Address:  \(order.address.city) - \(order.address.street), apartment \(order.address.apartment), entrance  \(order.address.entrance), floor \(order.address.floor)"
            createdDateLabel.text = "\(order.formattedCreatedDate ?? "")"
            totalPriceLabel.text = "Total price:  \(order.totalPrice)₸"
        }
    }
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Address: "
        label.font = .systemFont(ofSize: 18)
        
        return label
    }()
    
    let createdDateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 18)
        
        return label
    }()
    
    let totalPriceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Total price: "
        label.font = .boldSystemFont(ofSize: 22)
        
        return label
    }()
    
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
        view.addSubview(createdDateLabel)
        view.addSubview(addressLabel)
        view.addSubview(productsTableView)
        view.addSubview(totalPriceLabel)
    }
    
    private func setDelegates() {
        productsTableView.dataSource = self
        productsTableView.delegate = self
    }
    
    private func setupConstraints() {
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-10)
        }
        
        createdDateLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        
        totalPriceLabel.snp.makeConstraints { make in
            make.top.equalTo(createdDateLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        
        productsTableView.snp.makeConstraints { make in
            make.top.equalTo(totalPriceLabel.snp.bottom).offset(10)
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
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
