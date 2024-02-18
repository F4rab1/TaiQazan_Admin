//
//  OrderViewController.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 18.02.2024.
//

import UIKit
import FirebaseFirestore

class OrderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var orderIDs: [String] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(OrderCell.self, forCellReuseIdentifier: "Order")
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setDelegates()
        setupConstraints()
        fetchOrderIDs()
    }
    
    private func fetchOrderIDs() {
        let db = Firestore.firestore()
        let ordersRef = db.collection("orders")
        
        ordersRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            
            guard let snapshot = snapshot else {
                print("Snapshot is nil")
                return
            }
            
            for document in snapshot.documents {
                self.orderIDs.append(document.documentID)
            }
            self.tableView.reloadData()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
    }
    
    private func setDelegates() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Order", for: indexPath) as! OrderCell
        cell.configure(with: orderIDs[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderDescriptionVC = OrderDescriptionViewController()
        orderDescriptionVC.title = orderIDs[indexPath.row]
        navigationController?.pushViewController(orderDescriptionVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
