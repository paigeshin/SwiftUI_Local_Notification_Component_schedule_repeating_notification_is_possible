//
//  NotificationReceiver.swift
//  MySwiftUI_Notification_Component
//
//  Created by paige shin on 2021/03/08.
//

import SwiftUI
import UserNotifications


// MARK: - HANDLE INCOMING REQUESTS
class NotificationReceiver: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    private let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        requestAuthorization(remote: true)
        notificationCenter.delegate = self
    }
    
    private func requestAuthorization(remote: Bool) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted: Bool, error: Error?) in
            if let error: Error = error {
                print("error: ", error.localizedDescription)
                return
            }
            if granted {
                self.notificationCenter.delegate = self
                print("granted: ", granted)
                if remote {
                    print("Registered for remote message")
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
    }
    
}

// MARK: - HANDLE INCOMING REQUESTS
extension NotificationReceiver {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Receiving Response....\(response)")
        
        switch response.actionIdentifier {
        case NotificationConstants.ACTION_ORDER_PIZZA:
            print("Order Pizza")
            NotificationCenter.default.post(name: NSNotification.Name(NotificationConstants.POST_NOTIFICATION_ORDER_PIZZA), object: nil)
        case NotificationConstants.ACTION_CANCEL_PIZZA:
            print("Cancel Pizza")
        default:
            break
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) { }
}
