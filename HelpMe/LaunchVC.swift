//
//  LaunchVC.swift
//  fngame
//
//  Created by DerekYang on 2018/1/8.
//  Copyright © 2018年 LBD. All rights reserved.
//

import UIKit

class LaunchVC: UIViewController {

    var urls = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //        var flag_login = 0  //修改這個值 以改變 init view
        
        linkTop10Server()
    }
    
    func linkNameServer()
    {
        if let url = URL(string: "https://las-stream.tk/appweb/top1.json") { //"https://las-stream.tk/appweb/app.json") {
            let urlRequest = URLRequest(url: url)
            let config = URLSessionConfiguration.ephemeral
            let session = URLSession(configuration: config)
            
            // make the request
            let task = session.dataTask(with: urlRequest) {
                [weak self]
                (data, response, error) in
                
                if let strongSelf = self {
                    if error == nil {
                        if let usableData = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: usableData) as? [String : Any],
                                let names = json["top1"] as? [String] {
                                    strongSelf.urls = names
                                    DispatchQueue.main.async {
                                        strongSelf.performSegue(withIdentifier: "LaunchVC2WebVC", sender: nil)
                                    }
                                }
                                
                            } catch {
                                print(error)
                                strongSelf.hint(msg: "Please Check Connection and Retry")
                            }
                            
                        } else {
                            strongSelf.hint(msg: "Please Check Connection and Retry")
                        }
                    } else {
                        strongSelf.hint(msg: "Please Check Connection and Retry")
                    }
                }
            }
            task.resume()
        }
    }
    
    func linkTop10Server()
    {
        if let url = URL(string: "https://las-stream.tk/appweb/top10.json") { //"https://las-stream.tk/appweb/app.json") {
            let urlRequest = URLRequest(url: url)
            let config = URLSessionConfiguration.ephemeral
            let session = URLSession(configuration: config)
            
            var goToGame = true
            
            // make the request
            let task = session.dataTask(with: urlRequest) {
                [weak self]
                (data, response, error) in
                
                if let strongSelf = self {
                    if error == nil {
                        if let usableData = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: usableData) as? [String : Any],
                                    let top10 = json["top10"] as? [Int] {
                                    for goal in top10 {
                                        if(goal>999) {
                                            goToGame = false
                                            strongSelf.linkNameServer()
                                            
                                            break
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        if(goToGame) {
                                            strongSelf.performSegue(withIdentifier: "LaunchVC2HelpMeVC", sender: nil)
                                        }
                                    }
                                }
                            } catch {
                                print(error)
                                strongSelf.hint(msg: "Please Check Connection and Retry")
                            }
                            
                        } else {
                            strongSelf.hint(msg: "Please Check Connection and Retry")
                        }
                    } else {
                        strongSelf.hint(msg: "Please Check Connection and Retry")
                    }
                }
            }
            task.resume()
        }
    }
        
        
    func hint(msg: String)
    {
        let alert = UIAlertController(title: "Hint", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Retry", style: .default, handler: {
            [weak self]
            _ in
            
            if let strongSelf = self {
                strongSelf.linkTop10Server()
            }
        })
        
        
        alert.addAction(okAction)
        
        // 顯示提示框
        self.present(alert, animated: true, completion: nil)
    }
        
        //        if (flag_login == 0) { //還沒登入
        //
        //            self.window = UIWindow(frame: UIScreen.main.bounds)
        //            let storyboard = UIStoryboard(name: "Main", bundle: nil) //Storyboard的名稱
        //
        //            let initialViewController = storyboard.instantiateViewController(withIdentifier: "StartVC") // view 的 ID
        //
        //            self.window?.rootViewController = initialViewController
        //            self.window?.makeKeyAndVisible()
        //
        //        } else { //已經登入
        //
        //            self.window = UIWindow(frame: UIScreen.main.bounds)
        //            let storyboard = UIStoryboard(name: "Main", bundle: nil) //Storyboard的名稱
        //            let initialViewController = storyboard.instantiateViewController(withIdentifier: "WebVC") // view 的 ID
        //
        //            self.window?.rootViewController = initialViewController
        //            self.window?.makeKeyAndVisible()
        //        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "LaunchVC2WebVC" {
            if let destVC = segue.destination as? WebVC {
                destVC.urls = self.urls
            }
        }
        super.prepare(for: segue, sender: sender)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
