//
//  NotificationService.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 7.09.25.
//

import UserNotifications
import RxSwift


protocol NotificationsServiceProtocol: AnyObject {
    
    func requestAuthorization() -> Single<Bool>
    
    func configure()
    
    func scheduleDailyReminders(_ times: [DateComponents])
    
    func cancelAll()
}

final class NotificationsService: NSObject, NotificationsServiceProtocol {
    enum Const {
        static let categoryId = "health.reminder.category"
        static let actionMeasureId = "health.reminder.measure"
        static let requestPrefix = "health.reminder."
        static let threadId = "health.reminders"
    }
    
    private struct Template {
        let title: String
        let body: String
    }
    private let templates: [Template] = [
        .init(title: "🌡️ Check Your Temperature",
              body: "Stay on track — take a quick reading to monitor your health."),
        .init(title: "🧠 Feeling Okay Today?",
              body: "Take a moment to check your temperature and stay informed."),
        .init(title: "⏰ It’s Temperature Time",
              body: "Keep your data consistent. Take your daily measurement now."),
        .init(title: "📈 Build a Better Health Routine",
              body: "Log your temperature and heart rate today to track trends over time."),
        .init(title: "🔔 Daily Check Reminder",
              body: "A quick temperature check can help you spot changes early.")
    ]
    
    private func defaultTimes() -> [DateComponents] {
        return [DateComponents(hour: 9, minute: 41)]
    }
    
    private let center = UNUserNotificationCenter.current()
    private let bag = DisposeBag()
    
    // MARK: - Public
    
    func configure() {
        center.delegate = self
        
        let measure = UNNotificationAction(
            identifier: Const.actionMeasureId,
            title: "Measure now",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: Const.categoryId,
            actions: [measure],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([category])
        
        // React to UD notification state
        UDManagerService.notificatonStateObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] enabled in
                guard let self = self else { return }
                if enabled {
                    self.requestAuthorization()
                        .subscribe(onSuccess: { granted in
                            // Mirror the immediate user decision into UD
                            UDManagerService.setNotificatonState(granted)
                            if granted {
                                self.scheduleDailyReminders(self.defaultTimes())
                            } else {
                                self.cancelAll()
                            }
                        })
                        .disposed(by: self.bag)
                } else {
                    self.cancelAll()
                }
            })
            .disposed(by: bag)
    }
    
    func requestAuthorization() -> Single<Bool> {
        Single.create { [weak self] observer in
            self?.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                observer(.success(granted))
            }
            return Disposables.create()
        }
    }
    
    func scheduleDailyReminders(_ times: [DateComponents]) {
      
        let ids = times.indices.map { Const.requestPrefix + "\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: ids)
        
        for (idx, dc) in times.enumerated() {
            let tpl = templates.randomElement() ?? templates[0]
            let content = UNMutableNotificationContent()
            content.title = tpl.title
            content.body = tpl.body
            content.sound = .default
            content.categoryIdentifier = Const.categoryId
            content.threadIdentifier = Const.threadId
           
            content.userInfo = ["deeplink": "btp://measure/temp"]
            
            var date = DateComponents()
            date.hour = dc.hour
            date.minute = dc.minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
            let id = Const.requestPrefix + "\(idx)"
            let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            center.add(req)
        }
    }
    
    func cancelAll() {
        center.getPendingNotificationRequests { [weak self] list in
            let ids = list
                .map(\.identifier)
                .filter { $0.hasPrefix(Const.requestPrefix) }
            self?.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationsService: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == NotificationsService.Const.actionMeasureId ||
            response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            NotificationCenter.default.post(name: .openMeasureFromNotification, object: nil)
        }
        completionHandler()
    }
}

extension Notification.Name {
    static let openMeasureFromNotification = Notification.Name("openMeasureFromNotification")
}
