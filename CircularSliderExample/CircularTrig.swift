//
//  CircularTrig.swift
//
//  Created by Christopher Olsen on 03/03/16.
//  Copyright © 2016 Christopher Olsen. All rights reserved.
//

import UIKit

public class CircularTrig {
  
  public class func angleRelativeToNorthFromPoint(fromPoint: CGPoint, toPoint: CGPoint) -> CGFloat {
    var v = CGPointMake(toPoint.x - fromPoint.x, toPoint.y - fromPoint.y)
    let vmag = CGFloat(sqrt(square(Double(v.x)) + square(Double(v.y))))
    v.x /= vmag
    v.y /= vmag
    let cartesianRadians = Double(atan2(v.y, v.x))
    // Need to convert from cartesian style radians to compass style
    var compassRadians = cartesianToCompass(cartesianRadians)
    if (compassRadians < 0) {
      compassRadians += (2 * M_PI)
    }
    assert(compassRadians >= 0 && compassRadians <= 2 * M_PI, "angleRelativeToNorth should be always positive")
    return CGFloat(toDeg(compassRadians))
  }
  
  public class func pointOnRadius(radius: CGFloat, atAngleFromNorth: CGFloat) -> CGPoint {
    //Get the point on the circle for this angle
    var result = CGPoint()
    // Need to adjust from 'compass' style angle to cartesian angle
    let cartesianAngle = CGFloat(compassToCartesian(toRad(Double(atAngleFromNorth))))
    result.y = round(radius * sin(cartesianAngle))
    result.x = round(radius * cos(cartesianAngle))
    
    return result
  }
  
  // MARK: Draw Arcs
  public class func drawFilledCircleInContext(ctx: CGContextRef, center: CGPoint, radius: CGFloat) -> CGRect {
    let frame = CGRectMake(center.x - radius, center.y - radius, 2 * radius, 2 * radius)
    CGContextFillEllipseInRect(ctx, frame)
    return frame
  }
  
  public class func drawUnfilledCircleInContext(ctx: CGContextRef, center: CGPoint, radius: CGFloat, lineWidth: CGFloat, maximumAngle: CGFloat, lineCap: CGLineCap) {
    // by using maximumAngle an incomplete circle can be drawn
    drawUnfilledArcInContext(ctx, center: center, radius: radius, lineWidth: lineWidth, fromAngleFromNorth: 0, toAngleFromNorth: maximumAngle, lineCap: lineCap)
  }
  
  public class func drawUnfilledArcInContext(ctx: CGContextRef, center: CGPoint, radius: CGFloat, lineWidth: CGFloat, fromAngleFromNorth: CGFloat, toAngleFromNorth: CGFloat, lineCap: CGLineCap) {
    let cartesianFromAngle = compassToCartesian(toRad(Double(fromAngleFromNorth)))
    let cartesianToAngle = compassToCartesian(toRad(Double(toAngleFromNorth)))

    CGContextAddArc(ctx,
      center.x,   // arc start point x
      center.y,   // arc start point y
      radius,     // arc radius from center
      CGFloat(cartesianFromAngle), CGFloat(cartesianToAngle),
      0) // iOS flips the y coordinate so anti-clockwise (specified here by 0) becomes clockwise (desired)!
    
    CGContextSetLineWidth(ctx, lineWidth)
    CGContextSetLineCap(ctx, lineCap)
    CGContextDrawPath(ctx, CGPathDrawingMode.Stroke)
  }
  
  public class func drawUnfilledGradientArcInContext(ctx: CGContextRef, center: CGPoint, radius: CGFloat, lineWidth: CGFloat, maximumAngle: CGFloat, colors: [UIColor], lineCap: CGLineCap) {
    // ensure two colors exist to create a gradient between
    guard colors.count == 2 else {
      return
    }
    
    let cartesianFromAngle = compassToCartesian(toRad(Double(0)))
    let cartesianToAngle = compassToCartesian(toRad(Double(maximumAngle)))
    
    CGContextSaveGState(ctx)
    
    let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(cartesianFromAngle), endAngle: CGFloat(cartesianToAngle), clockwise: true)
    let containerPath = CGPathCreateCopyByStrokingPath(path.CGPath, nil, CGFloat(lineWidth), lineCap, CGLineJoin.Round, lineWidth)
    CGContextAddPath(ctx, containerPath)
    CGContextClip(ctx)
    
    let baseSpace = CGColorSpaceCreateDeviceRGB()
    let gradient = CGGradientCreateWithColors(baseSpace, [colors[1].CGColor, colors[0].CGColor], nil)
    let startPoint = CGPointMake(center.x - radius, center.y + radius)
    let endPoint = CGPointMake(center.x + radius, center.y - radius)
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, .DrawsBeforeStartLocation)
    
    CGContextRestoreGState(ctx)
  }
  
  public class func degreesForArcLength(arcLength: CGFloat, onCircleWithRadius radius: CGFloat, withMaximumAngle degrees: CGFloat) -> CGFloat {
    let totalCircumference = CGFloat(2 * M_PI) * radius
  
    let arcRatioToCircumference = arcLength / totalCircumference
  
    return degrees * arcRatioToCircumference // If arcLength is exactly half circumference, that is exactly half a circle in degrees
  }
  
  // MARK: Calculate radii of arcs with line widths
  /*
  *  For an unfilled arc.
  *
  *  Radius of outer arc (center to outside edge)  |          ---------
  *      = radius + 0.5 * lineWidth                |      +++++++++++++++
  *                                                |    /++/++++ --- ++++\++\
  *  Radius of inner arc (center to inside edge)   |   /++/++/         \++\++\
  *      = radius - (0.5 * lineWidth)              |  |++|++|     .     |++|++|
  *                                         outer edge^  ^-radius-^     ^inner edge
  *
  */
  public class func outerRadiuOfUnfilledArcWithRadius(radius: CGFloat, lineWidth: CGFloat) -> CGFloat {
    return radius + 0.5 * lineWidth
  }
  
  public class func innerRadiusOfUnfilledArcWithRadius(radius :CGFloat, lineWidth: CGFloat) -> CGFloat {
    return radius - 0.5 * lineWidth
  }
}

// MARK: - Utility Math
extension CircularTrig {
  
  /**
   *  Macro for converting radian degrees from 'compass style' reference (0 radians is along Y axis (ie North on a compass))
   *   to cartesian reference (0 radians is along X axis).
   *
   *  @param rad Radian degrees to convert from 'Compass' reference
   *
   *  @return Radian Degrees in Cartesian reference
   */
  private class func toRad(degrees: Double) -> Double {
    return ((M_PI * degrees) / 180.0)
  }
  
  private class func toDeg(radians: Double) -> Double {
    return ((180.0 * radians) / M_PI)
  }
  
  private class func square(value: Double) -> Double {
    return value * value
  }
  
  /**
   *  Macro for converting radian degrees from cartesian reference (0 radians is along X axis)
   *   to 'compass style' reference (0 radians is along Y axis (ie North on a compass)).
   *
   *  @param rad Radian degrees to convert from Cartesian reference
   *
   *  @return Radian Degrees in 'Compass' reference
   */
  private class func cartesianToCompass(radians: Double) -> Double {
    return radians + (M_PI/2)
  }
  
  private class func compassToCartesian(radians: Double) -> Double {
    return radians - (M_PI/2)
  }
}
