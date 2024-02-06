//
//  ViewController.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 06.02.2024.
//

import UIKit
import SnapKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    private let productImageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Product name"
        tf.borderStyle = .roundedRect
        
        return tf
    }()
    
    private let priceTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Product price"
        tf.borderStyle = .roundedRect
        
        return tf
    }()
    
    private let brandTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Product brand"
        tf.borderStyle = .roundedRect
        
        return tf
    }()
    
    private let descriptionTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Product description"
        tf.borderStyle = .roundedRect
        
        return tf
    }()
    
    private lazy var mainStackView = CustomStackView(axis: .vertical, arrangedSubviews: [nameTextField, priceTextField, brandTextField, descriptionTextField], spacing: 10, alignment: .fill)
    
    private let addProductButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add product", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add product"
        nameTextField.delegate = self
        priceTextField.delegate = self
        brandTextField.delegate = self
        descriptionTextField.delegate = self
        
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        productImageButton.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        addProductButton.addTarget(self, action: #selector(addProductButtonTapped), for: .touchUpInside)
        
        [productImageButton, mainStackView, addProductButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        productImageButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(productImageButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        addProductButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        [nameTextField, priceTextField, brandTextField, descriptionTextField].forEach { make in
            make.snp.makeConstraints { $0.height.equalTo(50)}
        }
    }
    
    @objc func addProductButtonTapped() {
        guard
            let nameText = nameTextField.text,
            let priceText = priceTextField.text,
            let brandText = brandTextField.text,
            let descriptionText = descriptionTextField.text,
            nameText.count > 0,
            priceText.count > 0,
            brandText.count > 0,
            descriptionText.count > 0,
            productImageButton.currentImage != UIImage(named: "plus_photo")
        else {
            
            let alert = UIAlertController(title: "Not all fields are filled in", message: "Fill in all the fields", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            present(alert, animated: true)

            return
        }

        dismiss(animated: true)
    }
    
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            productImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}

