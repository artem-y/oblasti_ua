//
//  AppDelegate.swift
//  Oblasti UA
//
//  Created by Artem Yelizarov on 4/23/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Static Properties
    
    /// Returns delegate of UIApplication's shared instance, casted to AppDelegate
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    // MARK: - Public Properties
    
    var window: UIWindow?
    
    /// Block of code that will be called (if set) when application 'resigns active', used to pause game tasks (for example, stop timers)
    var pauseApp: (() -> ())?
    
    weak var settingsObserver: OBRemovableObserver?
    weak var menuModeObserver: OBRemovableObserver?
    weak var pauseScreenShowTimeObserver: OBRemovableObserver?
    weak var settingsController: OBSettingsController?
}

// MARK: - App Delegate Methods

extension AppDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        removeObservers()
        pauseApp?()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        addObservers()
        settingsController?.loadSettings()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        removeObservers()
    }
}

// MARK: - Private Methods

extension AppDelegate {
    private func addObservers() {
        settingsObserver?.addToNotificationCenter()
        menuModeObserver?.addToNotificationCenter()
        pauseScreenShowTimeObserver?.addToNotificationCenter()
    }
    
    private func removeObservers() {
        settingsObserver?.removeFromNotificationCenter()
        menuModeObserver?.removeFromNotificationCenter()
        pauseScreenShowTimeObserver?.removeFromNotificationCenter()
    }
}

