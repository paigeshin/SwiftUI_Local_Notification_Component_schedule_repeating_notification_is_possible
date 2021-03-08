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
