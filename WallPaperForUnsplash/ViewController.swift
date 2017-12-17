//
//  ViewController.swift
//  WallPaperForUnsplash
//
//  Created by great Lock on 2017/12/17.
//  Copyright © 2017年 great Lock. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

class ViewController: NSViewController {
    
    var photos = [PhotoModule]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    @IBAction func startDownloadDidTapped(_ sender: Any) {
        requestData(1)
    }
    
    
    func requestData(_ fromPageIndex: Int) {
        let parameters: Parameters = ["client_id": "fcb9e2337b4a3561b3e6b9ae3e85981ab223b1f3bdb9d50337843dad45332ea0",
                                      "per_page": 100,
//                                      "order_by": "popular",
                                      "page": fromPageIndex]
        Alamofire.request("https://api.unsplash.com/photos/", method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                let jsonArr = JSON(response.result.value as Any)
                self.parserJsonArr(jsonArr: jsonArr)
                print("get json data,num : \(self.photos.count)")
                self.requestData(fromPageIndex + 1)
            } else {
                print("refresh data failed.")
                print("final count: \(self.photos.count)")
                self.startDownloadWallPapers()
            }
        }
    }
    
    private func parserJsonArr(jsonArr: JSON){
        for i in 0...jsonArr.count - 1 {
            let photoObj = PhotoModule(json: jsonArr[i])
            photoObj.writeToLocalPath(json: jsonArr[i])
            photos.append(photoObj)
        }
    }
    
    private func startDownloadWallPapers() {
        let jsonPath = "/Users/greatlock/files/wallpaper/parpers.plist"
        let localArr = NSArray(contentsOfFile: jsonPath) as! Array<Dictionary<String, Any>>
        downloadPapers(localArr: localArr)
    }
    
    private func downloadPapers(localArr: Array<Dictionary<String, Any>>) {
        if localArr.count == 0 {
            print("下载完毕")
            return;
        }
        
        let urlStr = (localArr[0]["urls"] as! Dictionary<String, String>)["raw"]!
        let url = URL.init(string: urlStr)!
        let destination = DownloadRequest.suggestedDownloadDestination(for: .picturesDirectory, in: .userDomainMask)
        Alamofire.download(url, to: destination)
            .responseData { (response) in
            if response.result.isSuccess {
                var mutableArr = localArr
                mutableArr.remove(at: 0)
                print("下载完毕! 剩余\(mutableArr.count)张")
                self.downloadPapers(localArr: mutableArr)
            } else {
                var mutableArr = localArr
                mutableArr.remove(at: 0)
                print("下载失败! 剩余\(mutableArr.count)张")
                self.downloadPapers(localArr: mutableArr)
            }
        }
    }
}

