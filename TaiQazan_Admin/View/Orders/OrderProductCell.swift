//
//  OrderDescriptionCell.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 21.02.2024.
//

import UIKit
import SDWebImage

class OrderProductCell: UITableViewCell {
    
    var product: Product? {
        didSet {
            guard let product = product else { return }
            nameLabel.text = product.name
            priceLabel.text = "\(product.price ?? 0) ₸ per unit"
            if let url = URL(string: product.imageLink ?? "") {
                productImageView.sd_setImage(with: url)
            }
        }
    }
    
    var quantity: Int? {
        didSet {
            guard let quantity = quantity else { return }
            quantityLabel.text = "\(quantity)"
            totalPriceLabel.text = "\(quantity * (product?.price ?? 0)) ₸"
        }
    }
    
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
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        
        return label
    }()
    
    let quantityLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.rgb(red: 211, green: 211, blue: 211)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.textAlignment = .center
        
        return label
    }()
    
    let totalPriceLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    lazy var labelsStackView: UIStackView = {
        let stackview = UIStackView()
        stackview.alignment = .top
        stackview.axis = .vertical
        [nameLabel,
         priceLabel,
         quantityLabel].forEach { stackview.addArrangedSubview($0) }
        
        return stackview
    }()
    
    lazy var stackView: UIStackView = {
        let stackview = UIStackView()
        stackview.spacing = 12
        stackview.alignment = .center
        [productImageView,
         labelsStackView,
         totalPriceLabel].forEach { stackview.addArrangedSubview($0) }
        
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
            make.width.height.equalTo(80)
        }
        
        quantityLabel.snp.makeConstraints { make in
            make.width.equalTo(40)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
}
