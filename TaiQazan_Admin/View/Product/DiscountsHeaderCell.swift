//
//  DiscountsHeaderCell.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 22.04.2024.
//

import UIKit

class DiscountsHeaderCell: UICollectionViewCell {
    
    let discountsLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap the image to change discount image"
        label.textColor = .blue
        label.font = .boldSystemFont(ofSize: 12)
        
        return label
    }()
    
    let discountImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .red
        
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stackView = VerticalStackView(arrangedSubviews: [
            discountsLabel,
            discountImageView
        ], spacing: 12)
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
            make.leading.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
