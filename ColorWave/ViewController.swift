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

@objc public class ViewController: UIViewController, BridgeFinderDelegate, BridgeAuthenticatorDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate{
    var dataSourceItems: [DataSourceItem] = [DataSourceItem()]
    var audioObj: AudioProcessor = AudioProcessor()
    var swiftyHue: SwiftyHue = SwiftyHue()
    fileprivate let bridgeAccessConfigUserDefaultsKey = "BridgeAccessConfig"
    fileprivate let bridgeFinder = BridgeFinder()
    fileprivate var bridgeAuthenticator: BridgeAuthenticator?
    @IBOutlet weak var bridgeStatus: UILabel!
    var bridge:HueBridge? = nil
    var lights = Array<String>()
    @IBOutlet weak var numLightsLabel: UILabel!
    @IBOutlet weak var runTestButton: Button!
    @IBOutlet weak var genreCollectionView: UICollectionView!
    @IBOutlet weak var runAudioBtn: RaisedButton!
    var activeColorIndex = 0
    @IBOutlet weak var predLabel: UILabel!
    var partyModeActive:Bool = false
    @IBOutlet weak var allOffButton: RaisedButton!
    @IBOutlet weak var allOnButton: RaisedButton!
    var activeColors = Array<UIColor>()
    var palattes = Array<GenreData>()
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        audioObj.initialize(self as UIViewController)
        
        palattes = Array(GenreColorModel.sharedInstance.palattes.values)
        
        self.predLabel.text = "Any"
        
