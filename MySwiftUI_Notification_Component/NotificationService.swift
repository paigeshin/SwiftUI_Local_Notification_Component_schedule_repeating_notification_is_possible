//
//  NotificationService.swift
//  MySwiftUI_Notification_Component
//
//  Created by paige shin on 2021/03/08.
//

import UserNotifications
import SwiftUI

class NotificationService: NSObject {
    
    
    private let notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        createPizzaSelectionCategory()
    }
    
    //원하는 만큼 category를 정의한다.
    private func createPizzaSelectionCategory() {
        let orderAction = UNNotificationAction(identifier: NotificationConstants.ACTION_ORDER_PIZZA, title: "Order Pizza", options: .foreground) //.foreground 앱을 앞으로 가져옴 
        let cancelAction = UNNotificationAction(identifier: NotificationConstants.ACTION_CANCEL_PIZZA, title: "Cancel Pizza", options: .destructive) //없앰
        let category = UNNotificationCategory(identifier: NotificationConstants.CATEGORY_PIZZA, actions: [orderAction, cancelAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
}

//MARK: - PERIODIC NOTIFICATION
extension NotificationService {
    
    //notification 최대 64개까지..
    func addNotification(title: String,
                         body: String,
                         url: URL? = nil,
                         customSoundFileName: String? = nil,
                         weekday: Int? = nil,
                         hour: Int,
                         minute: Int = 0,
                         seconds: Int = 0,
                         repeating: Bool = false, //repeat을 true로 두면 periodic notification이 된다.
                         notificationIdentifier: String? = nil,
                         categoryIdentifier: String? = nil,
                         attachmentIdentifier: String? = nil) {
        
        // 1. Create MutableContent
        let content: UNMutableNotificationContent = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        /// set custom sound if you want
        if let customSoundFileName = customSoundFileName {
            content.sound = UNNotificationSound.init(named:UNNotificationSoundName(rawValue: customSoundFileName))
        }
        
        /// set category if you want
        if let categoryIdentifier: String = categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }
        
        // 2. Create date component
        var dateComponents: DateComponents = DateComponents()
        //dateComponents.calendar = Calendar.current
        
        /// set weeday if you want
        if let weekday = weekday {
            /// 1 - sunday, 2 - monday,  3 - tuesday, 4 - wednesday, 5 - thursday, 6 - friday, 7 -saturday
            dateComponents.weekday = weekday
        }
        
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = seconds
        
        /// attach url if you want
        if let url: URL = url {
            do {
                let attachment = try UNNotificationAttachment(identifier: attachmentIdentifier ?? UUID().uuidString, url: url, options: nil)
                content.attachments = [attachment]
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        // 3. Create Trigger
        let trigger: UNCalendarNotificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeating)
        
        // 4. Create Request
        let request: UNNotificationRequest = UNNotificationRequest(identifier: notificationIdentifier ?? UUID().uuidString, content: content, trigger: trigger)
        notificationCenter.add(request) { (error) in
            if let error: Error = error {
                print("error: ", error.localizedDescription)
                return
            }
            print("added notification: \(request.identifier)")
            print("Notification at \(hour):\(minute), at weekday: \(weekday ?? -1)")
        }
        
    }
    
}


//MARK: - NOTIFICATION STATUS CHECK
extension NotificationService {
    
    //notification status
    func getPendingNotificationRequests() -> [UNNotificationRequest]? {
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        var notificationRequests: [UNNotificationRequest] = [UNNotificationRequest]()
        notificationCenter.getPendingNotificationRequests { (requests) in
            notificationRequests = requests
            semaphore.signal()
        }
        semaphore.wait()
        return notificationRequests
    }
    
    func getPendingNotificationRequests(completion: @escaping([UNNotificationRequest]) -> Void) {
        notificationCenter.getPendingNotificationRequests { (requests) in
            completion(requests)
        }
    }
    
    func getDeliveredNotificationRequests() -> [UNNotification]? {
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        var notificationRequests: [UNNotification] = [UNNotification]()
        notificationCenter.getDeliveredNotifications { (requests) in
            notificationRequests = requests
            semaphore.signal()
        }
        semaphore.wait()
        return notificationRequests
    }
    
    func getDeliveredNotificationRequests(completion: @escaping([UNNotification]) -> Void) {
        notificationCenter.getDeliveredNotifications { (requests) in
            completion(requests)
        }
    }
    
}

//MARK: - CLEAR NOTIFICATION
extension NotificationService {
    
    func removePendingNotificationRequests(identifiers: [String]) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func removePendingNotificationRequests() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func clearDeliveredNotificationRequests(identifiers: [String]) {
        notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
    
    func clearDeliveredNotificationRequests() {
        notificationCenter.removeAllDeliveredNotifications()
    }
    
}

