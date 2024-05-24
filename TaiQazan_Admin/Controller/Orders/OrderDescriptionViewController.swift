//
//  OrderDescriptionViewController.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 18.02.2024.
//

import UIKit
import FirebaseFirestore

class OrderDescriptionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var selectedOrder: Order? {
        didSet {
            guard let order = selectedOrder else { return }
            addressLabel.text = "Address:  \(order.address.city) - \(order.address.street), apartment \(order.address.apartment), entrance  \(order.address.entrance), floor \(order.address.floor)"
            createdDateLabel.text = "\(order.formattedCreatedDate ?? "")"
            totalPriceLabel.text = "Total price:  \(order.totalPrice) ₸"
            paymentTypeLabel.text = "Payment method: \(paymentMethodText(for: order.paymentType ?? 3))"
        }
    }
    var pickerView: UIPickerView?
    
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
    
    let paymentTypeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Payment method: "
        label.font = .systemFont(ofSize: 18)
        
        return label
    }()
    
    private let productsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(OrderProductCell.self, forCellReuseIdentifier: "OrderProductCell")
        tableView.backgroundColor = UIColor.rgb(red: 240, green: 242, blue: 240)
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        
        return tableView
    }()
    
    let changeStatusButton: UIButton = {
        let button = UIButton()
        button.setTitle("Change status", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.rgb(red: 56, green: 182, blue: 255)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true

        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeStatusButton.addTarget(self, action: #selector(changeStatusButtonTapped), for: .touchUpInside)
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
        view.addSubview(changeStatusButton)
        view.addSubview(paymentTypeLabel)
    }
    
    private func setDelegates() {
        productsTableView.dataSource = self
        productsTableView.delegate = self
    }
    
    @objc func changeStatusButtonTapped() {
        guard let order = selectedOrder else { return }
        
        let newStatus = order.status + 1
        let db = Firestore.firestore()
        db.collection("orders").document(order.id).updateData(["status": newStatus]) { error in
            if let error = error {
                print("Failed to update status:", error)
                return
            }
            
            self.selectedOrder?.status = newStatus
            print("Order status updated successfully")
        }
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
        
        paymentTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(totalPriceLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        
        productsTableView.snp.makeConstraints { make in
            make.top.equalTo(paymentTypeLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(200)
        }
        
        changeStatusButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(48)
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

extension OrderDescriptionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedNumber = row + 1
        print("Selected number: \(selectedNumber)")
    }
}

func paymentMethodText(for paymentType: Int) -> String {
    switch paymentType {
    case 0:
        return "Apple Pay"
    case 1:
        return "Cash to courier"
    case 2:
        return "Card to the courier"
    default:
        return "Unknown"
    }
}
