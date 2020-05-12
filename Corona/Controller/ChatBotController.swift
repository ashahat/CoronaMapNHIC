//
//  ChatBotController.swift
//  Corona Map
//
//  Created by Abdulrahman Shahat on 21/03/2020.
//  Copyright © 2020 Samabox. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Assistant
import MessageKit
import MapKit
//import BMSCore
import InputBarAccessoryView


class ChatBotController: MessagesViewController, MessagesDataSource  {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func currentSender() -> SenderType {
        return steven
    }
    
    var currentMSGSender: MockUser {
        return steven
    }
    
    var BashayerSender: MockUser {
        return steven
    }
    
    let refreshControl = UIRefreshControl()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    fileprivate let kCollectionViewCellHeight: CGFloat = 12.5

   // Messages State
    var messageList:  [MockMessage] = []
    
    var now = Date()
    var sessionID : String?

   // Conersation SDK
    var assistant: Assistant?
    var context: MessageContext?
    let steven = MockUser(senderId: "000002", displayName: "")
    let bashayer = MockUser(senderId: "000003", displayName: "")
    var assistantID = ""
    
   // UIButton to initiate login
   @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
          let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
          view.addSubview(navBar)
          let title : String
          let close : String
          if Constants.lang == "ar"
          {
            title = Constants.chatTitleAr
            close = Constants.closeTitleAr
            assistantID = ""
          }
          else
          {
            title = Constants.chatTitle
            close = Constants.closeTitle
            assistantID = ""
          }
          let navItem = UINavigationItem(title: title)
          let doneItem = UIBarButtonItem(title: close , style: .plain, target: nil, action: #selector(cancel))
          navItem.rightBarButtonItem = doneItem

          navBar.setItems([navItem], animated: false)
        
          configureMessageCollectionView()
          configureMessageInputBar()
          self.instantiateAssistant()
    }
    
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
     }
    
    
     override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }

        @objc func didBecomeActive(_ notification: Notification) {
            
            
        }

        // MARK: - Setup Methods

        // Method to instantiate assistant service
        func instantiateAssistant() {

            let authenticator = WatsonIAMAuthenticator(apiKey: "")
                   let assistant = Assistant(version: "Date", authenticator: authenticator)
                   assistant.serviceURL = "https://api.eu-gb.assistant.watson.cloud.ibm.com/instances/"
                   
                 
                  assistant.createSession(assistantID: assistantID) {
                    response, error in

                    guard let session = response?.result else {
                      print(error?.localizedDescription ?? "unknown error")
                      return
                    }
                   
                    self.sessionID = session.sessionID
                    self.assistant = assistant
                    self.retrieveFirstMessage()
                  }
        }

        // Method to handle errors with Watson Assistant
        func failAssistantWithError(_ error: Error) {
            //showAlert(.error(error.localizedDescription))
        }
    
        func configureMessageCollectionView() {
               
            if Constants.lang == "ar"
               {
                   messageInputBar.inputTextView.placeholderLabel.textAlignment = .right
                   messageInputBar.inputTextView.placeholder = Constants.placeholderTitleAr
                   messageInputBar.sendButton.title = Constants.sendTitleAr
                   messageInputBar.inputTextView.textAlignment = .right
               }
               else
               {
                   messageInputBar.inputTextView.placeholderLabel.textAlignment = .left
                    messageInputBar.inputTextView.placeholder = Constants.placeholderTitle
                   messageInputBar.sendButton.title = Constants.sendTitle
                   messageInputBar.inputTextView.textAlignment = .left
               }
               messagesCollectionView.messagesLayoutDelegate = self
               messagesCollectionView.messagesDisplayDelegate = self
               messagesCollectionView.messagesDataSource = self
               messagesCollectionView.messageCellDelegate = self
               scrollsToBottomOnKeyboardBeginsEditing = true // default false
               maintainPositionOnKeyboardFrameChanged = true // default false
               messagesCollectionView.addSubview(refreshControl)
              
           }
           
           func configureMessageInputBar() {
               messageInputBar.delegate = self
               messageInputBar.inputTextView.tintColor = .primaryColor
               messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
               messageInputBar.sendButton.setTitleColor(
                   UIColor.primaryColor.withAlphaComponent(0.3),for: .highlighted
               )
           }

        // Retrieves the first message from Watson
         func retrieveFirstMessage() {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                           NVActivityIndicatorPresenter.sharedInstance.setMessage("التحدث مع بشاير بوت")
                       }

           assistant!.message(assistantID: assistantID, sessionID: self.sessionID!) { response, error in
              guard let watsonMessages = response?.result else {
                  print(error?.localizedDescription ?? "unknown error")
                  return
                }
                
            let output = watsonMessages.output
            DispatchQueue.main.async
            {
                var returnedMessage = ""
                let uniqueID = UUID().uuidString
                let date = self.dateAddingRandomTime()
                for watsonMessage in output.generic!
                {
                    self.context = watsonMessages.context
                    
                    // Add message to assistant message array
                   

                    if(watsonMessage.responseType == "text")
                    {
                        returnedMessage.append("\n" + watsonMessage.text!)
                        
                    }
                    else if(watsonMessage.responseType == "option")
                    {
                        returnedMessage.append("\n" + watsonMessage.title!)
                        returnedMessage.append("\n")
                        var count:Int = 1
                        for optionsMessage in watsonMessage.options!
                        {
                            
                            returnedMessage.append("\n" + String(count) + ". " + optionsMessage.label)
                            count += 1
                        }
                         returnedMessage.append("\n")
                    }
                        
                 }
                      let style = NSMutableParagraphStyle()
                    
                      if Constants.lang == "ar"
                      {
                         style.alignment = NSTextAlignment.right
                      }
                      else
                      {
                         style.alignment = NSTextAlignment.left
                      }
                             
                
                      returnedMessage.append("\n")
                            
                            let attributedText = NSAttributedString(string: returnedMessage, attributes: [NSAttributedString.Key.paragraphStyle: style , .font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.black])

                            let message = MockMessage(attributedText: attributedText, user: self.bashayer, messageId: uniqueID, date: date)
                            
                            self.messageList.append(message)
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToBottom()
                        }
                       
                      
                               
                       }
           }
    

        // Method to create a random date
        func dateAddingRandomTime() -> Date {
            let randomNumber = Int(arc4random_uniform(UInt32(10)))
            var date: Date?
            if randomNumber % 2 == 0 {
                date = Calendar.current.date(byAdding: .hour, value: randomNumber, to: now) ?? Date()
            } else {
                let randomMinute = Int(arc4random_uniform(UInt32(59)))
                date = Calendar.current.date(byAdding: .minute, value: randomMinute, to: now) ?? Date()
            }
            now = date ?? Date()
            return now
        }

        // Method to show an alert with an alertTitle String and alertMessage String
        func showAlert(_ error: AssistantError) {
            // Log the error to the console
            
            DispatchQueue.main.async {

                // Stop animating if necessary
               // self.stopAnimating()

                // If an alert is not currently being displayed
                if self.presentedViewController == nil {
                    // Set alert properties
                    let alert = UIAlertController(title: error.alertTitle,
                                                  message: error.alertMessage,
                                                  preferredStyle: .alert)
                    // Add an action to the alert
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
                    // Show the alert
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }

 // MARK: - Helpers
    
    func insertMessage(_ message: MockMessage) {
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    // MARK: - MessagesDataSource
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 0), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 0), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
       // let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
}

