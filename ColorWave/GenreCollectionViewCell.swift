//
//  GenreCollectionViewCell.swift
//  ColorWave
//
//  Created by Luke Hansen on 12/7/17.
//  Copyright © 2017 SMU. All rights reserved.
//

import UIKit
import Material

class GenreCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet var genreLabel: UILabel!
    @IBOutlet weak var colorCollection: UICollectionView!
    let colorCellIdentifier = "colorCellIdentifier"
    var genreData:GenreData = GenreData()

    override init(frame: CGRect) {
        super.init(frame: frame)
        print("frame")
        print(frame)
        self.frame.size = CGSize(width: 150.0, height: 75.0)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.genreLabel?.text = self.genreData.name
    }
    func initWithData(_ data:GenreData){
        self.genreData = data
        self.genreLabel?.text = self.genreData.name
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.colorCollection.delegate = self
        self.colorCollection.dataSource = self
        self.colorCollection.register(UINib(nibName:"ColorCell", bundle: nil), forCellWithReuseIdentifier: colorCellIdentifier)
        self.colorCollection.backgroundColor = UIColor.clear
        self.colorCollection.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.genreData.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.colorCollection.dequeueReusableCell(withReuseIdentifier: colorCellIdentifier, for: indexPath) as! ColorCell
        cell.backgroundColor = Array(self.genreData.colors)[indexPath.row]
        return cell as UICollectionViewCell
    }
}
