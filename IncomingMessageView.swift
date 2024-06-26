

import Foundation
import UIKit
import Combine

class IncomingMessageView: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var friendlyNameLabel: UILabel!
    @IBOutlet weak var msgContentView: UIView!
    @IBOutlet weak var dateTimeSent: UILabel!
    
    
    @IBOutlet weak var textMsg: UITextView!
    
    @IBOutlet weak var imageMsg: UIImageView!
    
    private var cordnator: Cordnator = Cordnator.sharedInstance
    
    private var cancellables = Set<AnyCancellable>()
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureCell(message : PersistentMessageDataItem){
        
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        let viewModel = MessageBubbleViewModel(message: message, currentUser: Cordnator.sharedInstance.myIdentity)
        msgContentView.layer.cornerRadius = 2;
//        friendlyNameLabel.isHidden = true
        friendlyNameLabel.text = message.author
        let type = viewModel.contentCategory
        
        print(type)
        imageMsg.image = nil
        textMsg.text = nil
        imageMsg.isHidden = true
        textMsg.isHidden = true
//        msgContentView.frame = CGRect(x: 0, y: 0, width: 0, height:0)
//        imageMsg.frame = CGRect(x: 0, y: 0, width: 0, height:0)
//        textMsg.frame = CGRect(x: 0, y: 0, width: 0, height:0)
        
        if(type == .text){
            textMsg.isHidden = false
            textMsg.attributedText = viewModel.text
        }
        else if(type == .image){
            imageMsg.isHidden = false
            cordnator.getMediaAttachmentURL(for: viewModel.source.messageIndex, conversationSid: viewModel.source.conversationSid) { url in
                viewModel.getImage(for: url)
            }
            
            viewModel.$image
                        .receive(on: DispatchQueue.main)
                        .sink { [weak self] image in
                            if(image != nil){
                                self?.imageMsg.image = image
                            }
                        }
                        .store(in: &cancellables)
        }
    }
}
