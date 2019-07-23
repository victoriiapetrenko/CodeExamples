//
//  NotificationViewController.swift
//  JobDeploymentNotification
//

import UIKit
import UserNotifications
import UserNotificationsUI
import DJLocalization

/**
 The Job Deployment Notification screen (S10)
 
 From here the user can either accept a job, then the Job Overview screen will be shown.
 If the user either lets the time run out or taps the 'Decline Job' button, the 'Job Rejected' screen will be shown.
 */
class JobDeploymentNotificationViewController: UIViewController, UNNotificationContentExtension {
    
    @IBOutlet weak var jobIdLabel: UILabel!
    @IBOutlet weak var jobId: UILabel!
    @IBOutlet weak var trademarkImage: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timer: UILabel!
    
    let defaults = UserDefaults(suiteName: ObfuscatedDefinitions.userDefaultsDomain)
    
    /// The timer that continously triggers a refresh of the UI state.
    private weak var fireTimer: Timer?
    let timerQueue = DispatchQueue(label: "Timer DispatchQueue", qos: .background, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
    
    /// The countdown timer used to display the remaining time to answer the job request.
    private var countdownTimer: CountdownTimer?
    
    /// The jobId number received from the notification payload.
    var jobIdValue: JobId?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer?.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        timer?.text = ""
        timer?.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scheduleUIUpdatingTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        unscheduleUIUpdatingTimer()
    }
    
    
    // MARK: - Push Notifications
    
