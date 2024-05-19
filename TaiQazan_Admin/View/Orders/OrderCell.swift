//
//  OrderCell.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 18.02.2024.
//

import UIKit
import SnapKit

class OrderCell: UITableViewCell {
    
    let cartImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "cart.fill")
        iv.tintColor = .gray
        
        return iv
    }()
    
    let orderIdLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.black
        
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Status"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        label.backgroundColor = UIColor.rgb(red: 56, green: 182, blue: 255)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        contentView.addSubview(cartImage)
        contentView.addSubview(orderIdLabel)
        contentView.addSubview(statusLabel)
    }
    
    func configure(with orderId: String, status: Int) {
        orderIdLabel.text = "\(orderId)"
        statusLabel.text = statusLabelText(for: status)
    }
    
    private func statusLabelText(for status: Int) -> String {
        switch status {
        case 1:
            return "Created"
        case 2:
            return "Collecting products"
        case 3:
            return "Collected products"
        case 4:
            return "Delivering"
        case 5:
            return "Delivered"
        default:
            return "Unknown Status"
        }
    }
    
    private func setupConstraints() {
        cartImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.height.width.equalTo(32)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        orderIdLabel.snp.makeConstraints { make in
            make.leading.equalTo(cartImage.snp.trailing).offset(8)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.width.equalTo(80)
            make.height.equalTo(32)
            make.top.bottom.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
