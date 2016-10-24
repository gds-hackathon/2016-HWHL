//
//  XMPPWorker.swift
//  NobodyAlone
//
//  Created by Stan Wu on 15/8/18.
//  Copyright (c) 2015年 Stan Wu. All rights reserved.
//

import UIKit
import CoreData

let kChatServer = "1affair.com"
let kChatServerDomain = "1affair.com"

class XMPPWorker: NSObject,XMPPStreamDelegate,XMPPReconnectDelegate,XMPPAutoPingDelegate,XMPPBlockingDelegate {
    var chatUID:String?
    fileprivate static var _xmppStream: XMPPStream!
    static var xmppReconnect: XMPPReconnect!
    static var xmppAutoPing: XMPPAutoPing!
    static var xmppBlocking: XMPPBlocking!
    static var xmppStreamManagement: XMPPStreamManagement!
    fileprivate static var _sharedWorker: XMPPWorker!
    
    static var xmppStream: XMPPStream{
        get{
            if _xmppStream == nil{
                setupStream()
            }
            
            return _xmppStream
        }
    }
    
    static var sharedWorker: XMPPWorker!{
        get{
            if _sharedWorker == nil{
                _sharedWorker = XMPPWorker()
            }
            
            return _sharedWorker
        }
    }
    
    class func sendMessage(_ msg:String,toUser uid:String,date:Date?){
        sendMessage(msg, toUser: uid, date: date, paid: false)
    }
    
    class func sendMessage(_ msg:String,toUser uid:String,date:Date?,paid: Bool){
        let body = DDXMLElement(name: "body")
        body?.setStringValue(msg)
        
        if let d = date{
            body?.addAttribute(withName: "date", doubleValue: d.timeIntervalSince1970)
        }
        
        if paid{
            body?.addAttribute(withName: "paid", stringValue: "1")
        }
        
        let message = DDXMLElement(name: "message")
        message?.addAttribute(withName: "type", stringValue: "chat")
        message?.addAttribute(withName: "to", stringValue: "\(uid)@\(kChatServerDomain)")
        message?.addChild(body)
        
        xmppStream.send(message)
    }
    
    class func sendFakeMessage(_ msg:String,fromUser uid:String){
        if uid != MDataProvider.myUID(){
            let body = DDXMLElement(name: "body")
            body?.setStringValue(msg)
            
            let message = XMPPMessage(type: "chat")
            message?.addAttribute(withName: "from", stringValue: "\(uid)@\(kChatServerDomain)")
            message?.addChild(body)
            
            XMPPWorker.sharedWorker.xmppStream(xmppStream, didReceive: message)
        }
    }
    
    class func sendMedia(_ mediaInfo: NSDictionary,toUser uid: String,date: Date?){
        let body = DDXMLElement(name: "body")
        body?.setStringValue(NSLocalizedString("当前版本不支持查看此条消息，请升级到最新版本", comment: "当前版本不支持查看此条消息，请升级到最新版本"))
        
        if let d = date{
            body?.addAttribute(withName: "date", doubleValue: d.timeIntervalSince1970)
        }
        
        if MDataProvider.isVIP(){
            body?.addAttribute(withName: "paid", stringValue: "1")
        }
        
        let mediaString = NSString(data: try! JSONSerialization.data(withJSONObject: mediaInfo, options: JSONSerialization.WritingOptions(rawValue: 0)), encoding: String.Encoding.utf8.rawValue)
        body?.addAttribute(withName: "media", stringValue: mediaString as! String)
        
        let message = DDXMLElement(name: "message")
        message?.addAttribute(withName: "type", stringValue: "chat")
        message?.addAttribute(withName: "to", stringValue: "\(uid)@\(kChatServerDomain)")
        message?.addChild(body)
        
        xmppStream.send(message)
    }
    
    class func supportedMediaType(_ mediaType:String?) -> Bool{
        let supported = NSSet(array: ["photo","voice","question","answer"])
        
