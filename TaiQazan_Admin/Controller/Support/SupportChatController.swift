//
//  SupportChatController.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 08.04.2024.
//

import UIKit
import MessageKit
import FirebaseAuth
import InputBarAccessoryView
import NVActivityIndicatorView
import SDWebImage

class SupportChatController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    private let chatFirebase = ChatFirebaseService()
   
    private var messageButtonTapped = false
    
    var currentSender: MessageKit.SenderType {
        currentUser
    }
    
    var currentUser = MockUser(senderId: "\(Auth.auth().currentUser?.uid ?? "Вы")", displayName: "Вы")
    
    private let activityIndicatorView: NVActivityIndicatorView = {
        let view = NVActivityIndicatorView(frame: .zero)
        view.type = .lineScale
        view.color = ColorManager.mainColor ?? UIColor.black
        
        return view
    }()
    
    private let customTitle: UILabel = {
        let label = UILabel()
        label.textColor = ColorManager.mainColor
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.text = "Служба Поддержки"
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = customTitle
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        showMessageTimestampOnSwipeLeft = true
        
        fetchMessages()
        configureMessageInputBar()
        
        addActivityIndicatorView()
        
        navigationController?.navigationBar.tintColor = ColorManager.mainBlack
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        layout?.setMessageOutgoingCellBottomLabelAlignment(.init(textAlignment: .right, textInsets: .zero))
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?
            .setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(
                textAlignment: .right,
                textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)))
        layout?
            .setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(
                textAlignment: .right,
                textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)))
        
    }
    
    // MARK: - MessagesDataSource
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    func fetchMessages() {
        activityIndicatorView.startAnimating()
        
        ChatViewModel.shared.getDataFromFirbase(currentUser: currentUser, chatID: 0) { [weak self] in
          
            self?.messagesCollectionView.reloadData()
            self?.messagesCollectionView.scrollToLastItem()
            self?.activityIndicatorView.stopAnimating()
        }
    }
    
    
    func addActivityIndicatorView() {
        messagesCollectionView.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(300)
            make.width.height.equalTo(50)
            make.centerX.equalToSuperview()
        }
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return ChatViewModel.shared.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return ChatViewModel.shared.messages.count
    }
    
    func configureMessageInputBar() {
        let cameraInputBar = CameraInputBarAccessoryView()
        cameraInputBar.alertPresenterDelegate = self
        messageInputBar = cameraInputBar
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = ColorManager.mainColor
        messageInputBar.sendButton.setTitleColor(ColorManager.mainColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            ColorManager.mainColor!.withAlphaComponent(0.3),
            for: .highlighted)
        
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.tintColor = ColorManager.mainColor
        messageInputBar.inputTextView.backgroundColor = .clear
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        
        
        //                placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabel.text = "  Напишите ваше сообщение"
        messageInputBar.inputTextView.placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200 / 255, green: 200 / 255, blue: 200 / 255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        configureInputBarItems()
        inputBarType = .custom(messageInputBar)
    }
    
    private func configureInputBarItems() {
        messageInputBar.setRightStackViewWidthConstant(to: 40, animated: false)
        messageInputBar.sendButton.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
        messageInputBar.sendButton.setSize(CGSize(width: 40, height: 40), animated: false)
        messageInputBar.sendButton.image = UIImage(named: "ic_up")
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 20
        let charCountButton = InputBarButtonItem()
            .configure {
                $0.title = "0/140"
                $0.contentHorizontalAlignment = .right
                $0.setTitleColor(UIColor(white: 0.6, alpha: 1), for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .bold)
                $0.setSize(CGSize(width: 50, height: 25), animated: false)
            }.onTextViewDidChange { item, textView in
                item.title = "\(textView.text.count)/140"
                let isOverLimit = textView.text.count > 140
                item.inputBarAccessoryView?
                    .shouldManageSendButtonEnabledState = !isOverLimit
                if isOverLimit {
                    item.inputBarAccessoryView?.sendButton.isEnabled = false
                }
                let color = isOverLimit ? .red : UIColor(white: 0.6, alpha: 1)
                item.setTitleColor(color, for: .normal)
            }
        let bottomItems = [.flexibleSpace, charCountButton]
        
        configureInputBarPadding()
        
        messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)
        
        messageInputBar.sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = ColorManager.mainColor
                })
            }.onDisabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
                })
            }
    }
    
    private func configureInputBarPadding() {
        messageInputBar.padding.bottom = 8
        messageInputBar.middleContentViewPadding.right = -38
        messageInputBar.inputTextView.textContainerInset.bottom = 8
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) {
        let avatar = Avatar(image: UIImage(systemName: "beats.headphones"))
        avatarView.set(avatar: avatar)
        avatarView.layer.borderWidth = 2
        avatarView.isHidden = isNextMessageSameSender(at: indexPath)
        avatarView.layer.borderColor = ColorManager.mainColor?.cgColor
    }
    
    func setChatType() {
        let label = UILabel()
        label.text = "Nurmukh"
        label.textColor = ColorManager.mainColor
        self.navigationItem.titleView = label
        
        let chatType = UserDefaults.standard.string(forKey: "ChatCollectionName") ?? "message"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if chatType == "message" {
                label.text = "Message Title"
            } else {
                label.text = "Other Title"
            }
        }
    }
}

