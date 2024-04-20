//
//  MainController.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 10.04.2024.
//

import UIKit
import FirebaseAuth

class MainTableController: UITableViewController, UISearchBarDelegate{
    
    fileprivate var productResults = [Product]()
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    private let refreshController = UIRefreshControl()
    
    fileprivate let enterSearchTermLabel: UILabel = {
        let label = UILabel()
        label.text = "No Products found"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.backgroundColor = ColorManager.mainBGColor
        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.identifier)
        tableView.refreshControl = refreshController
        refreshControl?.addTarget(self, action: #selector(refreshProductData(_:)), for: .valueChanged)
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
        
        setupUI()
        setupConstraints()
        setupSearchBar()
        fetchProducts()
    }
    
    func setupUI() {
        tableView.addSubview(enterSearchTermLabel)
    }
    
    func setupConstraints() {
        enterSearchTermLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(30)
        }
    }
    
    fileprivate func setupSearchBar() {
        definesPresentationContext = true
        navigationItem.searchController = self.searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
    }
    
    var timer: Timer?
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (_) in
            ProductService.shared.fetchProductsWithSearchTerm(searchTerm: searchText) { (res, err) in
                self.productResults = res
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    @objc func refreshProductData(_ sender: Any) {
        ProductService.shared.fetchProducts { (products, error) in
            if let error = error {
                print("Failed to fetch products:", error)
                self.refreshController.endRefreshing()
                return
            }
            
            self.productResults = products
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshController.endRefreshing()
            }
        }
    }
    
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
        enterSearchTermLabel.isHidden = productResults.count != 0
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let productToDelete = productResults[indexPath.row]
            ProductService.shared.deleteProduct(withId: productToDelete.id ?? "") { error in
                if let error = error {
                    print("Error deleting product:", error)
                } else {
                    print("Product deleted successfully")
                    self.productResults.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
}
