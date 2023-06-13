//
//  HistoryView.swift
//  FoodCostManager
//
//  Created by 菊地真優 on 2023/06/11.
//

import SwiftUI
import Neumorphic
import RealmSwift
import WidgetKit

struct HistoryView: View {
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var monthlyTotal: Int = 0
    @State private var monthlyList:Results<FoodTable>?
    @State private var showModalFlags: [Bool] = []
    var body: some View {
        ZStack{
            Color.Neumorphic.main.ignoresSafeArea()
            ScrollView{
                Text("履歴").font(.headline)
                Spacer().frame(height: 20)
                VStack(spacing:0){
                    //headline
                    HStack{
                        Button{
                            if(selectedMonth == 1){
                                selectedMonth = 12
                                selectedYear = selectedYear - 1
                            }else{
                                selectedMonth = selectedMonth - 1
                            }
                            let realm = try! Realm()
                            monthlyList = realm.objects(FoodTable.self).filter("year == \(selectedYear) && month == \(selectedMonth)")
                            monthlyTotal = monthlyList?.sum(ofProperty: "price") ?? 0
                            self.showModalFlags = Array(repeating: false, count: monthlyList?.count ?? 0)
                            
                        }label:{
                            Image(systemName: "arrowtriangle.left").imageScale(.small)
                        }.softButtonStyle(Circle(),padding: 8)
                        Text("\(selectedYear)"+"年\(selectedMonth)月").padding(.horizontal,10)
                        Button{
                            if(selectedMonth == 12){
                                selectedMonth = 1
                                selectedYear = selectedYear + 1
                            }else{
                                selectedMonth = selectedMonth + 1
                            }
                            
                            let realm = try! Realm()
                            monthlyList = realm.objects(FoodTable.self).filter("year == \(selectedYear) && month == \(selectedMonth)")
                            monthlyTotal = monthlyList?.sum(ofProperty: "price") ?? 0
                            self.showModalFlags = Array(repeating: false, count: monthlyList?.count ?? 0)
                            
                        }label:{
                            Image(systemName: "arrowtriangle.right").imageScale(.small)
                        }.softButtonStyle(Circle(),padding: 8)
                    }.padding(.bottom,12)
                    
                    RoundedRectangle(cornerRadius: 20).fill(Color.Neumorphic.main).softInnerShadow(RoundedRectangle(cornerRadius: 20),spread: 0.3).overlay(content: {
                        VStack{
                                
                            HStack{
                            Text("合計金額")
                                Text("¥\(monthlyTotal)").font(.largeTitle)
                                    .onAppear {
                                        let realm = try! Realm()
                                        monthlyList = realm.objects(FoodTable.self).filter("year == \(selectedYear) && month == \(selectedMonth)")
                                        self.showModalFlags = Array(repeating: false, count: monthlyList?.count ?? 0)
                                        monthlyTotal = monthlyList?.sum(ofProperty: "price") ?? 0
                                        
                                    }
                            }
                            HStack{
                                Text("目標金額").font(.caption)
                                Text("¥\(monthlyTotal)").font(.largeTitle)
                                    .onAppear {
                                        let realm = try! Realm()
                                        monthlyList = realm.objects(FoodTable.self).filter("year == \(selectedYear) && month == \(selectedMonth)")
                                        self.showModalFlags = Array(repeating: false, count: monthlyList?.count ?? 0)
                                        monthlyTotal = monthlyList?.sum(ofProperty: "price") ?? 0
                                        
                                    }
                            }
                        }
                    }).frame(height:150)
                    Spacer().frame(height: 16)
                    //display
                    if let mList = monthlyList{
                        ForEach((0..<mList.count).reversed(), id: \.self) { index in
                            Button{
                                showModalFlags[index]=true
                                print(mList[index].id)
                            }label: {
                                HStack{
                                    switch(mList[index].category){
                                    case "スーパー":
                                        Circle().fill(.orange).softOuterShadow().overlay(Image(systemName: "cart.fill").imageScale(.medium).foregroundColor(.white) ).frame(width: 35)
                                        
                                    case "外食":
                                        Circle().fill(.pink).softOuterShadow().overlay(Image(systemName: "fork.knife").imageScale(.medium).foregroundColor(.white) ).frame(width: 35)
                                        
                                    default:
                                        Circle().fill(.gray).softOuterShadow().overlay(Image(systemName: "ellipsis").imageScale(.medium).foregroundColor(.white) ).frame(width: 35)
                                    }
                                    VStack(alignment: .leading){
                                        Text("\(mList[index].category)")
                                        Text("\(mList[index].year)"+"/\(mList[index].month)/\(mList[index].day)").font(.caption).foregroundColor(.gray)
                                    }.padding(.horizontal,6)
                                    Spacer()
                                    Text("¥\(mList[index].price)")
                                }
                                
                            }.foregroundColor(Color(uiColor: .label))
                                .sheet(isPresented: $showModalFlags[index],onDismiss: {monthlyTotal = monthlyList?.sum(ofProperty: "price") ?? 0}){
                                    ModifyModalView(flag: $showModalFlags[index],id: mList[index].id)
                                }
                                
                            if( index != 0 ){
                                Divider().padding(.vertical,8)
                            }
                        }.padding(.horizontal,10)
                    }
                    
                    
                }.padding().background(RoundedRectangle(cornerRadius: 10).fill(Color.Neumorphic.main).softOuterShadow()).padding(.horizontal,20)
                
            }.padding(.vertical,16)
        }
    }
}

