//
//  HelpMeVC.swift
//  HelpMe
//
//  Created by DerekYang on 2018/1/16.
//  Copyright © 201年 DerekYang. All rights reserved.
//

import UIKit
import AVFoundation

import CoreBluetooth
import CoreLocation

import GoogleMobileAds

import AudioToolbox


//間隔︰ (長訊號為短訊號之三倍長度)
//1) 字母內的每一個訊號間，相距一“點”
//2) 兩個字母間的間隔為三“點”
//3) 每個英文字間的間隔為五“點”
//S: ... O: ---

class HelpMeVC: BaseVC
{
    
    @IBOutlet weak var adView: UIView!
    @IBOutlet var lblMsg: UILabel!
    
    var adBannerView: GADBannerView?
    
    static let baseTime: Int = 250//ms
    let timeDot = baseTime
    let timeDesh = 3 * baseTime
    let intervalChar = (3-1) * baseTime//beside timeDot
    let intervalWord = (5-3) * baseTime//beside intervalChar
    
    let morseCode = ["A" : ".-", "B" : "-...", "C" : "-.-.", "D" : "-..", "E" : ".",
                     "F" : "..-.", "G" : "--.", "H" : "....", "I" : "..", "J" : ".---",
                     "K" : "-.-", "L" : ".-..", "M" : "--", "N" : "-.", "O" : "---",
                     "P" : ".--.", "Q" : "--.-", "R" : ".-.", "S" : "...", "T" : "-",
                     "U" : "..-", "V" : "...-", "W" : ".--", "X" : "-..-", "Y" : "-.--",
                     "Z" : "--..",
                     "1" : ".----", "2" : "..---", "3" : "...--", "4" : "....-", "5" : ".....",
                     "6" : "-....", "7" : "--...", "8" : "---..", "9" : "----.", "0" : "-----"
                     ]
    
    let lm = CLLocationManager()
    var peripheralManager: CBPeripheralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        lm.requestAlwaysAuthorization()
        lm.delegate = self
        
        adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView?.adUnitID = "ca-app-pub-3397168268806661/6247875041"
        adBannerView?.delegate = self
        adBannerView?.rootViewController = self
        
        adBannerView?.load(GADRequest())
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func click(_ sender: UIButton) {
//        for i in 1...5 {
//            if(0 == i%2) {
//                flasfDot()
//            } else {
//                flasfDesh()
//            }
//        }
        let str = encode2morse(str: "SOS")
        morse2Flash(str: str)
    }

    @IBAction func switchHear(_ sender: UISwitch)
    {
        let uuid = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
        let region = CLBeaconRegion(proximityUUID: uuid!, identifier: "myregion")
        if(sender.isOn) {
            // 用來得知附近 beacon 的資訊。觸發1號method
            lm.startRangingBeacons(in: region)
            // 用來接收進入區域或離開區域的通知。觸發2號與3號method
            lm.startMonitoring(for: region)
        } else {
            lm.stopRangingBeacons(in: region)
            lm.stopMonitoring(for: region)
        }
    }
    
    @IBAction func switchBroadcast(_ sender: UISwitch)
    {
        if(sender.isOn) {
            let queue = DispatchQueue.global()
            peripheralManager = CBPeripheralManager(delegate: self, queue: queue)
        } else {
            peripheralManager.stopAdvertising()
        }
    }
    
//    func toggleFlash()
//    {
//        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
//            return
//        }
//        if (device.hasTorch) {
//            do {
//                try device.lockForConfiguration()
//                if (device.torchMode == AVCaptureDevice.TorchMode.on) {
//                    device.torchMode = AVCaptureDevice.TorchMode.off
//                } else {
//                    do {
//                        try device.setTorchModeOn(level: 1.0)
//                    } catch {
//                        print(error)
//                    }
//                }
//                device.unlockForConfiguration()
//            } catch {
//                print(error)
//            }
//        }
//    }
    func encode2morse(str: String) -> String
    {
        var retStr = ""
        let upperStr = str.uppercased()
        let array = upperStr.description.split(separator: " ")
        for subStr in array {
            for char in subStr {
                if let map = morseCode[String(char)] {
                    retStr += map
                    retStr += "^"
                }
            }
            retStr += ";"
        }
        print(retStr)
        return retStr
    }
    
    func morse2Flash(str: String)
    {
        for char in str {
            switch char {
            case ".":
                flasfDot()
            case "-":
                flasfDesh()
            case "^":
                usleep(useconds_t(1000 * intervalChar))
            case ";":
                usleep(useconds_t(1000 * intervalWord))
            default:
                break;
            }
            
        }
    }
    func flasfDot()
    {
        flash(ms: timeDot)
    }
    
    func flasfDesh()
    {
        flash(ms: timeDesh)
    }
    
    func flash(ms: Int)
    {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            return
        }
        
          if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
               
                device.torchMode = AVCaptureDevice.TorchMode.off
                
                do {
                    try device.setTorchModeOn(level: 1.0)
                    usleep(useconds_t(1000 * ms))
                    device.torchMode = AVCaptureDevice.TorchMode.off
                    usleep(useconds_t(1000 * timeDot))
                } catch {
                    print(error)
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
        
    }
    
    
}


extension HelpMeVC: CLLocationManagerDelegate
{
    /* 1號method */
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion)
    {
        for beacon in beacons {
            print("major=\(beacon.major) minor=\(beacon.minor) accury=\(beacon.accuracy) rssi=\(beacon.rssi)")
            switch beacon.proximity {
            case .far:
                lblMsg.text = "Far"
                
            case .near:
                lblMsg.text = "Near"
                
            case .immediate:
                lblMsg.text = "Immediate"
                
            case .unknown:
                lblMsg.text = "Unknown"
            }
        }
    }
    
    /* 2號method */
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion)
    {
        // 進入區域
        lblMsg.text = "Enter \(region.identifier)"
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    }
    
    /* 3號method */
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion)
    {
        // 離開區域
        lblMsg.text = "Exit \(region.identifier)"
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    }
}

extension HelpMeVC: CBPeripheralManagerDelegate
{
    
    
//    
//     func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        let queue = DispatchQueue.global()
//        peripheralManager = CBPeripheralManager(delegate: self, queue: queue)
//    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        guard peripheral.state == .poweredOn else {
            lblMsg.text = "藍牙未開啟"
            return
        }
        
        peripheral.delegate = self
        
        // uuid可在終端機由uuidgen指令產生
        let uuid = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
        // 雖然identifier參數在這裡沒有用處，但不可以填nil
        let region = CLBeaconRegion(
            proximityUUID: uuid!,
            major: 2000,
            minor: 56,
            identifier: ""
        )
        
        var advData = [String: AnyObject]()
        for (key, value) in region.peripheralData(withMeasuredPower: nil) {
            advData[key as! String] = value as AnyObject
        }
        
        // mybeacon是當某裝置進行掃描周圍藍牙裝置時會看到的名字
        advData[CBAdvertisementDataLocalNameKey] = "mybeacon" as AnyObject
        // 開始廣播訊號
        peripheral.startAdvertising(advData)
    }
}

extension HelpMeVC: GADBannerViewDelegate
{
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        //        bannerView.frame = adview.frame
        adView.addSubview(bannerView)
        
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
}

