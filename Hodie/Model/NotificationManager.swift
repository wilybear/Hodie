//
//  NotificationManager.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/22.
//

import Foundation
import UserNotifications

class LocalNotificationManager {
    var tasks:Set<TodoTask> = []
    
    func requestPermission() -> Void {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .alert]) { granted, error in
                if granted == true && error == nil {
                    self.scheduleNotifications()
                    // We have permission!
                }
        }
    }
    
    func addNotification(task: TodoTask) -> Void {
        tasks.update(with: task)
    }
    
    func scheduleNotifications() -> Void {
        for task in tasks {
            let content = UNMutableNotificationContent()
            content.title = task.name
            let dateComponent = Calendar.current.dateComponents([.hour, .minute], from: task.startTime)
            var triggerDate = DateComponents()
            triggerDate.hour = dateComponent.hour!
            triggerDate.minute = dateComponent.minute!
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(identifier: "\(task.objectID)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                guard error == nil else { return }
                print("Scheduling notification with id: \(task.id)")
            }
        }
    }
    
    func schedule() -> Void {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
              switch settings.authorizationStatus {
                  case .notDetermined:
                      self.requestPermission()
                  case .authorized, .provisional:
                      self.scheduleNotifications()
                  default:
                      break
            }
        }
    }
}
