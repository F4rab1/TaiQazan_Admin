//
//  OrderProductController.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 19.05.2024.
//

import UIKit
import SnapKit
import SDWebImage

class OrderProductDetailController: UIViewController {
    
    var selectedProduct: Product? {
        didSet {
            if let product = selectedProduct {
                nameTextField.text = product.name
                priceTextField.text = "\(product.price ?? 0) ₸"
                brandTextField.text = product.brand
                descriptionTextField.text = product.description
                if let url = URL(string: product.imageLink ?? "") {
                    productImageButton.sd_setImage(with: url, for: .normal)
                }
            }
        }
    }
    
    private let productImageButton: UIButton = {
        let button = UIButton()
        button.imageView?.contentMode = .scaleToFill
        button.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 0.1)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
        button.contentMode = .scaleAspectFill
        
        return button
    }()
    
    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Product name"
        tf.layer.borderColor = UIColor.rgb(red: 56, green: 182, blue: 255).cgColor
        tf.layer.borderWidth = 1.5
        tf.layer.cornerRadius = 8.0
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: tf.frame.size.height))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        return tf
    }()
    
    private let priceTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Product price"
        tf.layer.borderColor = UIColor.rgb(red: 56, green: 182, blue: 255).cgColor
        tf.layer.borderWidth = 1.5
        tf.layer.cornerRadius = 8.0
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: tf.frame.size.height))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        return tf
    }()
    
    private let brandTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Product brand"
        tf.layer.borderColor = UIColor.rgb(red: 56, green: 182, blue: 255).cgColor
        tf.layer.borderWidth = 1.5
        tf.layer.cornerRadius = 8.0
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: tf.frame.size.height))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        return tf
    }()
    
    private let descriptionTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Product description"
        tf.layer.borderColor = UIColor.rgb(red: 56, green: 182, blue: 255).cgColor
        tf.layer.borderWidth = 1.5
        tf.layer.cornerRadius = 8.0
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: tf.frame.size.height))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        
        return tf
    }()
    
    private lazy var mainStackView = CustomStackView(axis: .vertical, arrangedSubviews: [nameTextField, priceTextField, brandTextField, descriptionTextField], spacing: 10, alignment: .fill)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        [productImageButton, mainStackView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        productImageButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(productImageButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        [nameTextField, priceTextField, brandTextField, descriptionTextField].forEach { make in
            make.snp.makeConstraints { $0.height.equalTo(50)}
        }
    }
    
}