        genreCollectionView.delegate = self
        genreCollectionView.dataSource = self
        genreCollectionView.register(UINib(nibName: "GenreCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GenreCollectionViewCell")
//        genreCollectionView.reloadData()
        let topBorder = CALayer() //
        topBorder.frame = CGRect(x: 0.0, y: self.predLabel.layer.frame.bounds.maxY, width: self.view.frame.width, height: 1)
        topBorder.backgroundColor = UIColor.black.cgColor
        self.predLabel.layer.addSublayer(topBorder)
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "gradient")!)
        runTestButton.backgroundColor = Color.blue.base
        runTestButton.pulseColor = .white
        runAudioBtn.backgroundColor = Color.blue.base
        runAudioBtn.pulseColor = .white
        runTestButton.titleColor = Color.white
        runAudioBtn.titleColor = Color.white
        runAudioBtn.title = "Run Audio"
        allOffButton.pulseColor = .white
        allOnButton.pulseColor = .white
        allOffButton.titleColor = Color.white
        allOnButton.titleColor = Color.white
        allOffButton.backgroundColor = Color.blue.base
        allOnButton.backgroundColor = Color.blue.base
        
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
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GenreColorModel.sharedInstance.palattes.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:GenreCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier:"GenreCollectionViewCell", for: indexPath) as! GenreCollectionViewCell
        cell.initWithData(palattes[indexPath.row])
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = Color.grey.darken2.cgColor
        cell.layer.borderWidth = 2.0
        cell.backgroundColor = UIColor.clear
        cell.layer.cornerRadius = cell.frame.size.width/10;
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        cell.addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.handleDoubleTap(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        cell.addGestureRecognizer(doubleTap)
        
        tap.require(toFail: doubleTap)
        return cell
    }
    
    @objc func handleDoubleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
        print("handled double tap")
        let senderView = sender?.view as! GenreCollectionViewCell
        print(senderView.genreData.name)
        //        let modal = GenreConfigModalViewController()
        //        let navController = UINavigationController(rootViewController: modal)
        //        self.present(navController, animated: true, completion: nil)
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GenreConfigModalID") as! GenreConfigModalViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        popOverVC.setGenreData(gd: senderView.genreData)

    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        let senderView = sender?.view as! GenreCollectionViewCell
        self.predLabel.text = senderView.genreData.name
        if let set = GenreColorModel.sharedInstance.palattes[predLabel.text!]{
            activeColors = Array(set.colors)
        } else {
            print("handle tap broke!!!!!!!")
        }
        
    }
    @objc func stepColorBass(){
        if(!self.partyModeActive){
            return
        }
        var lightState = LightState()
        lightState.on = true;
        lightState.brightness = 254
        lightState.transitiontime = 0
        print("predLabel")
        print(predLabel.text!)
        let xy = HueUtilities.calculateXY(activeColors[activeColorIndex%activeColors.count], forModel: "LCT001")
        lightState.xy = [Float(xy.x), Float(xy.y)]
        activeColorIndex+=1
        swiftyHue.bridgeSendAPI.setLightStateForGroupWithId("0", withLightState: lightState) { (errors) in
            print(errors ?? "")
        }
        
        
    }
    @objc func updatePrediction(genre:String){
        self.predLabel.text = genre;
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func runAudioPressed(_ sender: Any) {
        print("title")
        print(self.runAudioBtn.title!)
        if(self.runAudioBtn.title! == "Run Audio"){
            self.partyModeActive = true
            self.runAudioBtn.title = "Stop Audio" as String?
            self.audioObj.start()
        }else if(self.runAudioBtn.title! == "Stop Audio"){
            self.partyModeActive = false
            self.runAudioBtn.title = "Run Audio"
            self.audioObj.stop()
            
        } else {
            print("idk lol")
        }
        
    }
    
    
    public func bridgeFinder(_ finder: BridgeFinder, didFinishWithResult bridges: [HueBridge]) {
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
    
    public func bridgeAuthenticator(_ authenticator: BridgeAuthenticator, didFinishAuthentication username: String) {
        bridgeStatus.text = "Connected"
        print("Connected with username: ", username)
        let bac = BridgeAccessConfig(bridgeId: "BridgeId", ipAddress: (bridge?.ip)!, username: username)
        self.writeBridgeAccessConfig(bridgeAccessConfig: bac)
        runConnect()
    }
    
    public func bridgeAuthenticator(_ authenticator: BridgeAuthenticator, didFailWithError error: NSError) {
        bridgeStatus.text = "Failed to Connect"
        print("Failed to Connect")
    }
    
    public func bridgeAuthenticatorRequiresLinkButtonPress(_ authenticator: BridgeAuthenticator, secondsLeft: TimeInterval) {
        bridgeStatus.text = "Press link button"
        print("Press link button")
    }
    
    public func bridgeAuthenticatorDidTimeout(_ authenticator: BridgeAuthenticator) {
        bridgeStatus.text = "Timeout"
        print("Timeout")
    }
    func refreshLights() {
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
    }
    
    @IBAction func allOffPressed(_ sender: Any) {
        var lightState = LightState()
        lightState.on = false
        lightState.transitiontime = 5
        swiftyHue.bridgeSendAPI.setLightStateForGroupWithId("0", withLightState: lightState) { (errors) in
            print(errors ?? "")
            NSLog("end send")
        }
    }
    
    @IBAction func allOnPressed(_ sender: Any) {
        var lightState = LightState()
        lightState.on = true
        lightState.brightness = 254
        lightState.transitiontime = 5
        let xy = HueUtilities.calculateXY(UIColor.white, forModel: "LCT001")
        lightState.xy = [Float(xy.x), Float(xy.y)]
        swiftyHue.bridgeSendAPI.setLightStateForGroupWithId("0", withLightState: lightState) { (errors) in
            print(errors ?? "")
            NSLog("end send")
        }
    
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
//        swiftyHue.setLocalHeartbeatInterval(10, forResourceType: .lights)
//        swiftyHue.startHeartbeat();
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.lightChanged), name: NSNotification.Name(rawValue: ResourceCacheUpdateNotification.lightsUpdated.rawValue), object: nil)
    }
    
    @objc public func lightChanged() {
        print("Changed")
    }
    
}







