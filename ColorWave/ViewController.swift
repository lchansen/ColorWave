//
//  ViewController.swift
//  ColorWave
//
//  Created by Oscar on 12/6/17.
//  Copyright © 2017 SMU.cse5323. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var myObject: AudioProcessor = AudioProcessor()
    var mfccArr = UnsafeMutablePointer<Float>.allocate(capacity: 13)
    
    

    var isActive = false
    
    
    override func viewDidLoad() {
        

        //myObject.setArrays(fftArr, mfccArr: mfccArr)
        //myObject.setUpdate(justPrintRandomShit)
        
//        print("fft1: ", String(fftArr[0]))
//        print("mfcc1: ", String(mfccArr[0]))
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func justPrintRandomShit(){
        print("RANDOMSHIT")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func activate(_ sender: Any) {
        myObject.start()
        isActive = !isActive
    }
    
}

