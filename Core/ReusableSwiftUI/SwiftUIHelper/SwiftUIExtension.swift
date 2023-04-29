//
//  SwiftUIExtension.swift
//  FitnessApp
//
//  Created by Duy Bui on 1/7/20.
//  Copyright © 2020 Duy Bui. All rights reserved.
//

import SwiftUI

extension View {
    func endEditing(_ force: Bool) {
        UIApplication.shared.windows.forEach { $0.endEditing(force)}
    }
}
