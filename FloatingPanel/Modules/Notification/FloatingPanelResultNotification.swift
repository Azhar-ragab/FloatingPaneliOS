//
//  FloatingPanelResultNotification.swift
//  FloatingPanel
//
//  Created by Azhar Ragab on 07/02/2023.
//

import Foundation
protocol FloatingPanelResultNotificationDelegate {
    
    func dismiss()
}

class FloatingPanelResultNotification {
    
    private var delegate: FloatingPanelResultNotificationDelegate?
    
    init(delegate: FloatingPanelResultNotificationDelegate? = nil) {
        self.delegate = delegate
    }
    
    func dismiss() {
        post()
    }
        
    private func post() {
        let name = Notification.Name("name")
        NotificationCenter.default.post(
            name: name,
            object: nil,
            userInfo: nil)
    }
    
    func subscribe() {
        let name = Notification.Name("name")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.panelResult(notification: )),
            name: name,
            object: nil)
    }
    
    @objc private func panelResult(notification: Notification) {
     
        delegate?.dismiss()
    }
}
