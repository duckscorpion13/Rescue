//
//  BaseVC.swift
//  HelpMe
//
//  Created by DerekYang on 5/21/18.
//  Copyright © 2018 LBD. All rights reserved.
//

import UIKit
import WebKit

class BaseVC: UIViewController {
    var urlStr = "" {
        didSet {
            if let _url = URL(string: self.urlStr) {
                let request = URLRequest(url: _url)//, cachePolicy: .reloadRevalidatingCacheData)
            
                webView.load(request)
            }
        }
    }
    var webView: WKWebView!
    var indicator: UIActivityIndicatorView!
    let configuration = WKWebViewConfiguration()
    
    var topConstraint: NSLayoutConstraint? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.init(red: 0xC4/0xFF,
                                                                           green: 0x0D/0xFF,
                                                                           blue: 0x24/0xFF,
                                                                           alpha: 1.0)
      
        self.setupWebView()
        self.setupIndicator()
        
        self.urlStr = "https://lbdapp.tk/morsehelper/description.html"
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    @objc func deviceRotated()
    {
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight :
            topConstraint?.constant = 0
        case .portrait :
            topConstraint?.constant = 20
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupIndicator()
    {
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.color = UIColor.gray
        view.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func clearCache()
    {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
            dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records, completionHandler: {
                //                print("clear")
            })
            //            for record in records {
            //                if record.displayName.contains("facebook") {
            //                    dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [record], completionHandler: {
            //                        print("Deleted: " + record.displayName);
            //                    })
            //                }
            //            }
        }
    }
}

extension BaseVC: WKNavigationDelegate, WKUIDelegate
{
    func setupWebView() {
        configuration.allowsInlineMediaPlayback = true
        configuration.userContentController.add(self, name: "clearCache")
        
        webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        
        webView.uiDelegate = self
        
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
            topConstraint = webView.topAnchor.constraint(equalTo: view.topAnchor)
            // webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            topConstraint?.isActive = true
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
        
      
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation")
        
        indicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("didCommit")
        
        //        activityIndicatorView.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish")
        
        indicator.stopAnimating()
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
                webView.isHidden = true
            }
        }
        
        decisionHandler(WKNavigationResponsePolicy.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        return nil
    }
    
}

extension BaseVC: WKScriptMessageHandler
{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
    {
        print(message.name)
        if message.name == "clearCache" {
            //            if let dic = message.body as? NSDictionary {
            //                print(dic["className"] as? String ?? "")
            //                print(dic["functionName"] as? String ?? "")
            //            }
            self.clearCache()
        }
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
}


