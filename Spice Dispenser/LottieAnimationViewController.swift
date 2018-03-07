//
//  LottieAnimationViewController.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2018-03-07.
//  Copyright © 2018 Rakesh Mandhan. All rights reserved.
//

import UIKit
import Lottie

class LottieAnimationViewController: UIViewController {

    var animationView: LOTAnimationView!
    var timeout: TimeInterval = 1.5    // Default timeout
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // view.backgroundColor = UIColor(white: 1, alpha: 0.85)
        view.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        view.insertSubview(blurEffectView, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(animationView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animationView.play()
        Timer.scheduledTimer(timeInterval: timeout, target: self, selector: #selector(LottieAnimationViewController.dismissView), userInfo: nil, repeats: false)
    }
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}
