//
//  FloatingPoint+Radians.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 03/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import Foundation

public extension FloatingPoint {
    // 角度转弧度
    public var degreesToRadians: Self { return self * .pi / 180 }
    // 弧度转角度
    public var radiansToDegrees: Self { return self * 180 / .pi }
}
