//
//  PhotoModule.swift
//  WallPaperForUnsplash
//
//  Created by great Lock on 2017/12/17.
//  Copyright © 2017年 great Lock. All rights reserved.
//

import Cocoa
import SwiftyJSON

class PhotoModule: NSObject {
    var id: String
    var downloadUrl: String
    
    init(json: JSON) {
        id = json["id"].string!
        downloadUrl = json["urls"]["raw"].string!
        
        
    }

    func writeToLocalPath(json: JSON) {
        let resultJson = ["id": json["id"].string!,
                          "urls":json["urls"].dictionaryObject!] as [String : Any]
        let jsonPath = "/Users/greatlock/files/wallpaper/parpers.plist"
        let localArr = NSMutableArray(contentsOfFile: jsonPath)
        if let resultArr = localArr {
            resultArr.add(resultJson)
            let isSuccess = resultArr.write(toFile: jsonPath, atomically: true)
            if !isSuccess {
                print("error \(String(describing: json.dictionaryObject))")
            }
        }else{
            let resultArr = NSMutableArray()
            resultArr.add(resultJson)
            let isSuccess = resultArr.write(toFile: jsonPath, atomically: true)
            if !isSuccess {
                print("error \(String(describing: json.dictionaryObject))")
            }
        }

    }
}
