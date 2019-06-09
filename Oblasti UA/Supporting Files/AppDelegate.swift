//
//  AppDelegate.swift
//  TestMap
//
//  Created by Artem Yelizarov on 4/23/19.
//  Copyright © 2019 Artem Yelizarov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Public Properties
    var window: UIWindow?

    /// Returns delegate of UIApplication's shared instance, casted to AppDelegate
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    /// Block of code that will be called (if set) when application 'resigns active', used to pause game tasks (for example, stop timers)
    var pauseApp: (() -> ())?
    
    weak var settingsObserver: TMRemovableObserver?
    weak var menuModeObserver: TMRemovableObserver?
    weak var pauseScreenShowTimeObserver: TMRemovableObserver?
    weak var settingsController: TMSettingsController?

    // MARK: - AppDelegate Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        removeObservers()
        pauseApp?()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        addObservers()
        settingsController?.loadSettings()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        removeObservers()
    }

    // MARK: - Private Methods
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

