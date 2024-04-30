//
//  DiscountsHeaderHorizontalController.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 22.04.2024.
//

import UIKit
import SDWebImage

protocol DiscountsHeaderHorizontalDelegate: AnyObject {
    func didSelectImage(withPicker picker: UIImagePickerController)
}

class DiscountsHeaderHorizontalController: HorizontalSnappingController, UIImagePickerControllerDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    weak var delegate: DiscountsHeaderHorizontalDelegate?
    private let cellId = "cellId"
    var selectedIndexPathItem: Int?
    var discountsResults = [Discount]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        collectionView.register(DiscountsHeaderCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        
        fetchDiscounts()
    }
    
    fileprivate func fetchDiscounts() {
        DiscountService.shared.fetchDiscounts { (discounts, error) in
            if let error = error {
                print("Failed to fetch products:", error)
                return
            }

            self.discountsResults = discounts
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return discountsResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DiscountsHeaderCell
        if let imageURL = URL(string: discountsResults[indexPath.item].imageLink ?? "") {
            cell.discountImageView.sd_setImage(with: imageURL)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        selectedIndexPathItem = indexPath.item + 1
        
        delegate?.didSelectImage(withPicker: imagePickerController)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let selectedCell = collectionView.indexPathsForSelectedItems?.first.flatMap({ collectionView.cellForItem(at: $0) }) as? DiscountsHeaderCell {
                selectedCell.discountImageView.image = originalImage
                if let discountId = selectedIndexPathItem {
                    print(discountId)
                    DiscountService.shared.updateDiscount(discountId: discountId, image: originalImage) { discount, err in
                        print(discount, err ?? "error when uploading discount image")
                    }
                }
            }
        }
        
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return .init(width: view.frame.width - 8, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return .init(top: 0, left: 0, bottom: 0, right: 0)
    }
}
