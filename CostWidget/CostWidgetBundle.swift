//
//  CostWidgetBundle.swift
//  CostWidget
//
//  Created by 菊地真優 on 2023/06/12.
//

import WidgetKit
import SwiftUI

@main
struct CostWidgetBundle: WidgetBundle {
    var body: some Widget {
        CostWidget()
        CostWidgetLiveActivity()
    }
}
