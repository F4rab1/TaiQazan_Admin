//
//  OrderViewController.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 18.02.2024.
//

import UIKit
import FirebaseFirestore

class OrderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var orders: [Order] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.register(OrderCell.self, forCellReuseIdentifier: "Order")
        
        return tableView
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Created", "Collecting", "Collected", "Delivering", "Delivered"])
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = UIColor.rgb(red: 56, green: 182, blue: 255)
        
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        setupUI()
        setDelegates()
        setupConstraints()
        fetchOrders()
    }
    
    private func fetchOrders() {
        OrderService.shared.fetchOrders { orders, error in
            if let error = error {
                print("Failed to fetch orders:", error)
                return
            }
            
            self.orders = orders
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
    }
    
    private func setDelegates() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupConstraints() {
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom)
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        // Fetch orders based on selected segment
        fetchOrders()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(orders.count)
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Order", for: indexPath) as! OrderCell
        let order = orders[indexPath.item]
        cell.configure(with: order.id, status: order.status)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderDescriptionVC = OrderDescriptionViewController()
        let order = orders[indexPath.item]
        orderDescriptionVC.title = order.id
        navigationController?.pushViewController(orderDescriptionVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
