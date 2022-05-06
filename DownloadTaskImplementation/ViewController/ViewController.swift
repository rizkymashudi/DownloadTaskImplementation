//
//  ViewController.swift
//  DownloadTaskImplementation
//
//  Created by Rizky Mashudi on 06/05/22.
//

import UIKit

class ViewController: UIViewController {
  
  let progressView: UIProgressView = {
    let v = UIProgressView()
    v.translatesAutoresizingMaskIntoConstraints = false
    
    return v
  }()
  
  let messageView: UILabel = {
    let v = UILabel()
    v.textAlignment = .center
    v.translatesAutoresizingMaskIntoConstraints = false
    
    return v
  }()
  
  lazy var btnDownload: UIButton = {
    let v = UIButton(type: .roundedRect)
    v.setTitle("Download", for: .normal)
    v.translatesAutoresizingMaskIntoConstraints = false
    v.addTarget(self, action: #selector(downloadFile), for: .touchUpInside)
    
    return v
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    downloadProgress()
    
  }
  
  private func setupView(){
    view.addSubview(progressView)
    view.addSubview(messageView)
    view.addSubview(btnDownload)
    
    NSLayoutConstraint.activate([
      progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      progressView.widthAnchor.constraint(equalToConstant: 200),
      progressView.heightAnchor.constraint(equalToConstant: 20),
      
      messageView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 5),
      messageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      messageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      
      btnDownload.topAnchor.constraint(equalTo: messageView.bottomAnchor, constant: 20),
      btnDownload.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
  }
  
  private func downloadProgress(){
    let _ = DownloadManager.shared.session    //call instance singleton DownloadManager
    
    //Download implementation
    DownloadManager.shared.progress = { (totalBytesWritten, totalBytesExpectedToWrite) in
      //Convert total bytes expected to MB
      let totalMB = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .binary)
      
      //Convert total bytes written to MB
      let writtenMB = ByteCountFormatter.string(fromByteCount: totalBytesWritten, countStyle: .binary)
      
      //Count progress downloaded
      let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
      
      //Update to UI in main thread
      DispatchQueue.main.async {
        self.btnDownload.isEnabled = false
        self.progressView.progress = progress
        self.messageView.text = "Downloading \(writtenMB) of \(totalMB)"
      }
    }
    
    //Implement completion handlers from DownloadManager
    //delete from downloaded file
    DownloadManager.shared.completed = { (location) in
      print("Download Finished")
      
      try? FileManager.default.removeItem(at: location)
      DispatchQueue.main.async {
        self.btnDownload.isEnabled = true
      }
    }
    
    //Implement error Handler from DownloadManager
    DownloadManager.shared.downloadError = { (task, error) in
      print("Task completed: \(task), error: \(error)")
    }
  }

  @objc private func downloadFile() {
    let url = URL(string: "http://212.183.159.230/50MB.zip")
    let task = DownloadManager.shared.session.downloadTask(with: url!)
    task.resume()
  }

}

