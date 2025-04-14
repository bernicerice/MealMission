import SwiftUI
import FirebaseCore
import AppTrackingTransparency
import AdSupport
import FirebaseAnalytics
import FirebaseInstallations
import FirebaseRemoteConfigInternal
import SdkPushExpress
import AppsFlyerLib

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, DeepLinkDelegate {
    
    var window: UIWindow?
    weak var initVC: MainMeal?
    
    
    var identAdvert: String = ""
    var time = 0
    var analytId: String = ""

    static var orientation = UIInterfaceOrientationMask.all
    
    private let pushAppId = "38921-1202"
    private var externalId = ""
    private var remote: RemoteConfig?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        remote = RemoteConfig.remoteConfig()
        setupConfig()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let viewController = MainMeal()
        initVC = viewController
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        AppsFlyerLib.shared().appsFlyerDevKey = "ZTipXWLJbCob9VqgWYAZ6X"
        AppsFlyerLib.shared().appleAppID = "6744488522"
        AppsFlyerLib.shared().deepLinkDelegate = self
        AppsFlyerLib.shared().delegate = self
        
        Task { @MainActor in
            analytId = await fetchAnalyticsId()
            externalId = analytId
        }

        viewDidLoad(viewController: viewController)
        
        AppsFlyerLib.shared().start()
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)

        //MARK: - PUSH EXPRESS
        externalId = analytId

        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if error != nil {
            } else {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        UNUserNotificationCenter.current().delegate = self

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            do {
                try PushExpressManager.shared.initialize(appId: self.pushAppId)
                try PushExpressManager.shared.activate(extId: self.externalId)
            } catch {
                print("Error initializing or activating PushExpressManager: \(error)")
            }

            if !PushExpressManager.shared.notificationsPermissionGranted {
                print("Notifications permission not granted. Please enable notifications in Settings.")
            }
        }
       
        return true
    }
    
    func fetchAnalyticsId() async -> String {
        do {
            if let appInstanceID = Analytics.appInstanceID() {
                return appInstanceID
            } else {
                return ""
            }
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientation
    }
    
    func setupConfig() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remote?.configSettings = settings
    }
    
    func viewDidLoad(viewController: MainMeal) {
        remote?.fetch { [weak self] status, error in
            guard let self = self else { return }
            
            if status == .success {
                let appsID = AppsFlyerLib.shared().getAppsFlyerUID()
                
                self.remote?.activate { _, error in
                    DispatchQueue.main.async {
                        if error != nil {
                            viewController.firstOpen()
                            return
                        }
                        
                        if let remString = self.remote?.configValue(forKey: "meal").stringValue {
                            if !remString.isEmpty {
                                if let finalURL = UserDefaults.standard.string(forKey: "finalURL") {
                                    viewController.secondOpen(string: finalURL)
                                    print("SECOND OPEN: \(finalURL)")
                                    return
                                }
                                
                                if self.identAdvert.isEmpty {
                                    self.time = 5
                                    self.identAdvert = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                                }
                                
                                if self.identAdvert.isEmpty {
                                    viewController.firstOpen()
                                    return
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(self.time)) {
                                    let stringURL = viewController.helpStr(mainSTR: remString, devID: self.analytId, advertID: self.identAdvert, appsId: appsID)
                                    
                                    print("Result: \(stringURL)")
                                    
                                    guard let url = URL(string: stringURL) else {
                                        viewController.firstOpen()
                                        return
                                    }
                                    
                                    if UIApplication.shared.canOpenURL(url) {
                                        viewController.secondOpen(string: stringURL)
                                    } else {
                                        viewController.firstOpen()
                                    }
                                }
                                
                            } else {
                                viewController.firstOpen()
                            }
                        } else {
                            viewController.firstOpen()
                        }
                    }
                }
            }
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        ATTrackingManager.requestTrackingAuthorization { (status) in
            self.time = 10
            switch status {
            case .authorized:
                self.identAdvert = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                self.time = 1
            case .denied:
                self.identAdvert = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            case .notDetermined:
                print("Not Determined")
            case .restricted:
                print("Restricted")
            @unknown default:
                print("Unknown")
            }
        }
        AppsFlyerLib.shared().start()
    }
    
    //MARK: - Push Notification Handling
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokPart = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let tok = tokPart.joined()
        PushExpressManager.shared.transportToken = tok
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        print("Received notification while app is in foreground: \(userInfo)")
        completionHandler([.banner, .list, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                    didReceive response: UNNotificationResponse,
                    withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("Handling notification response: \(userInfo)")
        NotificationCenter.default.post(name: Notification.Name("didReceiveRemoteNotification"), object: nil, userInfo: userInfo)
        completionHandler()
    }
}

extension AppDelegate: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        print("onConversionDataSuccess \(data)")
    }
    
    func onConversionDataFail(_ error: Error) {
        
    }
}

//@main
//struct MealMissionApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    var body: some Scene {
//        WindowGroup {
//            MainCoordinatorView()
//        }
//    }
//}
