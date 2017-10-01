//
//  InitialViewController.swift
//  Spice Dispenser
//
//  Created by Rakesh Mandhan on 2017-09-30.
//  Copyright © 2017 Rakesh Mandhan. All rights reserved.
//

import UIKit
import Lottie

class InitialViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        playLottieAnimation();
        // performSegue(withIdentifier: "segueToTabBarController", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playLottieAnimation() {
        // TODO: Scale according to the screen
        let animationView = LOTAnimationView(name: "gears")
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopAnimation = true;
        view.addSubview(animationView)
        animationView.play()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToTabBarController") {
            // Do nothing right now
        }
    }
}
