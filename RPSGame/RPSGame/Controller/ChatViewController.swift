//
//  ChatTableViewController.swift
//  RPSGame
//
//  Created by EHDOMB on 2022/06/20.
//

import UIKit

final class ChatViewController: UIViewController {
    
    let me = User(data: ["id":"1", "name":"ehd", "profileImageUrl":"", "record":Record(win: 100, lose: 100), "isLogin":true, "isInGame":true, "isInvited":true])
    let opponent = User(data: ["id":"2", "name":"domb", "profileImageUrl":"", "record":Record(win: 100, lose: 100), "isLogin":true, "isInGame":true, "isInvited":false])
    
    var chatMessages = [Message]()
    
    let containerView = UIView()
    let chatTableView = UITableView()
    let inputTextView = UITextView()
    let sendButton = UIButton()
    let moveDownButton = UIButton()
    let messageContainerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setAutoLayout()
        configure()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveKeyboardNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveKeyboardNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        observeMessages()
        textViewDidChange(inputTextView)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setAutoLayout() {
        
        view.addSubview(containerView)
        
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor)
        
        containerView.addSubview(chatTableView)
        containerView.addSubview(messageContainerView)
        containerView.addSubview(moveDownButton)
        
        chatTableView.anchor(top: containerView.topAnchor,
                             left: containerView.leftAnchor,
                             right: containerView.rightAnchor)
        
        messageContainerView.anchor(top: chatTableView.bottomAnchor,
                                    left: containerView.leftAnchor,
                                    bottom: containerView.bottomAnchor,
                                    right: containerView.rightAnchor, height: 60)
        
        moveDownButton.anchor(bottom: messageContainerView.topAnchor,
                              right: containerView.rightAnchor,
                              paddingBottom: 3,
                              paddingRight: 10,
                              width: 32,
                              height: 32)
        
        
        
        messageContainerView.addSubview(inputTextView)
        messageContainerView.addSubview(sendButton)

        inputTextView.anchor(left: messageContainerView.leftAnchor,
                             paddingLeft: 5,
                             height: 35)
        inputTextView.centerY(inView: messageContainerView)
        
        sendButton.anchor(left: inputTextView.rightAnchor,
                          right: messageContainerView.rightAnchor,
                          width: 35,
                          height: 35)
        sendButton.centerY(inView: messageContainerView)
    }
    
    func configure() {

        chatTableView.dataSource = self
        chatTableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "chatCell")
        chatTableView.rowHeight = UITableView.automaticDimension
        chatTableView.separatorStyle = .none
        chatTableView.allowsSelection = false
        chatTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureTableView(_:))))
        
        messageContainerView.backgroundColor = .white
        

        sendButton.setImage(UIImage(named: "sendBtnIcon"), for: .normal)
        sendButton.addTarget(self, action: #selector(sendBtnDidTap(_:)), for: .touchUpInside)

        
        inputTextView.layer.cornerRadius = 7
        inputTextView.layer.borderColor = UIColor.lightGray.cgColor
        inputTextView.layer.borderWidth = 0.2
        

        moveDownButton.setImage(UIImage(named: "moveDownBtn"), for: .normal)
        moveDownButton.layer.opacity = 0.5
        moveDownButton.addTarget(self, action: #selector(moveDownBtnDidTap(_:)), for: .touchUpInside)
        view.bringSubviewToFront(moveDownButton)

    }
    
    @objc func didReceiveKeyboardNotification(_ sender: Notification) {
    
        switch sender.name {
            case UIResponder.keyboardWillShowNotification:
            print("willshow")
            if let keyboardFrame:NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                   let keyboardRectangle = keyboardFrame.cgRectValue
               
                    UIView.animate(withDuration: 0.3) {
                        self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height)
                    }
                }
            
            case UIResponder.keyboardWillHideNotification :
                print("willhide")
                self.view.transform = .identity
                
            default : break
        }
    }
    
    @objc func tapGestureTableView(_ sender: UITapGestureRecognizer) {
        inputTextView.resignFirstResponder()
    }
    
    
    func observeMessages() {

        USERS_REF.child("Chat").child("messages").observe(.childAdded) { (snapshot) in
            if let dataArray = snapshot.value as? [String: Any] {
                
                print("🔵🔵🔵 obserMessages DataArray: ", dataArray)
                
                guard let senderName = dataArray["senderName"] as? String
                    , let messageText = dataArray["text"] as? String
                    else { return }

                let message = Message(userName: senderName, text: messageText)
                self.chatMessages.append(message)
                self.chatTableView.reloadData()

                self.chatTableView.scrollToRow(at: IndexPath(row: self.chatMessages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
            }
        }
    }
    
    func sendMessage(text: String, completion: @escaping (_ isSuccess: Bool) -> () ) {
        let senderName = me.name
        let dataArray: [String: Any] = ["senderName": senderName, "text": text]
        
        print("🔸🔸🔸 sendMessage DataArray: ", dataArray)
        
        USERS_REF.child("Chat").child("messages").childByAutoId().setValue(dataArray) { (error, ref) in
            error == nil ? completion(true) : completion(false)
        }
    }
    
    @objc func sendBtnDidTap(_ sender: UIButton) {
        guard let text = inputTextView.text, !text.isEmpty else { return }

            sendMessage(text: text, completion: { (isSuccess) in
                if isSuccess {
                    self.inputTextView.text = ""
                    self.textViewDidChange(self.inputTextView)
                } else {
                    print("‼️‼️‼️ sendMessage 메소드 에러")
                }
            })
    }
    
    @objc func moveDownBtnDidTap(_ sender: UIButton) {
        guard chatMessages.count > 0 else { return }
        
        self.chatTableView.scrollToRow(at: IndexPath(row: self.chatMessages.count-1, section: 0), at: UITableView.ScrollPosition.top, animated: true)
    }

}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatTableViewCell
        let message = chatMessages[indexPath.row]
        
        cell.setMessageData(message: message)
        
        
        
        message.userName == "e" ?
            cell.setBubbleType(type: .outgoing) : cell.setBubbleType(type: .incoming)
        
        return cell
    }
    
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)

        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
}


