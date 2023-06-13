//
//  ContentView.swift
//  FoodCostManager
//
//  Created by 菊地真優 on 2023/06/09.
//

import SwiftUI
import Neumorphic
import RealmSwift
import WidgetKit

struct ContentView: View {
    @State private var flag = false
    @State private var total: Int = 0
    @State private var currentMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var currentYear: Int = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        ZStack {
            Color.Neumorphic.main.ignoresSafeArea()
            VStack {
                Text("ホーム").font(.headline)
                Spacer().frame(height: 20)
                RoundedRectangle(cornerRadius: 20).fill(Color.Neumorphic.main).softInnerShadow(RoundedRectangle(cornerRadius: 20),spread: 0.3).overlay(content: {
                    VStack{
                        Text("今月の食費")
                        Text("¥\(total)").font(.largeTitle)
                            .onAppear {
                                let currentMonth = Calendar.current.component(.month, from: Date())
                                let currentYear = Calendar.current.component(.year, from: Date())
                                let realm = try! Realm()
                                let results = realm.objects(FoodTable.self).filter("year == \(currentYear) && month == \(currentMonth)")
                                total = results.sum(ofProperty: "price")
                                
                                
                            }
                    }
                }).frame(height:150).padding(.horizontal,10)
                Spacer()
                HStack(spacing:16){
                    InputButton(total:$total,category: "外食")
                    InputButton(total:$total,category: "スーパー")
                    InputButton(total:$total,category: "その他")
                }
                
            }
            .padding()
        }
    }
    
}

struct InputButton: View {
    @Binding var total:Int
    var category:String
    @State private var flag = false
    var body: some View {
        Button(){
            flag = true
        }label:{
            VStack{
                switch category {
                case "外食":
                    Image(systemName: "fork.knife").imageScale(.large).foregroundColor(.pink).frame(width: 20,height: 20)
                case "スーパー":
                    Image(systemName: "cart.fill").imageScale(.large).foregroundColor(.orange).frame(width: 20,height: 20)
                default:
                    Image(systemName: "ellipsis").imageScale(.large).foregroundColor(.gray).frame(width: 20,height: 20)
                }
                Text(category).font(.caption)
            }.frame(width: 50,height: 50)
        }
        .softButtonStyle(RoundedRectangle(cornerRadius: 100),padding: 28).padding(.bottom,30)
        //modalの動き
        .sheet(isPresented: $flag){
            AddModalView(flag: $flag,total:$total,category: category)
        }
        
    }
}


struct AddModalView: View {
    @Binding var flag:Bool
    @Binding var total:Int
    @FocusState private var textFieldFocused: Bool
    @State private var price:String = ""
    @State private var selectedDate:Date = Date()
    var category:String
    
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
                    
                    Button{
                        //TODO:決定した際の動き
                        let uuid = UUID()
                        let uniqueIdString = uuid.uuidString
                        let foodTable = FoodTable()
                        let int_price=Int(price) ?? 0
                        let year = Calendar.current.component(.year, from: selectedDate)
                        let month = Calendar.current.component(.month, from: selectedDate)
                        let day = Calendar.current.component(.day, from: selectedDate)
                        if(int_price>0){
                            //Realmに挿入
                            foodTable.id = uniqueIdString
                            foodTable.category = category
                            foodTable.year = year
                            foodTable.month = month
                            foodTable.day = day
                            foodTable.price = int_price
                            
                            let realm = try! Realm()
                            try! realm.write {
                                realm.add(foodTable)
                            }
                        }
                        flag = false
                        price=""
                        let currentYear=Calendar.current.component(.year, from: Date())
                        let currentMonth=Calendar.current.component(.month, from: Date())
                        if( year == currentYear && month == currentMonth){
                            total = total + int_price
                        }
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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environment(\.sizeCategory, .medium)
                .previewInterfaceOrientation(.portrait)
                .previewLayout(.sizeThatFits)
                .previewDevice("iPhone 14")
                .previewDisplayName("iPhone14")
            ContentView()
                .previewLayout(.sizeThatFits)
                .previewDevice("iPhone SE (3rd generation)")
                .previewDisplayName("iPhoneSE")
        }
        
    }
}
