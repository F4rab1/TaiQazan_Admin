//
//  ProductCell.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 10.04.2024.
//

import UIKit
import SnapKit

class ProductCell: UITableViewCell {
    
    static let identifier = "ProductCell"
    
    let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = UIColor.rgb(red: 56, green: 182, blue: 255)
        iv.layer.cornerRadius = 12
        
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Product name"
        
        return label
    }()
    
    let brandLabel: UILabel = {
        let label = UILabel()
        label.text = "Brand name"
        
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "1000" + " ₸"
        
        return label
    }()
    
    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("EDIT", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.backgroundColor = UIColor.rgb(red: 56, green: 182, blue: 255)
        button.layer.cornerRadius = 16
        
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stackview = UIStackView()
        stackview.spacing = 12
        stackview.alignment = .center
        [productImageView,
         VerticalStackView(arrangedSubviews: [
            nameLabel, brandLabel, priceLabel
         ]),
         editButton].forEach { stackview.addArrangedSubview($0) }
        
        return stackview
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview().inset(16)
        }
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        productImageView.snp.makeConstraints { make in
            make.width.height.equalTo(100)
        }
        
        editButton.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(32)
        }
    }
    
}
