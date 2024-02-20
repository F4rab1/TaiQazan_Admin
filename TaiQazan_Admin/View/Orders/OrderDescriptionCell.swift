//
//  OrderDescriptionCell.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 21.02.2024.
//

import UIKit

class OrderDescriptionCell: UITableViewCell {
    
    let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "galamilk")
        iv.backgroundColor = .blue
        iv.layer.cornerRadius = 12
        
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Bio-ice cream Dr.Galamilk Vanilla+Probiotic 100 g"
        
        return label
    }()
    
    let brandLabel: UILabel = {
        let label = UILabel()
        label.text = "Galamilk"
        
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "2310 ₸"
        
        return label
    }()
    
    let quantityLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .lightGray
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = true
        label.textAlignment = .center 
        label.text = "2"
        
        return label
    }()
    
    lazy var labelsStackView: UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .vertical
        [nameLabel,
         brandLabel,
         priceLabel].forEach { stackview.addArrangedSubview($0) }
        
        return stackview
    }()
    
    lazy var stackView: UIStackView = {
        let stackview = UIStackView()
        stackview.spacing = 12
        stackview.alignment = .center
        [productImageView,
         labelsStackView,
         quantityLabel].forEach { stackview.addArrangedSubview($0) }
        
        return stackview
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        
        addSubview(stackView)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        productImageView.snp.makeConstraints { make in
            make.width.height.equalTo(64)
        }
        
        quantityLabel.snp.makeConstraints { make in
            make.width.equalTo(32)
            make.height.equalTo(32)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
}
