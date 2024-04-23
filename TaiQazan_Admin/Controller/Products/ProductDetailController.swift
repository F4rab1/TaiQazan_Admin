//
//  ProductDescriptionController.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 10.04.2024.
//

import UIKit
import SnapKit
import SDWebImage
import FirebaseStorage
import FirebaseFirestore

class ProductDetailController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var selectedProduct: Product?
    
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
    
    private let editProductButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit product", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.rgb(red: 56, green: 182, blue: 255)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        
        return button
    }()
    
    private lazy var mainStackView = CustomStackView(axis: .vertical, arrangedSubviews: [nameTextField, priceTextField, brandTextField, descriptionTextField, editProductButton], spacing: 10, alignment: .fill)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let product = selectedProduct {
            nameTextField.text = product.name
            priceTextField.text = "\(product.price ?? 0) ₸"
            brandTextField.text = product.brand
            descriptionTextField.text = product.description
            if let url = URL(string: product.imageLink ?? "") {
                productImageButton.sd_setImage(with: url, for: .normal)
            }
            
        }
        
        let deleteButton = UIBarButtonItem(title: "delete", style: .plain, target: self, action: #selector(deleteButtonTapped))
        navigationItem.rightBarButtonItem = deleteButton
        
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        productImageButton.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        editProductButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        
        [productImageButton, mainStackView].forEach {
            view.addSubview($0)
        }
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
    
    @objc func editButtonTapped() {
        guard
            let productID = selectedProduct?.id,
            let nameText = nameTextField.text,
            let priceText = priceTextField.text,
            let brandText = brandTextField.text,
            let descriptionText = descriptionTextField.text,
            let image = productImageButton.imageView?.image,
            nameText.count > 0,
            priceText.count > 0,
            brandText.count > 0,
            descriptionText.count > 0,
            image != UIImage(named: "plus_photo")
        else {
            let alert = UIAlertController(title: "Not all fields are filled in", message: "Fill in all the fields", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            present(alert, animated: true)
            
            return
        }
        
        guard let uploadData = image.jpegData(compressionQuality: 0.1) else { return }
        
        let filename = NSUUID().uuidString
        
        let storageRef = Storage.storage().reference().child("productImages").child(filename)
        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
            
            if let err = err {
                print("Failed to upload product image:", err)
                return
            }
            
            storageRef.downloadURL(completion: { (downloadURL, err) in
                if let err = err {
                    print("Failed to fetch downloadURL:", err)
                    return
                }
                
                guard let productImageURL = downloadURL?.absoluteString else { return }
                
                print("Successfully uploaded product image:", productImageURL)
                
                let db = Firestore.firestore()
                
                let collectionRef = db.collection("products")
                let query = collectionRef.whereField("id", isEqualTo: productID)
                
                query.getDocuments { (querySnapshot, error) in
                    
                    if let error = error {
                        print("Error fetching documents: \(error)")
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        print("No documents found")
                        return
                    }
                    
                    for document in documents {
                        document.reference.setData([
                            "name": nameText,
                            "price": Int(priceText) ?? 0,
                            "description": descriptionText,
                            "brand": brandText,
                            "imageLink": productImageURL
                        ], merge: true) { error in
                            if let error = error {
                                print("Error updating document: \(error)")
                            } else {
                                print("Document successfully updated")
                                let alert = UIAlertController(title: "Product updated", message: "Product name: \(nameText)", preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .default)
                                alert.addAction(action)
                                self.present(alert, animated: true)
                            }
                        }
                    }
                }
            })
        })
    }
    
    @objc func deleteButtonTapped() {
        guard let productID = selectedProduct?.id else {
            print("Product ID is nil")
            return
        }
        
        let db = Firestore.firestore()
        let productsRef = db.collection("products")
        
        productsRef.whereField("id", isEqualTo: productID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting document: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            
            for document in documents {
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting document: \(error)")
                    } else {
                        let alert = UIAlertController(title: "Product deleted", message: String(self.selectedProduct?.name ?? ""), preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(action)
                        self.present(alert, animated: true)
                    }
                }
            }
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
        
        [nameTextField, priceTextField, brandTextField, descriptionTextField, editProductButton].forEach { make in
            make.snp.makeConstraints { $0.height.equalTo(50)}
        }
    }
    
}
