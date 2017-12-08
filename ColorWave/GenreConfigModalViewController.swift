//
//  GenreConfigModalViewController.swift
//  ColorWave
//
//  Created by Luke Hansen on 12/7/17.
//  Copyright © 2017 SMU. All rights reserved.
//

import UIKit
import Material

class GenreConfigModalViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: selectableColorCellIdentifier, for: indexPath) as! ColorCellSelectable
        let color = allColors[indexPath.row]
        cell.backgroundColor = color
        if(genreData.colors.contains(color)){
            //place a ring around it to kniw its selected
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 4.0
        } else {
            cell.layer.borderWidth = 0
        }
        return cell as UICollectionViewCell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected item")
        let selectedColor = allColors[indexPath.row]
        if(genreData.colors.contains(selectedColor)){
            //if we have the color, remove it
            genreData.colors.remove(selectedColor)
        } else {
            genreData.colors.insert(selectedColor)
        }
        gcm.palattes[genreData.name] = genreData
        collectionView.reloadData()
        
    }
    
    
    @IBOutlet weak var cardView: UIView!
    
    var genreData = GenreData()
    
    @IBOutlet weak var doneButton: RaisedButton!
    @IBOutlet weak var genreLabel: UILabel!
    
    @IBOutlet weak var colorSelectorCollection: UICollectionView!
    let selectableColorCellIdentifier = "scci"
    var gcm = GenreColorModel.sharedInstance
    var allColors = Array<UIColor>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.allColors = Array(gcm.colorOptions)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        // Do any additional setup after loading the view.
        self.doneButton.backgroundColor = Color.blue.base
        self.doneButton.titleColor = UIColor.white
        self.cardView.backgroundColor = Color.grey.lighten2
        self.cardView.layer.cornerRadius = 5.0;
        self.colorSelectorCollection.delegate = self
        self.colorSelectorCollection.dataSource = self
        self.colorSelectorCollection.register(UINib(nibName:"ColorCellSelectable", bundle: nil), forCellWithReuseIdentifier: selectableColorCellIdentifier)
        self.colorSelectorCollection.backgroundColor = UIColor.clear
        //self.colorSelectorCollection.reloadData()
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
