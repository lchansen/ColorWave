//
//  ColorModel.swift
//  ColorWave
//
//  Created by Luke Hansen on 12/7/17.
//  Copyright © 2017 SMU. All rights reserved.
//

import UIKit
import Material

@objc public class GenreData: NSObject {
    var name:String = ""
    var colors:Set<UIColor> = Set<UIColor>()
    override init(){
    }
    init(withName name:String, colors:Set<UIColor>){
        self.name = name;
        self.colors = colors
    }
}

class GenreColorModel {
    static let sharedInstance = GenreColorModel()
    var palattes:Dictionary = [String:GenreData]()
    var colorOptions = Set<UIColor>()
    init(){
        colorOptions.insert(Color.amber.base)
        colorOptions.insert(Color.blue.base)
        colorOptions.insert(Color.cyan.base)
        colorOptions.insert(Color.deepPurple.accent1)
        colorOptions.insert(Color.pink.darken1)
        colorOptions.insert(Color.lime.accent1)
        colorOptions.insert(Color.yellow.accent2)
        colorOptions.insert(Color.red.darken1)
        colorOptions.insert(Color.deepOrange.base)
        colorOptions.insert(Color.white)
        
        //Any
        var anyColors = Set<UIColor>()
        anyColors.insert(Color.amber.base)
        anyColors.insert(Color.blue.base)
        anyColors.insert(Color.cyan.base)
        anyColors.insert(Color.deepPurple.accent1)
        anyColors.insert(Color.pink.darken1)
        anyColors.insert(Color.lime.accent1)
        anyColors.insert(Color.yellow.accent2)
        anyColors.insert(Color.red.darken1)
        anyColors.insert(Color.deepOrange.base)
        anyColors.insert(Color.white)
        palattes["Any"] = GenreData(withName: "Any", colors: anyColors)
        
        var electronicColors = Set<UIColor>()
        electronicColors.insert(Color.blue.base)
        electronicColors.insert(Color.cyan.base)
        electronicColors.insert(Color.deepPurple.accent1)
        electronicColors.insert(Color.pink.darken1)
        electronicColors.insert(Color.lime.accent1)
        electronicColors.insert(Color.red.darken1)
        electronicColors.insert(Color.deepOrange.base)
        palattes["Electronic"] = GenreData(withName: "Electronic", colors: electronicColors)
        
        var experimentalColors = Set<UIColor>()
        experimentalColors.insert(Color.cyan.base)
        experimentalColors.insert(Color.deepPurple.accent1)
        experimentalColors.insert(Color.pink.darken1)
        experimentalColors.insert(Color.lime.accent1)
        palattes["Experimental"] = GenreData(withName: "Experimental", colors: experimentalColors)

        var folkColors = Set<UIColor>()
        folkColors.insert(Color.blue.base)
        folkColors.insert(Color.red.darken1)
        folkColors.insert(Color.white)
        palattes["Folk"] = GenreData(withName: "Folk", colors: folkColors)
        
        var hiphopColors = Set<UIColor>()
        hiphopColors.insert(Color.amber.base)
        hiphopColors.insert(Color.blue.base)
        hiphopColors.insert(Color.red.darken1)
        hiphopColors.insert(Color.deepOrange.base)
        hiphopColors.insert(Color.white)
        palattes["Hip-Hop"] = GenreData(withName: "Hip-Hop", colors: hiphopColors)

        var instrumentalColors = Set<UIColor>()
        instrumentalColors.insert(Color.blue.base)
        instrumentalColors.insert(Color.cyan.base)
        instrumentalColors.insert(Color.lime.accent1)
        instrumentalColors.insert(Color.yellow.accent2)
        instrumentalColors.insert(Color.red.darken1)
        instrumentalColors.insert(Color.white)
        palattes["Instrumental"] = GenreData(withName: "Instrumental", colors: instrumentalColors)

        var internationalColors = Set<UIColor>()
        anyColors.insert(Color.amber.base)
        anyColors.insert(Color.pink.darken1)
        anyColors.insert(Color.red.darken1)
        anyColors.insert(Color.deepOrange.base)
        anyColors.insert(Color.white)
        palattes["International"] = GenreData(withName: "International", colors: anyColors)
        
        var popColors = Set<UIColor>()
        popColors.insert(Color.cyan.base)
        popColors.insert(Color.deepPurple.accent1)
        popColors.insert(Color.pink.darken1)
        popColors.insert(Color.lime.accent1)
        palattes["Pop"] = GenreData(withName: "Pop", colors: popColors)
        
        var rockColors = Set<UIColor>()
        rockColors.insert(Color.amber.base)
        rockColors.insert(Color.pink.darken1)
        rockColors.insert(Color.red.darken1)
        rockColors.insert(Color.deepOrange.base)
        palattes["Rock"] = GenreData(withName: "Rock", colors: rockColors)
    }
}
