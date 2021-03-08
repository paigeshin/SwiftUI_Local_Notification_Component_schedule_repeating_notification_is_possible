# SwiftUI_Local_Notification_Component_schedule_repeating_notification_is_possible

# NotificationService

- It creates notifications
- It can remove notifications or observe it
- You can create as many categories as you need in `Constructor`

```swift
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
```

# NotificationReceiver

- It handles incoming Notifications

```swift
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
```

# NotificationConstants

- This class contains `category` name `action` name and `post` name.

```swift
//
//  NotificationConstants.swift
//  MySwiftUI_Notification_Component
//
//  Created by paige shin on 2021/03/08.
//

struct NotificationConstants {
    
    static let CATEGORY_PIZZA = "category_pizza"
    static let ACTION_ORDER_PIZZA = "action_order_pizza"
    static let ACTION_CANCEL_PIZZA = "action_cancel_pizza"
    
    //ACTION_ORDER_PIZZA를 선택했을 때 View로 보내줄 value, action의 option이 .foreground일 때만 가능하다.
    static let POST_NOTIFICATION_ORDER_PIZZA = "post_notification_order_pizza"
    
    
}
```

# Set on App LifeCycle

```swift
//
//  MySwiftUI_Notification_ComponentApp.swift
//  MySwiftUI_Notification_Component
//
//  Created by paige shin on 2021/03/08.
//

import SwiftUI

@main
struct MySwiftUI_Notification_ComponentApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(deviceToken)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
}

struct ContentView: View {
    
    @State var receivedText: String = ""
    let notificationService = NotificationService()
    @ObservedObject var notificationReceiver = NotificationReceiver()
    
    var body: some View {
        
        VStack {
            Text(self.receivedText)
                .padding()
        
            Button("Create Notification") {
                
                if let path = Bundle.main.path(forResource: "image2", ofType: "jpg") {
                    let url = URL(fileURLWithPath: path)
                    notificationService.addNotification(
                        title: "Ordering Pizza?",
                        body: "They are very delicious",
                        url: url,
                        hour: 16,
                        minute: 41,
                        categoryIdentifier: NotificationConstants.CATEGORY_PIZZA
                    )
                    notificationService.addNotification(
                        title: "Ordering Pizza?",
                        body: "They are very delicious",
                        url: url,
                        hour: 16,
                        minute: 42,
                        categoryIdentifier: NotificationConstants.CATEGORY_PIZZA
                    )
                    notificationService.addNotification(
                        title: "Ordering Pizza?",
                        body: "They are very delicious",
                        url: url,
                        hour: 16,
                        minute: 43,
                        categoryIdentifier: NotificationConstants.CATEGORY_PIZZA
                    )
                    notificationService.addNotification(
                        title: "Ordering Pizza?",
                        body: "They are very delicious",
                        url: url,
                        hour: 16,
                        minute: 44,
                        categoryIdentifier: NotificationConstants.CATEGORY_PIZZA
                    )
                }

                

            }
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name(NotificationConstants.POST_NOTIFICATION_ORDER_PIZZA), object: nil, queue: .main) { (_) in
                self.receivedText = "Order Pizza!!!"
            }
        }
        

    }
}
```