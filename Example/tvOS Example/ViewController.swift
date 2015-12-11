//
//  ViewController.swift
//  tvOS Example
//
//  Created by David White on 03/02/2016.
//  Copyright © 2016 deltaDNA. All rights reserved.
//

import UIKit
import DeltaDNA

class ViewController: UIViewController {

    @IBOutlet weak var sdkVersion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sdkVersion.text = DDNA_SDK_VERSION;
        
        DDNASDK.sharedInstance().clientVersion = "tvOS Example v1.0"
        DDNASDK.sharedInstance().hashSecret = "KmMBBcNwStLJaq6KsEBxXc6HY3A4bhGw"
        DDNASDK.sharedInstance().startWithEnvironmentKey("55822530117170763508653519413932",
            collectURL: "http://collect2010stst.deltadna.net/collect/api",
            engageURL: "http://engage2010stst.deltadna.net")
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSimpleEvent(sender: AnyObject) {
        DDNASDK.sharedInstance().recordEvent("achievement", withEventDictionary: [
            "achievementName" : "Sunday Showdown Tournament Win",
            "achievementID" : "SS-2014-03-02-01",
            "reward" : [
                "rewardName" : "Medal",
                "rewardProducts" : [
                    "items" : [
                        [
                            "item" : [
                                "itemAmount" : 1,
                                "itemName" : "Sunday Showdown Medal",
                                "itemType" : "Victory Badge"
                            ]
                        ]
                    ],
                    "virtualCurrencies" : [
                        [
                            "virtualCurrency" : [
                                "virtualCurrencyAmount" : 20,
                                "virtualCurrencyName" : "VIP Points",
                                "virtualCurrencyType" : "GRIND"
                            ]
                        ]
                    ],
                    "realCurrency" : [
                        "realCurrencyAmount" : 5000,
                        "realCurrencyType" : "USD"
                    ]
                ]
            ]
        ])
    }

    @IBAction func onEngage(sender: AnyObject) {
        DDNASDK.sharedInstance().requestEngagement("gameLoaded",
            withEngageParams: [
                "userLevel" : 4,
                "experience" : 1000,
                "missionName" : "Disco Volante"],
            callbackBlock: {(response) -> () in
                NSLog("Engage returned: %@", response)
        })
    }
    
    @IBAction func onImageMessage(sender: AnyObject) {
        let popup:DDNAPopup = DDNABasicPopup()
        weak var weakPopup = popup
        popup.afterPrepare = {()->() in
            weakPopup!.show()
        }
        popup.dismiss = {(name)->() in
            NSLog("Dismiss by %@", name)
        }
        popup.onAction = {(name, type, value)->() in
            NSLog("OnAction by %@ type %@ value %@", name, type, value)
        }
        DDNASDK.sharedInstance().requestImageMessage("imageMessage",
            withEngageParams: nil,
            imagePopup: popup,
            callbackBlock: {(response)->() in
                NSLog("Engage returned: %@", response)
        })
    }
    
    @IBAction func onUploadEvents(sender: AnyObject) {
        DDNASDK.sharedInstance().upload();
    }
}

