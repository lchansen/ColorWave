//
//  GenreConfigModalViewController.swift
//  ColorWave
//
//  Created by Luke Hansen on 12/7/17.
//  Copyright © 2017 SMU. All rights reserved.
//

import UIKit
import Material

class GenreConfigModalViewController: UIViewController {
    @IBOutlet weak var cardView: UIView!
    var genreData = GenreData()
    
    @IBOutlet weak var doneButton: RaisedButton!
    @IBOutlet weak var genreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        // Do any additional setup after loading the view.
        self.doneButton.backgroundColor = Color.blue.base
        self.doneButton.titleColor = UIColor.white
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func donePressed(_ sender: Any) {
        print("donepressed")
        self.view.removeFromSuperview()
    }
    
    func setGenreData(gd:GenreData){
        self.genreData = gd
        self.genreLabel?.text = self.genreData.name
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
