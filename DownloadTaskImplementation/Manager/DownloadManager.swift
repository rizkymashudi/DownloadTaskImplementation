//
//  DownloadManager.swift
//  DownloadTaskImplementation
//
//  Created by Rizky Mashudi on 06/05/22.
//

import Foundation
import UIKit

class DownloadManager: NSObject {
  static var shared = DownloadManager()
  
  //create 3 handlers
  var progress: ((Int64, Int64) -> ())? //to measure download progress
  var completed: ((URL) -> ())?         //to tell if download finished
  var downloadError: ((URLSessionTask, Error?) -> ())? //download process error
  
  lazy var session: URLSession = {
    let config = URLSessionConfiguration.background(withIdentifier: "com.rmwashere.downloadTask")
    config.isDiscretionary = false
    
    return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
  }()
  
}

extension DownloadManager: URLSessionDelegate, URLSessionDownloadDelegate {
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    //validate total byte to assign byte on progress handler
    if totalBytesExpectedToWrite > 0 {
      progress?(totalBytesWritten, totalBytesExpectedToWrite)
    }
  }
  
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    completed?(location)
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    downloadError?(task, error)
  }
  
  
}
