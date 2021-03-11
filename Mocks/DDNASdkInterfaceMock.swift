class DDNASdkInterfaceMock: NSObject, DDNASdkInterface {
    public var hasStarted: Bool = false
    public var isUploading: Bool = false
    
    public var recordedEvents: [DDNAEvent] = []
    
    func record(_ event: DDNAEvent!) -> DDNAEventAction! {
        recordedEvents.append(event)
        return DDNAEventAction()
    }
    
    func newSession() {
    }
    
    func stop() {
    }
    
    func clearPersistentData() {
    }
    
    func upload() {
    }
    
    func downloadImageAssets() {
    }
    
    func requestSessionConfiguration(_ userManager: DDNAUserManager!) {
    }
    
    func recordPushNotification(_ pushNotification: [AnyHashable : Any]!, didLaunch: Bool) {
    }
    
    func setCrossGameUserId(_ crossGameUserId: String!) {
    }
    
    func setPushNotificationToken(_ pushNotificationToken: String!) {
    }
    
    func setDeviceToken(_ deviceToken: Data!) {
    }
    
    func request(_ engagement: DDNAEngagement!, completionHandler: (([AnyHashable : Any]?, Int, Error?) -> Void)!) {
    }
    
    func request(_ engagement: DDNAEngagement!, engagementHandler: ((DDNAEngagement?) -> Void)!) {
    }
    
    func start(withNewPlayer userManager: DDNAUserManager!) {
    }
    
}