struct ModifyModalView: View {
    @Binding var flag:Bool
    //    var id:String
    @State  var id:String = ""
    @FocusState private var textFieldFocused:Bool
    @State private var price:String = ""
    @State private var category:String = ""
    @State private var selectedDate:Date = Date()
    
    
    var body: some View {
        
        ZStack{
            Color.Neumorphic.main.ignoresSafeArea()
            VStack{
                
                HStack {
                    
                    Text("\(category)").font(.headline)
                    Spacer()
                    Button {
                        // キャンセルした際の動作
                        flag = false
                        price = ""
                    } label: {
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .foregroundColor(.gray)
                    }
                }.padding(.bottom,10)
                RoundedRectangle(cornerRadius: 10).fill(Color.Neumorphic.main).softInnerShadow(RoundedRectangle(cornerRadius: 10)).overlay(content: {
                    
                    TextField("¥0", text: $price).font(.largeTitle).keyboardType(.numberPad) .multilineTextAlignment(TextAlignment.trailing).padding(.horizontal,12).focused($textFieldFocused)
                        .onAppear(){
                            textFieldFocused = true
                        }
                    
                }).frame(height:70)
                
                DatePicker(selection: $selectedDate,
                           displayedComponents: [.date],
                           label: { Image(systemName: "calendar") }
                ).frame(width: 100,height: 50)
                HStack{
                    //削除
                    Button{
                        
                        let realm = try! Realm()
                        let targetItem = realm.objects(FoodTable.self).filter("id == %@",id)[0]
                        try! realm.write {
                            realm.delete(targetItem)
                        }
                        
                        flag = false
                        price=""
                        id=""
                        
                        //widgetの更新
                        let currentYear=Calendar.current.component(.year, from: Date())
                        let currentMonth=Calendar.current.component(.month, from: Date())
                        
                        let results = realm.objects(FoodTable.self).filter("year == \(currentYear) && month == \(currentMonth)")
                        let total:Int = results.sum(ofProperty: "price")
                        
                        let userdefaults = UserDefaults(suiteName: "group.com.almikan.CostWidget")
                        userdefaults!.set(total, forKey: "total")
                        WidgetCenter.shared.reloadTimelines(ofKind: "CostWidget")
                        
                    }label:{
                        Text("削除").frame(width: 80,height: 20)
                    }.softButtonStyle(RoundedRectangle(cornerRadius: 12),textColor: Color.red).padding(.top,15)
                    Spacer().frame(width: 16)
               
                    Button{
                        let int_price=Int(price) ?? 0
                        let year = Calendar.current.component(.year, from: selectedDate)
                        let month = Calendar.current.component(.month, from: selectedDate)
                        let day = Calendar.current.component(.day, from: selectedDate)
                        if(int_price>0){
                            let realm = try! Realm()
                            let targetItem = realm.objects(FoodTable.self).filter("id == %@",id)[0]
                            try! realm.write {
                                targetItem.year=year
                                targetItem.month=month
                                targetItem.day=day
                                targetItem.price=int_price
                            }
                        }
                        flag = false
                        price=""
                        id=""
                        
                        //widgetの更新
                        let currentYear=Calendar.current.component(.year, from: Date())
                        let currentMonth=Calendar.current.component(.month, from: Date())
                        
                        let realm = try! Realm()
                        let results = realm.objects(FoodTable.self).filter("year == \(currentYear) && month == \(currentMonth)")
                        let total:Int = results.sum(ofProperty: "price")
                        
                        let userdefaults = UserDefaults(suiteName: "group.com.almikan.CostWidget")
                        userdefaults!.set(total, forKey: "total")
                        WidgetCenter.shared.reloadTimelines(ofKind: "CostWidget")
                        
                    }label:{
                        Text("決定").font(.headline).frame(width: 80,height: 20)
                    }.softButtonStyle(RoundedRectangle(cornerRadius: 12),mainColor: Color.orange,textColor: Color.white).padding(.top,15)
                    
                     }
            }.padding(.horizontal,30)
        }
        .presentationDetentsIfAvailable()
        .onAppear{
            //DBからidのデータを取得してUIに反映
            print(self.id)
            let realm = try! Realm()
            let res = realm.objects(FoodTable.self).filter("id == %@",self.id)
            if let selectedItem = res.first{
                let calendar = Calendar.current
                var dateComponents = DateComponents()
                dateComponents.year = selectedItem.year
                dateComponents.month = selectedItem.month
                dateComponents.day = selectedItem.day
                
                self.selectedDate = calendar.date(from: dateComponents) ?? Date()
                self.price = String(selectedItem.price)
                self.category = String(selectedItem.category)
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func presentationDetentsIfAvailable() -> some View {
        if #available(iOS 16.0, *) {
            presentationDetents([.height(300)])
        } else {
            self
        }
    }
}


struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .previewDevice("iPhone 14")
    }
}
