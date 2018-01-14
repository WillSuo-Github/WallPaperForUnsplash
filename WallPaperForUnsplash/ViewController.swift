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
    var allcount = 0
    var downloadQueue = DownloadTaskQueue(maxTaskCount: 100)
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
        requestData(2)
    }
    
    
    func requestData(_ fromPageIndex: Int) {
//        let parameters: Parameters = ["client_id": "fcb9e2337b4a3561b3e6b9ae3e85981ab223b1f3bdb9d50337843dad45332ea0",
//                                      "per_page": 100,
//                                      "order_by": "popular",
//                                      "page": fromPageIndex]
//        Alamofire.request("https://api.unsplash.com/photos/", method: .get, parameters: parameters).responseString { (response) in
//            if response.result.isSuccess {
//                let jsonArr = JSON(response.result.value as Any)
//                self.parserJsonArr(jsonArr: jsonArr)
//                print("get json data,num : \(self.photos.count)")
////                self.requestData(fromPageIndex + 1)
//                self.startDownloadWallPapers()
//            } else {
//                print("refresh data failed.")
//                print("final count: \(self.photos.count)")
//                self.startDownloadWallPapers()
//            }
//        }
        startDownloadWallPapers()
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
        var arr = NSArray(contentsOfFile: jsonPath) as! Array<Dictionary<String, Any>>
//        downloadPapers(localArr: localArr)
        allcount = arr.count
        for dict in arr {
            let taskID = dict["id"] as! String
            let urls: Dictionary = dict["urls"] as! Dictionary<String, String>
            let urlStr = urls["raw"] as! String
            downloadQueue.addTask(taskID: urlStr, startBlock: { (taskid) in
//                print(taskid)
//                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
//                    self.downloadQueue.endTask(taskID: taskid)
//                })
                self.downloadPapers(urlStr: taskid)
            })
        }
    }
    
    private func downloadPapers(urlStr: String) {
//        if localArr.count == 0 {
//            print("下载完毕")
//            return;
//        }
//
//        let urlStr = (localArr[0]["urls"] as! Dictionary<String, String>)["raw"]!
        let url = URL.init(string: urlStr)!
        let destination = DownloadRequest.suggestedDownloadDestination(for: .picturesDirectory, in: .userDomainMask)
        Alamofire.download(url, to: destination)
            .responseData { (response) in
            if response.result.isSuccess {
//                var mutableArr = localArr
//                mutableArr.remove(at: 0)
                self.allcount = self.allcount - 1
                print("下载完毕! 剩余\(self.allcount)张")
                self.downloadQueue.endTask(taskID: urlStr)
//                self.downloadPapers(localArr: mutableArr)
            } else {
//                var mutableArr = localArr
//                mutableArr.remove(at: 0)
                self.allcount = self.allcount - 1
                print("下载失败! 剩余\(self.allcount)张")
                self.downloadQueue.endTask(taskID: urlStr)
//                self.downloadPapers(localArr: mutableArr)
            }
        }
    }
}

