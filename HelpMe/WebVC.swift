//
//  ViewController.swift
//  TestSpeed
//
//  Created by DerekYang on 2017/12/28.
//  Copyright © 2017年 LBD. All rights reserved.
//

import UIKit
import WebKit

class WebVC: UIViewController {
    
    var webView: WKWebView!
    
  
    var flag = false
    
    var urls = [
        "https://github.com",
        "https://www.wikipedia.org",
        "https://www.youtube.com",
        "https://twitter.com",
        "https://www.ebay.com",
        "https://www.instagram.com",
        "https://tw.yahoo.com",
        "https://us.yahoo.com",
        "https://google.com",
        
                ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        webView = WKWebView()
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        } else {
            // Fallback on earlier versions
            self.edgesForExtendedLayout = []
            webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
        
        openFastLink()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func openFastLink()
    {
        let q = DispatchQueue.global()
        for urlStr in urls {
            q.async {
//                for i in 1...10 {
//                    print(urlStr + "-\(i)")
//                }
                
                if let url = URL(string: urlStr) {
                    
                    let urlRequest = URLRequest(url: url)
                    
                    // set up the session
                    let config = URLSessionConfiguration.default
                    let session = URLSession(configuration: config)
                    
                    // make the request
                    let task = session.dataTask(with: urlRequest) {
                        (data, response, error) in
                        
                        if(self.flag) {
                            return
                        }
                        
                        // check for any errors
                        guard error == nil else {
                            print(error!)
                            return
                        }
                        // make sure we got data
                        guard let _ = data else {
                            print("Error: did not receive data")
                            return
                        }
                        // parse the result as JSON, since that's what the API provides
                        
                        self.flag = true
                        DispatchQueue.main.async {
                            // 程式碼片段 ...
                            self.webView.load(urlRequest)
                        }
                    }
                    task.resume()
                }
            }
        }
    }

}

