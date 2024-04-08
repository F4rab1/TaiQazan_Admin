//
//  ChatModel.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 08.04.2024.
//

import AVFoundation
import CoreLocation
import Foundation
import MessageKit
import UIKit

struct MockUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
}

// MARK: - ImageMediaItem

private struct ImageMediaItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        size = CGSize(width: 240, height: 240)
        placeholderImage = UIImage()
    }
    
    init(imageURL: URL) {
        url = imageURL
        size = CGSize(width: 240, height: 240)
        placeholderImage = UIImage(systemName: "phone.fill")!
        
    }
}

internal struct MockMessage: MessageType {
    
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var user: MockUser
    var sender: SenderType {
        user
    }
    var isManager: Bool
    private init(kind: MessageKind, user: MockUser, messageId: String, date: Date, isManager: Bool) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
        self.isManager = isManager
    }
    
    init(custom: Any?, user: MockUser, messageId: String, date: Date, isManager: Bool) {
        self.init(kind: .custom(custom), user: user, messageId: messageId, date: date, isManager: isManager)
    }
    
    init(text: String, user: MockUser, messageId: String, date: Date, isManager: Bool) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date, isManager: isManager)
    }
    
    init(image: UIImage, user: MockUser, messageId: String, date: Date, isManager: Bool) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date, isManager: isManager)
    }
    
    init(emoji: String, user: MockUser, messageId: String, date: Date, isManager: Bool) {
        self.init(kind: .emoji(emoji), user: user, messageId: messageId, date: date, isManager: isManager)
    }
    
    init(imageURL: URL, user: MockUser, messageId: String, date: Date, isManager: Bool) {
        let mediaItem = ImageMediaItem(imageURL: imageURL)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date, isManager: isManager)
    }
    
    init(thumbnail: UIImage, user: MockUser, messageId: String, date: Date, isManager: Bool) {
        let mediaItem = ImageMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date, isManager: isManager)
    }
}
