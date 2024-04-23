//
//  MainController.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 10.04.2024.
//

import UIKit
import FirebaseAuth

class MainCollectionController: BaseListController, UISearchBarDelegate, UICollectionViewDelegateFlowLayout, DiscountsHeaderHorizontalDelegate {
    
    var productResults = [Product]()
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    private let refreshController = UIRefreshControl()
    let headerId = "discountsId"
    
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
        collectionView.backgroundColor = ColorManager.mainBGColor
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.identifier)
        collectionView.register(DiscountsPageHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView.refreshControl = refreshController
        refreshController.addTarget(self, action: #selector(refreshProductData(_:)), for: .valueChanged)
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
        
        setupUI()
        setupConstraints()
        setupSearchBar()
        fetchProducts()
    }
    
    func setupUI() {
        view.addSubview(enterSearchTermLabel)
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
                    self.collectionView.reloadData()
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
                self.collectionView.reloadData()
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
                self.collectionView.reloadData()
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

extension MainCollectionController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId, for: indexPath) as! DiscountsPageHeader
        header.discountsHeaderHorizontalController.delegate = self
        
        return header
    }
    
    func didSelectImage(withPicker picker: UIImagePickerController) {
        present(picker, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        enterSearchTermLabel.isHidden = productResults.count != 0
        return productResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCell.identifier, for: indexPath) as! ProductCell
        
        let productResult = productResults[indexPath.item]
        cell.nameLabel.text = productResult.name
        cell.brandLabel.text = productResult.brand
        cell.priceLabel.text = "\(productResult.price ?? 0) ₸"
        if let url = URL(string: productResult.imageLink ?? "") {
            cell.productImageView.sd_setImage(with: url)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProduct = productResults[indexPath.item]
        
        let vc = ProductDetailController()
        vc.selectedProduct = selectedProduct
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 120)
    }
}
