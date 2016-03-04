//
//  WithLabelsViewController.swift
//  CircularSliderExample
//
//  Created by Christopher Olsen on 3/4/16.
//  Copyright © 2016 Christopher Olsen. All rights reserved.
//

import UIKit

class WithLabelsViewController: UIViewController {

  @IBOutlet weak var sliderValue: UILabel!
  @IBOutlet weak var sliderView: UIView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // init slider view
    let frame = CGRectMake(0, 0, sliderView.frame.width, sliderView.frame.height)
    let circularSlider = CircularSlider(frame: frame)
    
    // setup target to watch for value change
    circularSlider.addTarget(self, action: Selector("valueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    
    // setup slider defaults
    circularSlider.maximumAngle = 270.0
    circularSlider.unfilledArcLineCap = .Round
    circularSlider.filledArcLineCap = .Round
    circularSlider.handleType = .BigCircle
    circularSlider.currentValue = 10
    circularSlider.lineWidth = 10
    circularSlider.labelDisplacement = -10.0
    circularSlider.innerMarkingLabels = ["0", "20", "40", "60", "80", "100"];
    
    // add to view
    sliderView.addSubview(circularSlider)
    
    // NOTE: create and set a transform to rotate the arc so the white space is centered at the bottom
    circularSlider.transform = circularSlider.getRotationalTransform()
  }
  
  func valueChanged(slider: CircularSlider) {
    sliderValue.text = "\(slider.currentValue)"
  }
}
