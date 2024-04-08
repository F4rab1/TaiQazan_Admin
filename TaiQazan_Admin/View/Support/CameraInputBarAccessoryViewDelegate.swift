//
//  CameraInputBarAccessoryViewDelegate.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 08.04.2024.
//

import InputBarAccessoryView
import UIKit
import UniformTypeIdentifiers

// MARK: - CameraInputBarAccessoryViewDelegate

protocol CameraInputBarAccessoryViewDelegate: InputBarAccessoryViewDelegate {
  func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment])
}

protocol AlertPresenterDelegate: AnyObject {
    func presentAlert(alert: UIAlertController)
    func presentImagePicker(imagePicker: UIImagePickerController)
    func presentDocumentPicker(documentPicker: UIDocumentPickerViewController)
    func dismiss()
}

extension CameraInputBarAccessoryViewDelegate {
  func inputBar(_: InputBarAccessoryView, didPressSendButtonWith _: [AttachmentManager.Attachment]) { }
}

// MARK: - CameraInputBarAccessoryView

class CameraInputBarAccessoryView: InputBarAccessoryView, UIDocumentPickerDelegate {
  // MARK: Lifecycle

    weak var alertPresenterDelegate: AlertPresenterDelegate?
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  lazy var attachmentManager: AttachmentManager = { [unowned self] in
    let manager = AttachmentManager()
    manager.delegate = self
    return manager
  }()

  func configure() {
    let camera = makeButton(named: "ic_camera")
    camera.tintColor = .darkGray
    camera.onTouchUpInside { [weak self] _ in
      self?.showImagePickerControllerActionSheet()
    }
    setLeftStackViewWidthConstant(to: 35, animated: true)
    setStackViewItems([camera], forStack: .left, animated: false)
    inputPlugins = [attachmentManager]
  }

  override func didSelectSendButton() {
    if attachmentManager.attachments.count > 0 {
      (delegate as? CameraInputBarAccessoryViewDelegate)?
        .inputBar(self, didPressSendButtonWith: attachmentManager.attachments)
    }
    else {
      delegate?.inputBar(self, didPressSendButtonWith: inputTextView.text)
    }
  }

  // MARK: Private

  private func makeButton(named _: String) -> InputBarButtonItem {
    InputBarButtonItem()
      .configure {
        $0.spacing = .fixed(10)
        $0.image = UIImage(systemName: "paperclip")?.withRenderingMode(.alwaysTemplate)
        $0.setSize(CGSize(width: 40, height: 40), animated: false)
      }.onSelected {
        $0.tintColor = .systemBlue
      }.onDeselected {
          $0.tintColor = ColorManager.mainColor
      }.onTouchUpInside { _ in
        print("Item Tapped")
      }
  }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension CameraInputBarAccessoryView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func showImagePickerControllerActionSheet() {
        let photoLibraryAction = UIAlertAction(title: "Выберите из фото", style: .default) { [weak self] _ in
            self?.showImagePickerController(sourceType: .photoLibrary)
        }
        
        let cameraAction = UIAlertAction(title: "Снимок с камеры", style: .default) { [weak self] _ in
            self?.showImagePickerController(sourceType: .camera)
        }
        
        let directoryAction = UIAlertAction(title: "Выберите PDF из файлов", style: .default) { [weak self] _ in
            self?.showFilePickerController()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        
        let alert = UIAlertController(title: "Выберите свой изображение", message: nil, preferredStyle: .actionSheet)
        
        for action in [photoLibraryAction, cameraAction, directoryAction, cancelAction] {
            alert.addAction(action)
        }
        alertPresenterDelegate?.presentAlert(alert: alert)
    }

    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        imgPicker.sourceType = sourceType
        imgPicker.presentationController?.delegate = self
        inputAccessoryView?.isHidden = true
        alertPresenterDelegate?.presentImagePicker(imagePicker: imgPicker)
    }
    
    func imagePickerController(
        _: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
    {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            inputPlugins.forEach { _ = $0.handleInput(of: editedImage) }
        }
        else if let originImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            inputPlugins.forEach { _ = $0.handleInput(of: originImage) }
        }
        alertPresenterDelegate?.dismiss()
        inputAccessoryView?.isHidden = false
    }
    
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        alertPresenterDelegate?.dismiss()
        inputAccessoryView?.isHidden = false
    }
    
    func showFilePickerController() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data], asCopy: true)
               documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .fullScreen
        alertPresenterDelegate?.presentDocumentPicker(documentPicker: documentPicker)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let documentURL = urls.first else { return }
        let documentData = (NSData(contentsOf: documentURL))
        if let data = documentData {
            inputPlugins.forEach { _ = $0.handleInput(of: data) }
        }
    }
}

// MARK: AttachmentManagerDelegate

extension CameraInputBarAccessoryView: AttachmentManagerDelegate {
  // MARK: - AttachmentManagerDelegate

  func attachmentManager(_: AttachmentManager, shouldBecomeVisible: Bool) {
    setAttachmentManager(active: shouldBecomeVisible)
  }

  func attachmentManager(_ manager: AttachmentManager, didReloadTo _: [AttachmentManager.Attachment]) {
    sendButton.isEnabled = manager.attachments.count > 0
  }

  func attachmentManager(_ manager: AttachmentManager, didInsert _: AttachmentManager.Attachment, at _: Int) {
    sendButton.isEnabled = manager.attachments.count > 0
  }

  func attachmentManager(_ manager: AttachmentManager, didRemove _: AttachmentManager.Attachment, at _: Int) {
    sendButton.isEnabled = manager.attachments.count > 0
  }

  func attachmentManager(_: AttachmentManager, didSelectAddAttachmentAt _: Int) {
    showImagePickerControllerActionSheet()
  }

  // MARK: - AttachmentManagerDelegate Helper

  func setAttachmentManager(active: Bool) {
    let topStackView = topStackView
    if active, !topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
      topStackView.insertArrangedSubview(attachmentManager.attachmentView, at: topStackView.arrangedSubviews.count)
      topStackView.layoutIfNeeded()
    } else if !active, topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
      topStackView.removeArrangedSubview(attachmentManager.attachmentView)
      topStackView.layoutIfNeeded()
    }
  }
}

// MARK: UIAdaptivePresentationControllerDelegate

extension CameraInputBarAccessoryView: UIAdaptivePresentationControllerDelegate {
  // Swipe to dismiss image modal
  public func presentationControllerWillDismiss(_: UIPresentationController) {
    isHidden = false
  }
}

