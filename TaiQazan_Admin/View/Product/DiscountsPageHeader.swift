//
//  DiscountPageHeader.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 22.04.2024.
//

import UIKit
import SnapKit

class DiscountsPageHeader: UICollectionReusableView {
        
    let discountsHeaderHorizontalController = DiscountsHeaderHorizontalController()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
    }
    
    func setupUI() {
        addSubview(discountsHeaderHorizontalController.view)
    }
    
    func setupConstraints() {
        discountsHeaderHorizontalController.view.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
