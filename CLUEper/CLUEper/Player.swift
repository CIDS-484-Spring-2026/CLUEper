//
//  Player.swift
//  CLUEper
//
//  Created by Elijah William Belz on 2/5/26.
//

import Foundation
import SwiftUI

struct Player: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var color: Color
}