    /**
     Use push notification payload to display the S10 screen.
     
     Required fields in the JSON payload (on the same level as the Apple `aps` field):
     - `jobId`: The deployment job id
     - `trademark`: A positive integer that corresponds to the trademark to be used to show logo and play ring sound.
     - `timer`: The countdown timer specified in minutes (different for various trademarks).
     - `timeStampPushReceived`: Our custom field that is set at the moment the push notification is received on the device. Used to calculate the remaining time to show in the countdown timer.
     
     TODO: this might be called multiple times while the view controller is visible. Handle this!
     */
    func didReceive(_ notification: UNNotification) {
        let factory = PayloadFactory(userInfo: notification.request.content.userInfo)
        
        guard let payload: Payload = factory.constructPayload() else {
                return
        }
        
        WSADataProviderHelper().postGetAllSyntiaNotifications()
        
        jobIdLabel?.text = DJLocalizedString("deployment_status_new", comment: "")
        
        if let jobIdObj = payload.jobId {
            var jobIdStr = String(jobIdObj.jobId)
            if jobIdStr.count > 8 {
                jobIdStr = String(jobIdStr.prefix(8))
            }
            
            jobId?.text = jobIdStr
            
            jobIdValue = payload.jobId
            
            if let trademarkString = payload.trademark,
                let trademark = Trademark(rawValue: trademarkString),
                let trademarkFilename = TrademarkMapper.logoFilenameBlack(for: trademark) {
                trademarkImage.image = UIImage(imageLiteralResourceName: trademarkFilename)
            }
            
            switch payload.locKey {
            case .newJob:
                timerLabel?.text = DJLocalizedString("time", comment: "") + ":"
                var twoMinutesTimer:TimeInterval = 2*60
                if let timer = payload.timer {
                    twoMinutesTimer = timer
                }
                var receivedPushTime = Date().timeIntervalSinceNow + twoMinutesTimer
                var newCountdownTime = receivedPushTime
                if let timeStampPushReceived = payload.timeStampPushReceived {
                    receivedPushTime = timeStampPushReceived
                    
                    // Calculate and update remaining time for the countdown since the user has received the push notification.
                    let unixTimeStamp = Date().timeIntervalSince1970
                    let differenceTime = unixTimeStamp - receivedPushTime
                }
                
                if newCountdownTime <= 0 {
                    countdownTimer = CountdownTimer(startTime: 0, forJobId: jobIdObj, andType: .jobTimeOutT1)
                    timeoutJob()
                } else {
                    countdownTimer = CountdownTimer(startTime: newCountdownTime, forJobId: jobIdObj, andType: .jobTimeOutT1)
                }
                
                scheduleUIUpdatingTimer()
                
            case .jobReBroadcast:
                timerLabel?.text = nil
                unscheduleUIUpdatingTimer()
            case .etaReminder:
                jobIdLabel?.text = "\( DJLocalizedString("p2s10o2", comment: "")) \(jobIdStr)"
                jobId.isHidden = true
                timerLabel?.text = DJLocalizedString("p2s10o1", comment: "")
                
                let isoDate = payload.trademark
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                dateFormatter.locale = Locale(identifier: DJLocalizationSystem.shared.language)
                
                let dateUtils = DateUtils()
                
                if let date = dateUtils.formattedETATimeFrom(isoDate){
                    let dateString = dateFormatter.string(from: date)
                    timer.text = dateString
                }
                
                unscheduleUIUpdatingTimer()
                
            default:
                break
            }
        }
    }
    
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
        // Go to S20 screen when the user taps anywhere on S10
        completion(.dismissAndForwardAction)
    }
    
    /**
     The user didn't react in time, time-out the job.
     */
    func timeoutJob() {
        DispatchQueue.main.async {
            self.timer?.text = DJLocalizedString("expired", comment: "")
        }
        
        // Save "expired" state to be able to show home screen instead of S20
        defaults?.set(true, forKey: "skipS20")
        
        sendTimeOut()
        timerQueue.sync {
            self.fireTimer?.invalidate()
        }
    }
    
    func sendTimeOut() {
        guard let username = WSAKeychainManager.username,
            let password = WSAKeychainManager.password(forUsername: username),
            let appInstanceId = defaults?.string(forKey: ObfuscatedDefinitions.wSAAppInstance),
            let jobId = jobIdValue else {
                return
        }
        
        let time = Date()
        let apiConnector = ApiConnector(session: URLSession.shared, requestFactory: RequestFactory(username: username, password: password))
        let event = JobEventRejected(vFreeText: nil,
                                     vCode: .rejectedByTimeOut,
                                     jobId: jobId,
                                     sequenceId: nil,
                                     bOfflineSystem: false,
                                     tsAction: time,
                                     tsAppTimestamp: time,
                                     applicationInstance: appInstanceId,
                                     timeoutCode: .app, refusalCode: nil,
                                     vTimeoutType: .notification)
        
        var url = ServerUrlPersistence.sharedInstance.serverUrl
        url += "/WSAppServer-wsapp/app_notification/create"
        
        apiConnector.makeCall(with: url, parameters: event, completion: { (success, response: BasicResponse?) in
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.dataDecodingStrategy = .base64
            
            let key = LocKeys.newJob.rawValue
            var pushEvent: PushEvent?
            
            if let data = self.defaults?.data(forKey: key) {
                pushEvent = try? decoder.decode(PushEvent.self, from: data)
                pushEvent?.isSent = response?.isSuccessful ?? false
            }
            
            // Store job id for later synchronization with Core Data
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.dataEncodingStrategy = .base64
            
            let pushEventData = try? encoder.encode(pushEvent)
            self.defaults?.set(pushEventData, forKey: key)
        })
    }
    
    /**
     Continuously called during the life time of the countdown timer.
     
     - Update the UI with new timer values.
     - Trigger job time-out.
     */
    @objc private func countdownTimerTick() {
        guard let countdownTimer = countdownTimer else {
            return
        }
        
        let (_, minutes, seconds) = DateUtils().secondsToHoursMinutesSeconds(seconds: Int(countdownTimer.time))
        DispatchQueue.main.async {
            self.timer?.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
        }
        
        if countdownTimer.time <= 0 {
            unscheduleUIUpdatingTimer()
            timeoutJob()
        }
    }
    
    
    // MARK: - Helper
    
    /**
     Schedule the reoccurring firing timer.
     */
    private func scheduleUIUpdatingTimer() {
        timerQueue.async {
            let timer = Timer(timeInterval: 1, target: self, selector: #selector(self.countdownTimerTick), userInfo: nil, repeats: true)
            timer.tolerance = 0.1
            self.fireTimer = timer
            
            if let countdownTimer = self.countdownTimer {
                let (_, minutes, seconds) = DateUtils().secondsToHoursMinutesSeconds(seconds: Int(countdownTimer.time))
                let timerString = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
                
                DispatchQueue.main.async {
                    self.timer?.text = String(format: DJLocalizedString("p2s20o3", comment: ""), timerString)
                }
            }
            RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
            RunLoop.current.run()
        }
    }
    
    /**
     Invalidate the reocurring UI firing timer.
     */
    private func unscheduleUIUpdatingTimer() {
        timerQueue.sync {
            fireTimer?.invalidate()
        }
    }
    
}
