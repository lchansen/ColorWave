//
//  ViewController.swift
//  ColorWave
//
//  Created by Luke Hansen on 12/6/17.
//  Copyright © 2017 SMU. All rights reserved.
//

import UIKit
import Charts
import Material
import SwiftyHue
import Gloss

var swiftyHue: SwiftyHue = SwiftyHue()

class ViewController: UIViewController, BridgeFinderDelegate, BridgeAuthenticatorDelegate {
    
    fileprivate let bridgeAccessConfigUserDefaultsKey = "BridgeAccessConfig"
    
    fileprivate let bridgeFinder = BridgeFinder()
    fileprivate var bridgeAuthenticator: BridgeAuthenticator?
    @IBOutlet weak var bridgeStatus: UILabel!
    var bridge:HueBridge? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //swiftyHue.enableLogging(true)
        
        if let bridgeAccessConfig = readBridgeAccessConfig() {
            print("found existing hue config")
            runTestCode()
        } else {
            print("searching for hue config")
            bridgeFinder.delegate = self
            bridgeFinder.start()
            bridgeStatus.text = "Searching"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bridgeFinder(_ finder: BridgeFinder, didFinishWithResult bridges: [HueBridge]) {
        guard let b = bridges.first else {
            return
        }
        bridge = b
        print(bridge ?? "bridge not found")
        bridgeStatus.text = "Authenticating"
        bridgeFinder.delegate = nil;
        bridgeAuthenticator = BridgeAuthenticator(bridge: bridge!, uniqueIdentifier: "swiftyhue#\(UIDevice.current.name)")
        bridgeAuthenticator?.delegate = self
        bridgeAuthenticator?.start()
        
    }
    
    func bridgeAuthenticator(_ authenticator: BridgeAuthenticator, didFinishAuthentication username: String) {
        bridgeStatus.text = "Connected"
        print("Connected with username: ", username)
        let bac = BridgeAccessConfig(bridgeId: "BridgeId", ipAddress: (bridge?.ip)!, username: username)
        self.writeBridgeAccessConfig(bridgeAccessConfig: bac)
        runTestCode()
    }
    
    func bridgeAuthenticator(_ authenticator: BridgeAuthenticator, didFailWithError error: NSError) {
        bridgeStatus.text = "Failed to Connect"
        print("Failed to Connect")
    }
    
    func bridgeAuthenticatorRequiresLinkButtonPress(_ authenticator: BridgeAuthenticator, secondsLeft: TimeInterval) {
        bridgeStatus.text = "Press link button"
        print("Press link button")
    }
    
    func bridgeAuthenticatorDidTimeout(_ authenticator: BridgeAuthenticator) {
        bridgeStatus.text = "Timeout"
        print("Timeout")
    }


}

extension ViewController {
    
    func readBridgeAccessConfig() -> BridgeAccessConfig? {
        
        let userDefaults = UserDefaults.standard
        let bridgeAccessConfigJSON = userDefaults.object(forKey: bridgeAccessConfigUserDefaultsKey) as? JSON
        
        var bridgeAccessConfig: BridgeAccessConfig?
        if let bridgeAccessConfigJSON = bridgeAccessConfigJSON {
            
            bridgeAccessConfig = BridgeAccessConfig(json: bridgeAccessConfigJSON)
        }
        
        return bridgeAccessConfig
    }
    
    func writeBridgeAccessConfig(bridgeAccessConfig: BridgeAccessConfig) {
        
        let userDefaults = UserDefaults.standard
        let bridgeAccessConfigJSON = bridgeAccessConfig.toJSON()
        userDefaults.set(bridgeAccessConfigJSON, forKey: bridgeAccessConfigUserDefaultsKey)
    }
}

extension ViewController {
    
    func runTestCode() {
        let bac = self.readBridgeAccessConfig()!
        swiftyHue.setBridgeAccessConfig(bac)
        print("connected")
        bridgeStatus.text = "connected"
        
        swiftyHue.setLocalHeartbeatInterval(2, forResourceType: .lights)
        
        swiftyHue.startHeartbeat();
        
        var lightState = LightState()
        lightState.on = false;
        swiftyHue.bridgeSendAPI.setLightStateForGroupWithId("1", withLightState: lightState) { (errors) in

            print(errors)
        }
        
        //        var beatManager = BeatManager(bridgeAccessConfig: bridgeAccessConfig)
        //        beatManager.setLocalHeartbeatInterval(3, forResourceType: .Lights)
        //        beatManager.setLocalHeartbeatInterval(3, forResourceType: .Groups)
        //        beatManager.setLocalHeartbeatInterval(3, forResourceType: .Rules)
        //        beatManager.setLocalHeartbeatInterval(3, forResourceType: .Scenes)
        //        beatManager.setLocalHeartbeatInterval(3, forResourceType: .Schedules)
        //        beatManager.setLocalHeartbeatInterval(3, forResourceType: .Sensors)
        //        beatManager.setLocalHeartbeatInterval(3, forResourceType: .Config)
        //
        //        beatManager.startHeartbeat()
        //
        NotificationCenter.default.addObserver(self, selector: #selector(self.lightChanged), name: NSNotification.Name(rawValue: ResourceCacheUpdateNotification.lightsUpdated.rawValue), object: nil)
        
        //        var lightState = LightState()
        //        lightState.on = true
        
        //        BridgeSendAPI.updateLightStateForId("324325675tzgztztut1234434334", withLightState: lightState) { (errors) in
        //            print(errors)
        //        }
        
        //        BridgeSendAPI.setLightStateForGroupWithId("huuuuuuu1", withLightState: lightState) { (errors) in
        //
        //            print(errors)
        //        }
        
        //        BridgeSendAPI.createGroupWithName("TestRoom", andType: GroupType.LightGroup, includeLightIds: ["1","2"]) { (errors) in
        //
        //            print(errors)
        //        }
        
        //        BridgeSendAPI.removeGroupWithId("11") { (errors) in
        //
        //            print(errors)
        //        }
        
        //        BridgeSendAPI.updateGroupWithId("11", newName: "TestRoom234", newLightIdentifiers: nil) { (errors) in
        //
        //            print(errors)
        //        }
        
        
        //TestRequester.sharedInstance.requestScenes()
        
        //TestRequester.sharedInstance.requestSchedules()
        
        //        BridgeSendAPI.createSceneWithName("MeineTestScene", includeLightIds: ["1"]) { (errors) in
        //
        //            print(errors)
        //        }
        
        //TestRequester.sharedInstance.requestLights()
        //TestRequester.sharedInstance.getConfig()
        //TestRequester.sharedInstance.requestError()
        
        //        BridgeSendAPI.activateSceneWithIdentifier("14530729836055") { (errors) in
        //            print(errors)
        //        }
        
        //        BridgeSendAPI.recallSceneWithIdentifier("14530729836055", inGroupWithIdentifier: "2") { (errors) in
        //
        //            print(errors)
        //        }
        
        //        let xy = Utilities.calculateXY(UIColor.greenColor(), forModel: "LST001")
        //
        //        var lightState = LightState()
        //        lightState.on = true
        //        lightState.xy = [Float(xy.x), Float(xy.y)]
        //        lightState.brightness = 254
        //
        //        BridgeSendAPI.updateLightStateForId("6", withLightState: lightState) { (errors) in
        //            print(errors)
        //        }
    }
    
    @objc public func lightChanged() {
        
        print("Changed")
        
        //        var cache = BridgeResourcesCacheManager.sharedInstance.cache
        //        var light = cache.groups["1"]!
        //        print(light.name)
    }
}





