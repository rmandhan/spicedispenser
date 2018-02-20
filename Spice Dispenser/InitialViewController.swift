//
//  InitialViewController.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2017-09-30.
//  Copyright © 2017 Rakesh Mandhan. All rights reserved.
//

/* NOTE BEING USED RIGHT NOW */

import UIKit
import Lottie

class InitialViewController: UIViewController {
    
    var animationView: LOTAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupLottieAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playLottieAnimation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupLottieAnimation() {
        animationView = LOTAnimationView(name: "gears")
        animationView.frame = CGRect(x: 0, y: 0, width: 220, height: 220)
        animationView.center = view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopAnimation = true
        view.addSubview(animationView)
    }
    
    @objc func playLottieAnimation() {
        animationView.play()
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(InitialViewController.goToTabBarController), userInfo: nil, repeats: false)
    }
    
    @objc func goToTabBarController() {
        performSegue(withIdentifier: "segueToTabBarController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToTabBarController" {
            // Do nothing right now
        }
    }
}
