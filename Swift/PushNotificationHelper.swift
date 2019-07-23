//
//  PushNotificationHelper.swift
//

import Foundation

@objc class PushNotificationHelper: NSObject {
    
    @objc static let sharedInstance = PushNotificationHelper()
    override init(){}
    
    static private let pushMessagesKey = Constants.UserDefaultsKeys.unreadMessagesNotifications.rawValue
    static private let pushJobUpdatesKey = Constants.UserDefaultsKeys.unreadJobUpdatesNotifications.rawValue
    static private let pushJobDBKey = Constants.UserDefaultsKeys.jobsNotifications.rawValue
    
    
    static var newJobsUpdates: [Int] {
        let defaults = UserDefaults(suiteName: ObfuscatedDefinitions.userDefaultsDomain)
        
        guard let jobUpdatesCount = defaults?.value(forKey: pushJobUpdatesKey) as? [Int] else {
            return []
        }
        return jobUpdatesCount
    }
    
    static var newJobMessages: [Int] {
        let defaults = UserDefaults(suiteName: ObfuscatedDefinitions.userDefaultsDomain)
        
        guard let messages = defaults?.value(forKey: pushMessagesKey) as? [Int] else {
            return []
        }
        return messages
    }
    
    static var jobsDB: [Int] {
        let defaults = UserDefaults(suiteName: ObfuscatedDefinitions.userDefaultsDomain)
        
        guard let jobs = defaults?.value(forKey: pushJobDBKey) as? [Int] else {
            return []
        }
        return jobs
    }
    
    @objc var userLoggedOut: Bool = false
    
    static public func updateJobPushes(newPush:Payload) {
        
        guard let jobId = newPush.jobId else { return }
        
        let type = newPush.locKey
        
        var jobsUpdates = newJobsUpdates
        var messages = newJobMessages
        
        if type == .update && !jobsUpdates.contains(jobId.jobId) {
            jobsUpdates.append(jobId.jobId)
            PushNotificationHelper.syncPushJobUpdates(jobUpdates: jobsUpdates)
        } else if type == .message {
            messages.append(jobId.jobId)
            PushNotificationHelper.syncPushMessages(messages: messages)
        }
    }
    
    @objc static public var unreadPushesCount: NSNumber {

        var count = 0
        
        let defaults = UserDefaults(suiteName: ObfuscatedDefinitions.userDefaultsDomain)
        if let messages = defaults?.value(forKey: pushMessagesKey) as? [Int] {
            count += messages.count
        }
        
        if let jobUpdates = defaults?.value(forKey: pushJobUpdatesKey) as? [Int] {
            count += jobUpdates.count
        }
        
        return NSNumber(value:count)
    }
    
    static public func syncPushMessages(messages:[Int]) {
        
        if let defaults = UserDefaults(suiteName: ObfuscatedDefinitions.userDefaultsDomain) {
            defaults.set(messages , forKey: pushMessagesKey)
        }
    }
    
    static public func syncPushJobUpdates(jobUpdates:[Int]) {
        
        let defaults = UserDefaults(suiteName: ObfuscatedDefinitions.userDefaultsDomain)
        defaults?.set(jobUpdates , forKey: pushJobUpdatesKey)
    }
    
    static public func syncPushJobsDB(jobsDB:[Int]) {
        
        let defaults = UserDefaults(suiteName: ObfuscatedDefinitions.userDefaultsDomain)
        defaults?.set(jobsDB , forKey: pushJobDBKey)
    }
}
