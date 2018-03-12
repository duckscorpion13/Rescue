//
//  ViewController.swift
//  TestSpeed
//
//  Created by DerekYang on 2017/12/28.
//  Copyright © 2017年 LBD. All rights reserved.
//

import UIKit
import WebKit

class WebVC: UIViewController, WKNavigationDelegate
{
    
    var webView: WKWebView!
    let configuration = WKWebViewConfiguration()
    
  
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
        setupWebView()
                
        openFastLink()
    }

    func setupWebView() {
        configuration.allowsInlineMediaPlayback = true
        webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        
        webView.navigationDelegate = self
        
        self.view.addSubview(webView)
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
        
        let request = URLRequest(url: URL(string: "https://lbdapp.tk/easygoalapp/description.html")!,
                                 cachePolicy: .reloadIgnoringLocalCacheData)
        
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation")
        
        //        activityIndicatorView.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("didCommit")
        
        //        activityIndicatorView.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish")
        
        //        activityIndicatorView.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail, error: \(error.localizedDescription)")
        
        //        activityIndicatorView.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation, error: \(error.localizedDescription)")
        
        //        activityIndicatorView.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("didReceiveServerRedirectForProvisionalNavigation")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let url = navigationResponse.response.url {
            print("decidePolicyFor navigationResponse response url: \(url.absoluteString)")
            
            if url.absoluteString.hasSuffix("close.html") {
//                webView.isHidden = true
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        decisionHandler(WKNavigationResponsePolicy.allow)
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