// MARK: - MessageCellDelegate

extension ChatBotController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        //print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        //print("Message tapped")
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        //print("Image tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        //print("Top cell label tapped")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        //print("Bottom cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        //print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        //print("Bottom label tapped")
    }

    func didStartAudio(in cell: AudioMessageCell) {
        //print("Did start playing audio sound")
    }

    func didPauseAudio(in cell: AudioMessageCell) {
        //print("Did pause audio sound")
    }

    func didStopAudio(in cell: AudioMessageCell) {
        //print("Did stop audio sound")
    }

    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        //print("Accessory view tapped")
    }

}

// MARK: - MessageLabelDelegate

extension ChatBotController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        //print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        //print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        //print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL)
    {
        UIApplication.shared.open(url)
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        //print("TransitInformation Selected: \(transitInformation)")
    }

    func didSelectHashtag(_ hashtag: String) {
        //print("Hashtag selected: \(hashtag)")
    }

    func didSelectMention(_ mention: String) {
        //print("Mention selected: \(mention)")
    }

    func didSelectCustom(_ pattern: String, match: String?) {
       //print("Custom data detector patter selected: \(pattern)")
    }
}

    // MARK: - MessageInputBarDelegate

extension ChatBotController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String)
    {

              let attributedText = messageInputBar.inputTextView.attributedText!
              let range = NSRange(location: 0, length: attributedText.length)
              attributedText.enumerateAttribute(.autocompleted, in: range, options: [])
              { (_, range, _) in

                let substring = attributedText.attributedSubstring(from: range)
                _ = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
              }

              let components = inputBar.inputTextView.components
              messageInputBar.inputTextView.text = String()
              messageInputBar.invalidatePlugins()

              // Send button activity animation
              messageInputBar.sendButton.startAnimating()
              messageInputBar.inputTextView.placeholder = "Sending..."
        
              DispatchQueue.global(qos: .default).async {
                   DispatchQueue.main.async { [weak self] in
                       self?.messageInputBar.sendButton.stopAnimating()
                       
                        if Constants.lang == "ar"
                        {
                             self?.messageInputBar.inputTextView.placeholder = Constants.placeholderTitleAr
                        }
                        else
                        {
                            self?.messageInputBar.inputTextView.placeholder = Constants.placeholderTitle
                        }
                       
                        self?.insertMessages(components)
                        self?.messagesCollectionView.scrollToBottom(animated: true)
                   }
             }
                
                let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n", with: ". ")
        
               let messageInput = MessageInput(messageType: MessageInput.MessageType.text.rawValue, text: cleanText)
               
               assistant!.message(assistantID: assistantID, sessionID: self.sessionID!, input: messageInput, context: context) { response, error in

                guard let watsonMessages = response?.result else {
                       print(error?.localizedDescription ?? "unknown error")
                       return
                     }
                     
                let output = watsonMessages.output
                
                 DispatchQueue.main.async
                 {
                     var returnedMessage = ""
                     let uniqueID = UUID().uuidString
                     let date = self.dateAddingRandomTime()
                     for watsonMessage in output.generic!
                     {
                         self.context = watsonMessages.context
                        //print(output.generic!)
                         // Add message to assistant message array
                        

                         if(watsonMessage.responseType == "text")
                         {
                             returnedMessage.append("\n" + watsonMessage.text!)
                         }
                         else if(watsonMessage.responseType == "option")
                         {
                             returnedMessage.append("\n" + watsonMessage.title!)
                             returnedMessage.append("\n")
                             var count:Int = 1
                             for optionsMessage in watsonMessage.options!
                             {
                                 
                                 returnedMessage.append("\n" + String(count) + ". " + optionsMessage.label)
                                 count += 1
                             }
                              returnedMessage.append("\n")
                         }
                             
                      }
                           let style = NSMutableParagraphStyle()
                    
                           if Constants.lang == "ar"
                           {
                              style.alignment = NSTextAlignment.right
                           }
                           else
                           {
                              style.alignment = NSTextAlignment.left
                           }
                     
                           returnedMessage.append("\n")
                           let attributedText = NSAttributedString(string: returnedMessage, attributes: [NSAttributedString.Key.paragraphStyle: style , .font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.black])

                           let message = MockMessage(attributedText: attributedText, user: self.bashayer, messageId: uniqueID, date: date)
                           self.messageList.append(message)
                           inputBar.inputTextView.text = String()
                           self.messagesCollectionView.insertSections([self.messageList.count - 1])
                           self.messagesCollectionView.scrollToBottom()
                 }

               }

           }
    
    private func insertMessages(_ data: [Any]) {
           for component in data {
            let user = self.currentMSGSender
               if let str = component as? String {
                let message = MockMessage(text: str, user: user, messageId: UUID().uuidString, date: Date())
                   insertMessage(message)
               } else if let img = component as? UIImage {
                let message = MockMessage(image: img, user: self.currentMSGSender, messageId: UUID().uuidString, date: Date())
                   insertMessage(message)
               }
           }
       }

    }

// MARK: - MessagesDisplayDelegate

extension ChatBotController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention: return [.foregroundColor: UIColor.white]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .phoneNumber]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
       // let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        //avatarView.set(avatar: avatar)
    }
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }

}

// MARK: - MessagesLayoutDelegate

extension ChatBotController: MessagesLayoutDelegate {
    
   func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
       return 35
   }
   
   func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
       return 0
   }
   
   func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
       return 0
   }
   
   func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
       return 0
   }
    
    
}
