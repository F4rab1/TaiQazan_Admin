//
//  UIStackViewExtension.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 07.02.2024.
//

import UIKit

class CustomStackView: UIStackView {
    init(axis: NSLayoutConstraint.Axis = .vertical, arrangedSubviews: [UIView], spacing: CGFloat = 0, distribution: Distribution = .fill, alignment: Alignment = .fill) {
        super.init(frame: .zero)
        arrangedSubviews.forEach{addArrangedSubview($0)}
        self.axis = axis
        self.spacing = spacing
        self.distribution = distribution
        self.alignment = alignment
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
