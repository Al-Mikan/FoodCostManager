//
//  ChartView.swift
//  FoodCostManager
//
//  Created by 菊地真優 on 2023/06/13.
//

import SwiftUI
import Neumorphic
import RealmSwift

struct ChartView: View {
    var body: some View {
        ZStack{
            Color.Neumorphic.main.ignoresSafeArea()
            ScrollView{
                Text("グラフ").font(.headline)
            }.padding(.vertical,16)
        }
        
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
    }
}
