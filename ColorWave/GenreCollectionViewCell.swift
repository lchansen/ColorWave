//
//  GenreCollectionViewCell.swift
//  ColorWave
//
//  Created by Luke Hansen on 12/7/17.
//  Copyright © 2017 SMU. All rights reserved.
//

import UIKit
import Material

class GenreCollectionViewCell: CollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genreData.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        genreData.colors.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
        let btn = FABButton()
        btn.frame.size = CGSize(width: 20.0, height: 20.0)
        btn.isEnabled = false
        btn.backgroundColor = Array(self.genreData.colors)[indexPath.row]
        cell.addSubview(btn)
        
        return cell
    }
    
    
    @IBOutlet var genreLabel: UILabel!
    @IBOutlet var colorsCollectionView: UICollectionView!
    
    
    var genreData:GenreData = GenreData()

    override init(frame: CGRect) {
        super.init(frame: frame)
        print("frame")
        print(frame)
        self.frame.size = CGSize(width: 150.0, height: 75.0)
        colorsCollectionView.register(UINib(nibName: "ColorCell", bundle: nil), forCellWithReuseIdentifier: "ColorCell")
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func initWithData(_ data:GenreData){
        self.genreData = data
        self.genreLabel?.text = self.genreData.name
        self.colorsCollectionView.delegate = self
        self.colorsCollectionView.dataSource = self
        self.colorsCollectionView.reloadData()
        
    }
    
}
