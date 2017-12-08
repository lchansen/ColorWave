//
//  ViewController.swift
//  ColorWave
//
//  Created by Luke Hansen on 12/6/17.
//  Copyright © 2017 SMU. All rights reserved.
//

import UIKit
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
    @IBOutlet weak var genreCollectionView: UICollectionView!
    @IBOutlet weak var runAudioBtn: RaisedButton!
    @IBOutlet weak var predLabel: UILabel!
    var partyModeActive:Bool = false
    @IBOutlet weak var allOffButton: RaisedButton!
    @IBOutlet weak var allOnButton: RaisedButton!
    var activeColors = Array<UIColor>()
    var palattes = Array<GenreData>()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        audioObj.initialize(self as UIViewController)
        swiftyHue.enableLogging(true)
        palattes = Array(GenreColorModel.sharedInstance.palattes.values)
        predLabel.text = "Any"
        genreCollectionView.delegate = self
        genreCollectionView.dataSource = self
        genreCollectionView.register(UINib(nibName: "GenreCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GenreCollectionViewCell")
        let topBorder = CALayer() //
        topBorder.frame = CGRect(x: 0.0, y: self.predLabel.layer.frame.bounds.maxY, width: self.view.frame.width, height: 1)
        topBorder.backgroundColor = UIColor.black.cgColor
        predLabel.layer.addSublayer(topBorder)
        view.backgroundColor = UIColor(patternImage: UIImage(named: "gradient")!)
        runAudioBtn.backgroundColor = Color.blue.base
        runAudioBtn.pulseColor = .white
        runAudioBtn.titleColor = Color.white
        runAudioBtn.title = "Run Audio"
        allOffButton.pulseColor = .white
        allOnButton.pulseColor = .white
        allOffButton.titleColor = Color.white
        allOnButton.titleColor = Color.white
        allOffButton.backgroundColor = Color.blue.base
        allOnButton.backgroundColor = Color.blue.base
        
        if let set = GenreColorModel.sharedInstance.palattes[predLabel.text!]{
            activeColors = Array(set.colors)
        }
        
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
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    //Fetch updates palattes from the sharedInstance
    func reloadPalattes(){
        palattes = Array(GenreColorModel.sharedInstance.palattes.values)
        genreCollectionView.reloadData()
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
    
    // MARK: - UIGestureRecognizerDelegate
    //Single tap selects genre as the 'active' color palatte
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        let senderView = sender?.view as! GenreCollectionViewCell
        self.predLabel.text = senderView.genreData.name
        if let set = GenreColorModel.sharedInstance.palattes[predLabel.text!]{
            activeColors = Array(set.colors)
        } else {
            print("handle tap broke!!!!!!!")
        }
        
    }
    
    //Double tap opens modal to edit the genre's color scheme
    @objc func handleDoubleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
        print("handled double tap")
        let senderView = sender?.view as! GenreCollectionViewCell
        print(senderView.genreData.name)
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GenreConfigModalID") as! GenreConfigModalViewController
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        popOverVC.setGenreData(gd: senderView.genreData, vc: self)

    }
    
    // MARK: - Light change/transition handlers (called from objective c)
    
    var activeBassIndex = 0 //keep changing a number so we cycle between colors
    @objc func stepColorBass(){
        //there may still be pending transitions if the queue in objc is backed up
        if(!self.partyModeActive){
            return
        }
        let usableLights = self.lights[0..<self.lights.count/2]
        let randomInt = Int(arc4random_uniform(UInt32(usableLights.count)))
        let randomLight = usableLights[randomInt]
        
        var lightState = LightState()
        lightState.on = true;
        lightState.brightness = 254
        lightState.transitiontime = 0
        let xy = HueUtilities.calculateXY(activeColors[activeBassIndex%activeColors.count], forModel: "LCT001")
        lightState.xy = [Float(xy.x), Float(xy.y)]
        activeBassIndex+=1
        
        swiftyHue.bridgeSendAPI.updateLightStateForId(randomLight, withLightState: lightState){ (error) in
            print(error ?? "")
        }
    }
    
    var activeMidIndex = 0
    @objc func stepColorMid(){
        //there may still be pending transitions if the queue in objc is backed up
        if(!self.partyModeActive){
            return
        }
        let usableLights = self.lights[(self.lights.count/2)...]
        let randomInt = Int(arc4random_uniform(UInt32(usableLights.count)))
        let randomLight = usableLights[randomInt+(self.lights.count/2)]
        
        var lightState = LightState()
        lightState.on = true;
        lightState.brightness = 254
        lightState.transitiontime = 1
        let xy = HueUtilities.calculateXY(activeColors[activeMidIndex%activeColors.count], forModel: "LCT001")
        lightState.xy = [Float(xy.x), Float(xy.y)]
        activeMidIndex+=1
        
        swiftyHue.bridgeSendAPI.updateLightStateForId(randomLight, withLightState: lightState){ (error) in
            print(error ?? "")
        }
    }
    
    @objc func updatePrediction(genre:String){
        self.predLabel.text = genre;
        //TODO: change current colors array
    }
    
    @IBAction func runAudioPressed(_ sender: Any) {
        if(self.runAudioBtn.title! == "Run Audio"){
            self.partyModeActive = true
            self.runAudioBtn.title = "Stop Audio" as String?
            self.audioObj.start()
        }else if(self.runAudioBtn.title! == "Stop Audio"){
            self.partyModeActive = false
            self.runAudioBtn.title = "Run Audio"
            self.audioObj.stop()
        } else {
            print("idk fam")
        }
    }
    
    //MARK - BridgeFinderDelegate, BridgeAuthenticatorDelegate
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
        bridgeAuthenticator = BridgeAuthenticator(bridge: bridge!, uniqueIdentifier: "swiftyhue#\(UIDevice.current.name)")
        bridgeAuthenticator?.delegate = self
        bridgeAuthenticator?.start()
    }
    
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
    
    //    @objc public func lightChanged() {
    //        //HeartBeat (when enabled), check to see if other apps have changed our light state
    //        print("Changed")
    //    }
    
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
    func runTest() {
        var lightState = LightState()
        lightState.on = false;
        lightState.transitiontime = 0
        swiftyHue.bridgeSendAPI.setLightStateForGroupWithId("0", withLightState: lightState) { (errors) in
            print(errors ?? "")
        }
        
        var when = DispatchTime.now() + 2
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
        
        when = DispatchTime.now() + 4
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
    
    //MARK - Provide some usability features
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