extension SupportChatController: CameraInputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        messageButtonTapped = true
        let message = MockMessage(text: text, user: MockUser(senderId: currentSender.senderId, displayName: currentUser.displayName), messageId: UUID().uuidString, date: Date(), isManager: true)
        ChatViewModel.shared.messages.append(message)
        ChatFirebaseService.shared.saveMessageToFirebase(message)
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment]) {
        for item in attachments {
            if case .image(let image) = item {
                self.sendImageMessage(photo: image)
            }
            else if case .data(let data) = item {
                self.sendDataMessage(data: data)
            }
        }
        inputBar.invalidatePlugins()
    }
    
    func sendImageMessage(photo: UIImage) {
        let photoMessage = MockMessage(image: photo, user: MockUser(senderId: currentSender.senderId, displayName: currentUser.displayName), messageId: UUID().uuidString, date: Date(), isManager: true)
        ChatViewModel.shared.messages.append(photoMessage)
        ChatFirebaseService.shared.saveMessageToFirebase(photoMessage)
        messagesCollectionView.reloadData()
    }
    
    func sendDataMessage(data: Data) {
        let dataMessage = MockMessage(custom: data, user: MockUser(senderId: currentSender.senderId, displayName: currentUser.displayName), messageId: UUID().uuidString, date: Date(), isManager: true)
        let dataMessageWithPhoto = MockMessage(emoji: "📄", user: MockUser(senderId: currentSender.senderId, displayName: currentUser.displayName), messageId: UUID().uuidString, date: Date(), isManager: true)
        ChatViewModel.shared.messages.append(dataMessageWithPhoto)
        ChatFirebaseService.shared.saveMessageToFirebase(dataMessage)
        messagesCollectionView.reloadData()
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) {
        if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
            imageView.sd_setImage(with: imageURL)
        }
    }
}


extension SupportChatController {
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        guard message.messageId != "messageButton" else {
            return  .bubbleOutline(.darkGray)
        }
        return .bubbleTail(tail, .curved)
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in collection: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath), message.messageId != "messageButton" {
            return 18
        }
        
        return 0
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isTimeLabelVisible(at: indexPath) {
            return NSAttributedString(
                string: formatter(date: message.sentDate),
                attributes: [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                    NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                ])
        }
        return nil
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if message.messageId != "messageButton" {
            return 18
        }
        
        return 0
    }
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard message.messageId != "messageButton" else { return nil }
        let displayName = message.sender.displayName == "Клиент" ? "Клиент" : "Вы"
        return NSAttributedString(string: displayName, attributes: [.font: UIFont.systemFont(ofSize: 10)])
    }
    
    func messageBottomLabelHeight(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        guard message.messageId == "messageButton" else { return 14 }
        return 5
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
        guard message.messageId != "messageButton" else { return nil }
        let dateString = hourFormatter(date: message.sentDate)
        return NSAttributedString(
            string: dateString,
            attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

// Is functions and formatters
extension SupportChatController {
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        indexPath.section % 4 == 0
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return ChatViewModel.shared.messages[indexPath.section].user == ChatViewModel.shared.messages[indexPath.section - 1].user
    }
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < ChatViewModel.shared.messages.count else { return false }
        return ChatViewModel.shared.messages[indexPath.section].user == ChatViewModel.shared.messages[indexPath.section + 1].user
    }
    
    func formatter(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM HH:mm"
        return dateFormatter.string(from: date)
    }
    
    func hourFormatter(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
}

extension SupportChatController: AlertPresenterDelegate {
    
    func presentAlert(alert: UIAlertController) {
        present(alert, animated: true)
    }
    
    func presentImagePicker(imagePicker: UIImagePickerController) {
        present(imagePicker, animated: true)
    }
    
    func presentDocumentPicker(documentPicker: UIDocumentPickerViewController) {
        documentPicker.modalPresentationStyle = .fullScreen
        present(documentPicker, animated: true, completion: nil)
    }
    
    func dismiss() {
        dismiss(animated: true)
    }
}

extension SupportChatController: MessageCellDelegate {
    func didTapAvatar(in _: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func sendNewMessage(_ label: String) {
        var messageText = label
        messageText.removeLast()
        let message = MockMessage(text: messageText, user: MockUser(senderId: currentSender.senderId, displayName: currentUser.displayName), messageId: UUID().uuidString, date: Date(), isManager: true)
        ChatViewModel.shared.messages.append(message)
        ChatFirebaseService.shared.saveMessageToFirebase(message)
        messagesCollectionView.reloadData()
    }
}

extension MessagesDisplayDelegate {
    // MARK: - All Messages Defaults
    
    //    public func backgroundColor(
    //        for message: MessageType,
    //        at _: IndexPath,
    //        in messagesCollectionView: MessagesCollectionView)
    //    -> UIColor
    //    {
    //        let outgoingMessageBackground = UIColor(named: "outgoingMessageBackground")!
    //        let incomingMessageBackground = UIColor(named: "incomingMessageBackground")
    //
    //        switch message.kind {
    //        case .emoji:
    //            return .clear
    //        default:
    //            guard let dataSource = messagesCollectionView.messagesDataSource else {
    //                return .white
    //            }
    //
    //            if dataSource.isFromCurrentSender(message: message) {
    //                return (message.messageId == "messageButton") ? .systemGray6: outgoingMessageBackground
    //            } else {
    //                return incomingMessageBackground!
    //            }
    //        }
    //    }
    
    //    public func textColor(
    //        for message: MessageType,
    //        at _: IndexPath,
    //        in messagesCollectionView: MessagesCollectionView)
    //    -> UIColor
    //    {
    //
    //        let incomingMessageLabel = UIColor(named: "incomingMessageLabel")
    //        guard let dataSource = messagesCollectionView.messagesDataSource else {
    //            return .black
    //        }
    //
    //        if dataSource.isFromCurrentSender(message: message) {
    //            return (message.messageId == "messageButton") ? incomingMessageLabel!: .white
    //        } else {
    //            return incomingMessageLabel!
    //        }
    //
    //    }
}