        if let mt = mediaType{
            return supported.contains(mt)
        }else{
            return false
        }
    }
    

    
    class func setupStream(){
        if _xmppStream == nil{
            _xmppStream = XMPPStream()
            
            xmppReconnect = XMPPReconnect(dispatchQueue: DispatchQueue.main)
            xmppReconnect.addDelegate(XMPPWorker.sharedWorker, delegateQueue: DispatchQueue.main)
            xmppReconnect.activate(_xmppStream)
            
            xmppAutoPing = XMPPAutoPing(dispatchQueue: DispatchQueue.main)
            xmppAutoPing.pingInterval = 15
            xmppAutoPing.pingTimeout = 10
            xmppAutoPing.addDelegate(XMPPWorker.sharedWorker, delegateQueue: DispatchQueue.main)
            xmppAutoPing.activate(_xmppStream)
            
            xmppBlocking = XMPPBlocking(dispatchQueue: DispatchQueue.main)
            xmppBlocking.autoRetrieveBlockingListItems = true
            xmppBlocking.addDelegate(XMPPWorker.sharedWorker, delegateQueue: DispatchQueue.main)
            xmppBlocking.activate(_xmppStream)
            
            xmppStreamManagement = XMPPStreamManagement(dispatchQueue: DispatchQueue.main)
            xmppStreamManagement.addDelegate(XMPPWorker.sharedWorker, delegateQueue: DispatchQueue.main)
            xmppReconnect.activate(_xmppStream)
            
            _xmppStream.addDelegate(sharedWorker, delegateQueue: DispatchQueue.main)
        }
#if !TARGET_IPHONE_SIMULATOR
    // Want xmpp to run in the background?
    //
    // P.S. - The simulator doesn't support backgrounding yet.
    //        When you try to set the associated property on the simulator, it simply fails.
    //        And when you background an app on the simulator,
    //        it just queues network traffic til the app is foregrounded again.
    //        We are patiently waiting for a fix from Apple.
    //        If you do enableBackgroundingOnSocket on the simulator,
    //        you will simply see an error message from the xmpp stack when it fails to set the property.
    
    _xmppStream.enableBackgroundingOnSocket = true
#endif
    }
    
    @objc class func checkAndConnect(){
        if MDataProvider.myInfo() == nil{
            return
        }
        
        if let prompts = UserDefaults.standard.object(forKey: "prompts") as? NSDictionary{
            let mut = NSMutableDictionary(dictionary: prompts)
            mut.setObject("0", forKey: "message" as NSCopying)
            UserDefaults.standard.set(mut, forKey: "prompts")
        }
        
