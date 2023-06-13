//
//  FoodTable.swift
//  FoodCostManager
//
//  Created by 菊地真優 on 2023/06/11.
//

import Foundation
import RealmSwift

class FoodTable: Object {
    @Persisted  var id:String
    @Persisted  var category = ""
    @Persisted  var year:Int
    @Persisted  var month:Int
    @Persisted  var day:Int
    @Persisted  var price:Int = 0
}

class MonthlyGoal: Object {
    @Persisted var year: Int = 0
    @Persisted var month: Int = 0
    @Persisted  var goal:Int
}
