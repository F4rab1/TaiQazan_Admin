//
//  SupportTableCell.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 08.04.2024.
//

import Foundation
import UIKit

class SupportTableCell: UITableViewCell {
    
    static let identifier = "SupportTableCell"
    
    private let chatNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = ColorManager.mainBlack
        label.numberOfLines = 0
        label.sizeToFit()
        
        return label
    }()
    
    private let chatImage: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        
        return view
    }()
    
    let newMessageNumberContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager.mainColor
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private let newMessageNumber: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "1"
        label.textColor = .systemBackground
        label.numberOfLines = 0
        label.sizeToFit()
        
        return label
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 0.5)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = ColorManager.mainBGColor
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

//MARK: - setupViews(), setupConstraints(), configure(country: Country)
extension SupportTableCell {
    private func setupViews() {
        [lineView, chatImage, chatNameLabel, newMessageNumberContainer].forEach {
            self.contentView.addSubview($0)
        }
        newMessageNumberContainer.addSubview(newMessageNumber)
        setupConstraints()
    }
    
    private func setupConstraints() {
        chatImage.snp.makeConstraints {
            $0.leading.equalTo(contentView.snp.leading).offset(20)
            $0.top.bottom.equalToSuperview().inset(12)
            $0.size.equalTo(30)
        }
        
        chatNameLabel.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview().inset(13)
            $0.leading.equalTo(chatImage.snp.trailing).offset(20)
        }
        
        lineView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
            $0.top.equalTo(chatImage.snp.bottom).offset(11)
        }
        
        newMessageNumberContainer.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        
        newMessageNumber.snp.makeConstraints {
            $0.center.equalTo(newMessageNumberContainer)
        }
    }
    
    func configure(with chatName: String, image: String, badgeCount: Int) {
        chatNameLabel.text = chatName
        chatImage.image = UIImage(systemName: image)
        guard badgeCount > 0 else {
            newMessageNumberContainer.isHidden = true
            return
        }
        newMessageNumberContainer.isHidden = false
        newMessageNumber.text = "\(badgeCount)"
    }
    
}