        let lastTime = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "LastCheckLoginStatusTime"))
        var needCheckLoginStatus = false
        if Date().timeIntervalSince(lastTime) > 300{
            needCheckLoginStatus = true
        }
        
        if needCheckLoginStatus{
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "LastCheckLoginStatusTime")
//            MTStatusBarOverlay.sharedInstance().postMessage(NSLocalizedString("正在连接...", comment: "正在连接..."))
            SWUtils.RunOnBackgroundThread({ () -> Void in
                XMPPWorker.checkLoginStatus()
            })
        }else{
            _ = connect()
        }
    }
    
    class func checkLoginStatus(){
        autoreleasepool { () -> () in
            let dict = MDataProvider.getMyProfile()
            let code = dict?.int(forKey: "code") ?? 0
            if SWDefinitions.RETURN_SUCCESS_CODE == code{
                SWUtils.RunOnMainThread({ () -> Void in
//                    MTStatusBarOverlay.sharedInstance().postFinishMessage(NSLocalizedString("连接成功", comment: "连接成功"), duration: 0.01)
                    _ = XMPPWorker.connect()
//                    NSNotificationCenter.defaultCenter().postNotificationName(NANotifications.ReloadPromptsFromBG, object: nil)
                })
            }else{
                SWUtils.RunOnMainThread({ () -> Void in
//                    MTStatusBarOverlay.sharedInstance().postErrorMessage(NSLocalizedString("连接失败", comment: "连接失败"), duration: 0.01)
//                    MTStatusBarOverlay.sharedInstance().hide()
                })
            }
        }
    }
    
    class func connect() -> Bool{
        if MDataProvider.myInfo() == nil || MDataProvider.XMPPPassword() == nil{
            return false
        }
        
        setupStream()
        
        if !xmppStream.isDisconnected(){
            return true
        }
        
        let uid = MDataProvider.myUID()!
        
        
        xmppStream.myJID = XMPPJID(string: "\(uid)@\(kChatServerDomain)/iphone")
        xmppStream.hostName = kChatServer
        
        do{
            try xmppStream.connect(withTimeout: 10)
        }catch{
            return false
        }
        
        return true
    }
    
    @objc class func disconnect(){
        NSLog("XMPP Disconnected")
//        MTStatusBarOverlay.sharedInstance().postFinishMessage(NSLocalizedString("连接关闭", comment: "连接关闭"), duration: 0.01)
        
        let status = (UIApplication.shared.delegate as! AppDelegate).currentNetworkStatus
        if NotReachable == status{
            xmppStream.disconnect()
        }else{
            xmppStream.disconnectAfterSending()
        }
    }
    
    func goOnline(){
        let presence = XMPPPresence()
        XMPPWorker.xmppStream.send(presence)
    }
    
    func goOffline(){
        let presence = XMPPPresence(type: "unavailable")
        XMPPWorker.xmppStream.send(presence)
    }
    
    
    
    // MARK: - XMPP Delegate
    func xmppStreamDidDisconnect(_ sender: XMPPStream!, withError error: Error!) {
        NSLog("Disconnected:\(error)")
    }
    
    func xmppStreamDidConnect(_ sender: XMPPStream!) {
        NSLog("Connected");
        
        _ = try? XMPPWorker.xmppStream.authenticate(withPassword: MDataProvider.XMPPPassword()!)
    }
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
        NSLog("Loginned")
        
        self.goOnline()
    }
    
    func xmppStream(_ sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        NSLog("Login Error:\(error)")
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive message: XMPPMessage!) {
        let type = message.attributeStringValue(forName: "type")
        
        let body = message.forName("body")
        
        
        if type == "chat" && body != nil{
            let from = message.attributeStringValue(forName: "from")
            let uid = from?.components(separatedBy: "@")[0]
            let relativeUID = body?.attributeStringValue(forName: "uid")
            let paid = body?.attributeBoolValue(forName: "paid")
            
            var dateline:Date?
            if let children = message.children() as? [DDXMLElement]{
                for child in children{
                    if let stamp = child.attributeStringValue(forName: "stamp"){
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                        dateline = formatter.date(from: stamp)
                        if  dateline == nil{
                            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                            dateline = formatter.date(from: stamp)
                        }
                        
                        let currentGMTOffset = NSTimeZone.local.secondsFromGMT()
                        dateline = dateline?.addingTimeInterval(Double(currentGMTOffset))
                    }
                }
            }
            
            if dateline == nil{
                dateline = Date()
            }
            
            let content = body?.stringValue()
            let action = body?.attributeStringValue(forName: "action")
            var mediaInfo: NSDictionary?
            if let media = body?.attributeStringValue(forName: "media"){
                if let d = media.data(using: String.Encoding.utf8, allowLossyConversion: true){
                    mediaInfo = (try? JSONSerialization.jsonObject(with: d, options: .allowFragments)) as? NSDictionary
                }
            }

            
            
        }
    }
    
    func xmppStream(_ sender: XMPPStream!, didSend message: XMPPMessage!) {
        SWUtils.RunOnMainThread { () -> Void in
            
            let body = message.forName("body")
            
            let date = Date(timeIntervalSince1970: (body?.attributeDoubleValue(forName: "date"))!)
            
            let prev = date.addingTimeInterval(-0.000001)
            let after = date.addingTimeInterval(0.000001)
            
            
        }
    }
    
    func xmppStream(_ sender: XMPPStream!, didFailToSend message: XMPPMessage!, error: Error!) {
        SWUtils.RunOnMainThread { () -> Void in
            let body = message.forName("body")
            
            let date = Date(timeIntervalSince1970: (body?.attributeDoubleValue(forName: "date"))!)
            
            let prev = date.addingTimeInterval(-0.000001)
            let after = date.addingTimeInterval(0.000001)
            
            
        }
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive presence: XMPPPresence!) {
        if let type = presence.attributeStringValue(forName: "type"){
            if type == "subscribe"{
                let jid = XMPPJID(string: presence.attributeStringValue(forName: "from"))
                let p = XMPPPresence(type: "subscribed", to: jid?.bare())
                XMPPWorker.xmppStream.send(p)
            }
        }
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive iq: XMPPIQ!) -> Bool {
        return true
    }
    
    //  MARK: - Initial Message Center
    class func initialMessageCenter(){
        /*
        var fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("User", inManagedObjectContext: MDataProvider.mainMOC())
        fetchRequest.predicate = NSPredicate(format: "uid!=\(MDataProvider.myUID()?.toInt() ?? 0) && uid>0 && lastcontact>\(NSDate(timeIntervalSince1970: 0))")
        fetchRequest.includesPropertyValues = false
        
        var messageInserted = NSUserDefaults.standardUserDefaults().boolForKey("MessagesInserted")
        var users = MDataProvider.mainMOC().executeFetchRequest(fetchRequest, error: nil)
        
        if (users?.count ?? 0) > 0 && !messageInserted{
            if let messages = NSArray(contentsOfFile: "messages.plist".bundlePath()) as? [NSDictionary]{
                for msg in messages{
                    var uid = msg.objectForKey("uid") as! String
                    
                    var message = XMPPMessage(type: "chat")

                    var body = DDXMLElement(name: "body", stringValue: msg.objectForKey("content") as! String)
                    message.addChild(body)
                    
                    message.addAttributeWithName("from", stringValue: "\(uid)@\(kChatServerDomain)")
                    
                    XMPPWorker.sharedWorker.xmppStream(xmppStream, didReceiveMessage: message)

                }
            }
        }
*/
    }
    
    //  MARK: - XMPPAutoReconnect Delegate
    func xmppReconnect(_ sender: XMPPReconnect!, didDetectAccidentalDisconnect connectionFlags: SCNetworkConnectionFlags) {
        NSLog("XMPP Detected Disconnect")
    }
    
    func xmppReconnect(_ sender: XMPPReconnect!, shouldAttemptAutoReconnect connectionFlags: SCNetworkConnectionFlags) -> Bool {
        return true
    }
    
    //  MARK: - XMPPAutoPing Delegate
    func xmppAutoPingDidTimeout(_ sender: XMPPAutoPing!) {
        SWUtils.RunOnMainThread { () -> Void in
            if MDataProvider.networkAvailable(){
                XMPPWorker.connect()
            }else{
                XMPPWorker.disconnect()
            }
        }
    }
    
    //  MARK: - XMPPBlocking Delegate
    func xmppBlocking(_ sender: XMPPBlocking!, didBlockJID xmppJID: XMPPJID!) {
        NSLog("%@ Blocked", xmppJID)
    }
    
    func xmppBlocking(_ sender: XMPPBlocking!, didUnblockJID xmppJID: XMPPJID!) {
        NSLog("%@ Unblocked", xmppJID)
    }
    
    func xmppBlocking(_ sender: XMPPBlocking!, didReceivedBlockingList blockingList: [Any]!) {
        NSLog("Blocking List:%@", blockingList)
    }
    
    func xmppBlocking(_ sender: XMPPBlocking!, didNotBlockJID xmppJID: XMPPJID!, error: Any!) {
        NSLog("Not Block Error:\(error)")
    }
    
    func xmppBlocking(_ sender: XMPPBlocking!, didNotUnblockJID xmppJID: XMPPJID!, error: Any!) {
        NSLog("Not Unblock Error:\(error)")
    }
}
