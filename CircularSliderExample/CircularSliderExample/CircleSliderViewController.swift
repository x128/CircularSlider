//
//  CircleSliderViewController.swift
//  CircularSliderExample
//
//  Created by Chris on 3/3/16.
//  Copyright © 2016 caolsen. All rights reserved.
//

import UIKit

class CircleSliderViewController: UIViewController {
  
  @IBOutlet weak var sliderValueLabel: UILabel!
  @IBOutlet weak var sliderView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // init slider view
    let frame = CGRectMake(0, 0, sliderView.frame.width, sliderView.frame.height)
    let circularSlider = CircularSlider(frame: frame)
    
    // setup target to watch for value change
    circularSlider.addTarget(self, action: Selector("valueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    
    // setup slider defaults
    circularSlider.unfilledArcLineCap = .Round
    circularSlider.filledArcLineCap = .Round
    circularSlider.currentValue = 10
    circularSlider.lineWidth = 30
    
    // add to view
    sliderView.addSubview(circularSlider)
  }
  
  func valueChanged(slider: CircularSlider) {
    sliderValueLabel.text = "\(slider.currentValue)"
  }
}
