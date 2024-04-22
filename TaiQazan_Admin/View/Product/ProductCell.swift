//
//  ProductCell.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 10.04.2024.
//

import UIKit
import SnapKit
import SDWebImage

class ProductCell: UICollectionViewCell {
    
    static let identifier = "ProductCell"
    
    let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        iv.layer.borderWidth = 0.5
        iv.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Product name"
        label.font = .boldSystemFont(ofSize: 18)
        
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
    
    let editButton: UILabel = {
        let label = UILabel()
        label.text = "Edit"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 14)
        label.backgroundColor = UIColor.rgb(red: 56, green: 182, blue: 255)
        label.layer.cornerRadius = 16
        label.clipsToBounds = true
        label.textAlignment = .center
        
        return label
    }()
    
    let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        
        return view
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stackView)
        addSubview(lineView)
        
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
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(14)
            make.top.equalToSuperview().offset(-10)
            make.bottom.equalTo(lineView.snp.top)
        }
        
        lineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview().inset(14)
            make.bottom.equalToSuperview()
        }
    }
    
}
