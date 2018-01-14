//
//  DownloadTaskQueue.swift
//  WallPaperForUnsplash
//
//  Created by great Lock on 2017/12/22.
//  Copyright © 2017年 great Lock. All rights reserved.
//

import Cocoa


class DownloadTask: NSObject {
    var runBlock: (_ taskId:String)->()?
    let taskID: String
    var running: Bool = false
    
    init(block: @escaping (_ taskId:String)->(), taskId:String) {
        self.runBlock = block
        taskID = taskId
    }
    
    public func run() {
        self.runBlock(taskID)
        self.running = true
    }
}

class DownloadTaskQueue: NSObject {
    var downloadQueue = NSMutableDictionary()
    var maxRunCount = 10
    var currentCount = 0
    init(maxTaskCount: Int) {
        maxRunCount = maxTaskCount
    }
    
    public func addTask(taskID:String, startBlock:@escaping (_ taskId:String)->()) {
        downloadQueue.setValue(DownloadTask(block: startBlock, taskId: taskID), forKey: taskID)
        runTask()
    }
    
    private func runTask() {
        if downloadQueue.count > 0 {
            for var i in (0..<downloadQueue.count).reversed() {
                let task: DownloadTask = downloadQueue.allValues[i] as! DownloadTask
                if currentCount < maxRunCount {
                    if !task.running {
                        currentCount = currentCount + 1
                        task.run()
                    }
                }else{
                    break
                }
            }
        }
    }
    
    public func endTask(taskID:String) {
        currentCount = currentCount - 1
        downloadQueue.removeObject(forKey: taskID)
        runTask()
    }
}


