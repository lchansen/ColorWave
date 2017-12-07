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
import Alamofire

struct GenreData {
    
}


class ViewController: UIViewController, BridgeFinderDelegate, BridgeAuthenticatorDelegate, CollectionViewDelegate, CollectionViewDataSource {
    var dataSourceItems: [DataSourceItem] = []
    let reuseIdentifier = "CollectCell"
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSourceItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell:GenreCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier:reuseIdentifier, for: indexPath) as! GenreCollectionViewCell
        cell.initWithParams()
        return cell
    }
    
    
    var swiftyHue: SwiftyHue = SwiftyHue()
    fileprivate let bridgeAccessConfigUserDefaultsKey = "BridgeAccessConfig"
    fileprivate let bridgeFinder = BridgeFinder()
    fileprivate var bridgeAuthenticator: BridgeAuthenticator?
    @IBOutlet weak var bridgeStatus: UILabel!
    var bridge:HueBridge? = nil
    var lights = Array<String>()
    @IBOutlet weak var numLightsLabel: UILabel!
    
    @IBOutlet weak var refreshButton: Button!
    @IBOutlet weak var runTestButton: Button!
    @IBOutlet weak var miscButton: FABButton!
    @IBOutlet weak var genreCollectionView: UICollectionView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        genreCollectionView.delegate = self
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "gradient")!)
//        let buttonColor = UIColor(red:0.01, green:0.66, blue:0.96, alpha:1.0)
        refreshButton.backgroundColor = Color.blue.base
        runTestButton.backgroundColor = Color.blue.base
        refreshButton.pulseColor = .white
        runTestButton.pulseColor = .white
        miscButton.pulseColor = .white
        miscButton.backgroundColor = Color.red.base
        
//        refreshButton.titleLabel?
//        runTestButton.titleColor = UIColor.white
        
        swiftyHue.enableLogging(true)
        
        if let _ = readBridgeAccessConfig() {
            print("found existing hue config")
            runConnect()
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
        runConnect()
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
    @IBAction func refreshLights() {
        swiftyHue.resourceAPI.fetchLights{
            (result: Result<[String:Light]>) in
            print("resource api fetchLights")
            if let keys = result.value?.keys{
                self.lights = Array(keys)
                print(self.lights)
                self.numLightsLabel.text = String(self.lights.count)
            }
        }
    }
    @IBAction func runTest() {
        var lightState = LightState()
        lightState.on = false;
        lightState.transitiontime = 0
        swiftyHue.bridgeSendAPI.setLightStateForGroupWithId("0", withLightState: lightState) { (errors) in
            print(errors ?? "")
        }
        
        var when = DispatchTime.now() + 2 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            var lightState = LightState()
            lightState.on = true;
            lightState.transitiontime = 0
            lightState.brightness = 254
            let xy = HueUtilities.calculateXY(SwiftyHueColor.blue, forModel: "LCT001")
            lightState.xy = [Float(xy.x), Float(xy.y)]
            
            
            self.swiftyHue.bridgeSendAPI.setLightStateForGroupWithId("0", withLightState: lightState) { (errors) in
                if let err = errors{
                    print(err)
                }
            }
        }
        
        when = DispatchTime.now() + 5 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            var lightState = LightState()
            lightState.on = true;
            lightState.transitiontime = 2 //10*100ms
            lightState.brightness = 254
            let xy = HueUtilities.calculateXY(SwiftyHueColor.white, forModel: "LCT001")
            lightState.xy = [Float(xy.x), Float(xy.y)]
            
            
            self.swiftyHue.bridgeSendAPI.setLightStateForGroupWithId("0", withLightState: lightState) { (errors) in
                if let err = errors{
                    print(err)
                }
            }
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
    
    @IBAction func lightOffTest(_ sender: Any) {
        var lightState = LightState()
        lightState.on = false
        lightState.transitiontime = 0
        swiftyHue.bridgeSendAPI.updateLightStateForId("6", withLightState: lightState){ (error) in if let err=error{print(err)}}
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
    
    func runConnect(){
        let bac = self.readBridgeAccessConfig()!
        swiftyHue.setBridgeAccessConfig(bac)
        print("connected")
        bridgeStatus.text = bac.ipAddress
        refreshLights()
        swiftyHue.setLocalHeartbeatInterval(10, forResourceType: .lights)
        swiftyHue.startHeartbeat();
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.lightChanged), name: NSNotification.Name(rawValue: ResourceCacheUpdateNotification.lightsUpdated.rawValue), object: nil)
    }
    
    @objc public func lightChanged() {
        print("Changed")
    }
    
}







