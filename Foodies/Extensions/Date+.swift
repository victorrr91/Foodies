//
//  Date+.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/22.
//

import Foundation

extension Date {
    static var timestamp: Int {
        Int(Date().timeIntervalSince1970 * 1000)
    }
}
