//
//  TMSettingsNavigationController.swift
//  TestMap
//
//  Created by Artem Yelizarov on 5/10/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

class TMSettingsNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    
//    -(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
//    {
//    return YES;
//    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
//    Also, don't forget to register the delegate with
//
//    recognizer.delegate = self;
//    Now the gesture recognizer should recognize gestures and the target method (handleTapBehind:) will be called.
//
//    Here comes the second problem in iOS 8: locationInView: doesn't seem to take the device orientation into account if nil is passed as a view. Instead, passing the root view works.
//
//    Here's my target code that seems to work for iOS 7.1 and 8.0:
//
//    if (sender.state == UIGestureRecognizerStateEnded) {
//    UIView *rootView = self.view.window.rootViewController.view;
//    CGPoint location = [sender locationInView:rootView];
//    if (![self.view pointInside:[self.view convertPoint:location fromView:rootView] withEvent:nil]) {
//    [self dismissViewControllerAnimated:YES completion:^{
//    [self.view.window removeGestureRecognizer:sender];
//    }];
//    }
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        tapGestureRecognizer.delegate = self
        view.window?.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func onTap(_ sender: UITapGestureRecognizer){
        
        if sender.state == .ended {
            if let rootView = view.window?.rootViewController?.view {
                
                let location = sender.location(in: rootView)
                
                if !view.point(inside: view.convert(location, from: rootView), with: nil) {
                    view.window?.removeGestureRecognizer(sender)
                }
                
            }
        }
    }
    
    deinit {
        print(self, "deinit!")
    }
}
