//
//  DiscountsHeaderHorizontalController.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 22.04.2024.
//

import UIKit

protocol DiscountsHeaderHorizontalDelegate: AnyObject {
    func didSelectImage(withPicker picker: UIImagePickerController)
}

class DiscountsHeaderHorizontalController: BaseListController, UIImagePickerControllerDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    weak var delegate: DiscountsHeaderHorizontalDelegate?
    private let cellId = "cellId"
    var groupHeaderImage = ["dis1", "dis2", "dis3"]
    var selectedIndexPathItem: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        collectionView.register(DiscountsHeaderCell.self, forCellWithReuseIdentifier: cellId)
       
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return groupHeaderImage.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DiscountsHeaderCell
        let imageName = groupHeaderImage[indexPath.item]
        cell.discountImageView.image = UIImage(named: imageName)
        
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
                    DiscountsService.shared.updateDiscount(discountId: discountId, image: originalImage) { discount, err in
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
        
        return .init(top: 0, left: 16, bottom: 0, right: 0)
    }
}
