//
//  ViewController.swift
//  BYBlueToothDemo-Swift
//
//  Created by Darin4lin on 2017/3/24.
//  Copyright © 2017年 QZBD. All rights reserved.
//

import UIKit
import BYBlueTooth

class ViewController: UIViewController {
	let bb = BYBlueTooth.share()
	var currPeripheral: CBPeripheral?
	override func viewDidLoad() {
		super.viewDidLoad()
		BYBlueTooth.isShowLog(true)
		
		_ = bb?.scanForPeripheralsWithService()(nil)?.begin()()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}

