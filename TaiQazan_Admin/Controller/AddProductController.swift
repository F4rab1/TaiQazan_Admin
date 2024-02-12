//
//  ViewController.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 06.02.2024.
//

import UIKit
import SnapKit
import FirebaseStorage
import FirebaseFirestore

class AddProductController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    private let productImageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    private let idTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Product ID"
        tf.borderStyle = .roundedRect
        
        return tf
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
    
    private lazy var mainStackView = CustomStackView(axis: .vertical, arrangedSubviews: [idTextField, nameTextField, priceTextField, brandTextField, descriptionTextField], spacing: 10, alignment: .fill)
    
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
        
        setupUI()
        setDelegates()
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
    
    private func setDelegates() {
        idTextField.delegate = self
        nameTextField.delegate = self
        priceTextField.delegate = self
        brandTextField.delegate = self
        descriptionTextField.delegate = self
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
        
        [idTextField, nameTextField, priceTextField, brandTextField, descriptionTextField].forEach { make in
            make.snp.makeConstraints { $0.height.equalTo(50)}
        }
    }
    
    @objc func addProductButtonTapped() {
        guard
            let idText = idTextField.text,
            let nameText = nameTextField.text,
            let priceText = priceTextField.text,
            let brandText = brandTextField.text,
            let descriptionText = descriptionTextField.text,
            let image = productImageButton.imageView?.image,
            idText.count > 0,
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
                
                print("Successfully uploaded profile image:", productImageURL)
                
                let db = Firestore.firestore()
                var ref: DocumentReference? = nil
                ref = db.collection("products").addDocument(data: [
                    "id": "5",
                    "name": nameText,
                    "price": Int(priceText) ?? 0,
                    "description": descriptionText,
                    "brand": brandText,
                    "imageLink": productImageURL
                ]) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                    }
                }
            })
        })
        
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

