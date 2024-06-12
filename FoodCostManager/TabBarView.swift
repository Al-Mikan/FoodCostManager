//
//  TabBarView.swift
//  FoodCostManager
//
//  Created by 菊地真優 on 2023/06/10.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
            
            HistoryView()
                .tabItem {
                    if #available(iOS 16.0, *) {
                        Image(systemName: "list.bullet.clipboard.fill")
                    } else {
                        Image(systemName: "list.bullet.rectangle.portrait.fill")
                    }
                    Text("履歴")
                }
            if #available(iOS 16.0, *) {
                ChartView()
                    .tabItem {
                        Image(systemName: "chart.xyaxis.line")
                        Text("グラフ")
                    }}
        }.accentColor(.orange)
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
            
    }
}
