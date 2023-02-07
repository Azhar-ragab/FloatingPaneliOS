//
//  BottomSheetViewController.swift
//  FloatingPanel
//
//  Created by Azhar Ragab on 07/02/2023.
//

import UIKit

open class BottomSheetContainerViewController<BottomSheet: UIViewController> : UIViewController, UIGestureRecognizerDelegate {
   
    private let configuration: BottomSheetConfiguration
    var state: BottomSheetState = .collapsed
    
    let bottomSheetViewController: BottomSheet
    var floatingPanelResultNotification = FloatingPanelResultNotification()

    private var topConstraint = NSLayoutConstraint()
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer()
        pan.delegate = self
        pan.addTarget(self, action: #selector(handlePan))
        return pan
    }()
    
    init(bottomSheetViewController: BottomSheet,
         bottomSheetConfiguration: BottomSheetConfiguration) {
        
        self.bottomSheetViewController = bottomSheetViewController
        self.configuration = bottomSheetConfiguration
        
        super.init(nibName: nil, bundle: nil)
        self.setupUI()
        floatingPanelResultNotification = FloatingPanelResultNotification(delegate: self)
        floatingPanelResultNotification.subscribe()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    private func setupUI() {
        bottomSheetViewController.view.makeCorner(withRadius: 20)
        self.addChild(bottomSheetViewController)
        self.view.addSubview(bottomSheetViewController.view)
        bottomSheetViewController.view.addGestureRecognizer(panGesture)
        bottomSheetViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        topConstraint = bottomSheetViewController.view.topAnchor
            .constraint(equalTo: self.view.bottomAnchor,
                        constant: -configuration.initialOffset)
        
        NSLayoutConstraint.activate([
            bottomSheetViewController.view.heightAnchor
                .constraint(equalToConstant: configuration.height),
            bottomSheetViewController.view.leftAnchor
                .constraint(equalTo: self.view.leftAnchor),
            bottomSheetViewController.view.rightAnchor
                .constraint(equalTo: self.view.rightAnchor),
            topConstraint
        ])
        
        bottomSheetViewController.didMove(toParent: self)
    }
    
    func showBottomSheet(animated: Bool = true) {
        self.topConstraint.constant = -configuration.height
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.state = .expanded
            })
        } else {
            self.view.layoutIfNeeded()
            self.state = .expanded
        }
    }
    
    func hideBottomSheet(animated: Bool = true) {
        self.topConstraint.constant = -configuration.initialOffset
        
        if animated {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5,
                           options: [.curveEaseOut],
                           animations: {
                            self.view.layoutIfNeeded()
            }, completion: { _ in
                self.state = .collapsed
            })
        } else {
            self.view.layoutIfNeeded()
            self.state = .collapsed
        }
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: bottomSheetViewController.view)
        let velocity = sender.velocity(in: bottomSheetViewController.view)
        
        let yTranslationMagnitude = translation.y.magnitude
        
        switch sender.state {
        case .began, .changed:
            if self.state == .expanded {
               
                guard translation.y > 0 else { return }
                topConstraint.constant = -(configuration.height - yTranslationMagnitude)
                self.view.layoutIfNeeded()
            } else {
                let newConstant = -(configuration.initialOffset + yTranslationMagnitude)
                guard translation.y < 0 else { return }
                guard newConstant.magnitude < configuration.height else {
                    self.showBottomSheet()
                    return
                }
                topConstraint.constant = newConstant
                self.view.layoutIfNeeded()
            }
        case .ended:
            if self.state == .expanded {
                
                if velocity.y < 0 {
                    self.showBottomSheet()
                } else if yTranslationMagnitude >= configuration.height / 2 || velocity.y > 1000 {
                    self.hideBottomSheet()
                } else {
                    self.showBottomSheet()
                }
            } else {
                
                if yTranslationMagnitude >= configuration.height / 2 || velocity.y < -1000 {
                    self.showBottomSheet()
                } else {
                    self.hideBottomSheet()
                }
            }
        case .failed:
            if self.state == .expanded {
                
                self.showBottomSheet()
            } else {
                self.hideBottomSheet()
            }
        default: break
        }
    }
}

extension BottomSheetContainerViewController: FloatingPanelResultNotificationDelegate {
    
    func dismiss() {
        self.view.removeFromSuperview()
    }
}
