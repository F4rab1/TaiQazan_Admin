//
//  MainController.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 10.04.2024.
//

import UIKit
import FirebaseAuth

class MainTableController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.backgroundColor = ColorManager.mainBGColor
        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.identifier)
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
        
        fetchProducts()
    }
    
    fileprivate var productResults = [Product]()
    
    fileprivate func fetchProducts() {
        ProductService.shared.fetchProducts { (products, error) in
            if let error = error {
                print("Failed to fetch products:", error)
                return
            }
            
            self.productResults = products
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func addButtonTapped() {
        let vc = AddProductController()
        vc.title = "New Product"
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Products"
        tabBarController?.tabBar.isHidden = false
    }
}

extension MainTableController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductCell.identifier, for: indexPath) as! ProductCell
        tableView.backgroundColor = .white
        
        let productResult = productResults[indexPath.item]
        cell.nameLabel.text = productResult.name
        cell.brandLabel.text = productResult.brand
        cell.priceLabel.text = "\(productResult.price ?? 0) ₸"
        if let url = URL(string: productResult.imageLink ?? "") {
            cell.productImageView.sd_setImage(with: url)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedProduct = productResults[indexPath.row]
        
        let vc = ProductDetailController()
        vc.selectedProduct = selectedProduct
        navigationController?.pushViewController(vc, animated: true)
    }
}


