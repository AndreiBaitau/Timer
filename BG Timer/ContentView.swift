//
//  ContentView.swift
//  BG Timer
//
//  Created by Balaji on 19/04/20.
//  Copyright © 2020 Balaji. All rights reserved.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    var body: some View {
        
        Home().preferredColorScheme(.light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
    }
}
struct ExpenseItem:Identifiable, Codable {
    let name: String
    let time: String
    let id = UUID()
    let type: String
    let amount: Int
}


class Expenses: ObservableObject {
    @Published var items = [ExpenseItem](){
    didSet {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(items){
        UserDefaults.standard.set(encoded, forKey: "Items")
        }}}
        init() {
            if let items = UserDefaults.standard.data(forKey: "Items"){
                let decoder = JSONDecoder()
                if let decoded = try? decoder.decode([ExpenseItem].self, from: items) {
                    self.items = decoded
                    
                }
                return
            }
        }}


struct Home : View {
    @State private var showingAddExpense = false
    @ObservedObject var expenses = Expenses()
    @State private var wakeUp = Date()
    @State var start = false
    @State var to : CGFloat = 0
    @State var count = 0
    let str : String = "Smiley \u{1F603}"
    
    @State var time = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var minutes = 00;
    var body: some View{
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: self.count)
        
        ZStack{
            Spacer()
           // Color.black.opacity(0.06).edgesIgnoringSafeArea(.all)
            
                .padding(200)
            VStack{
                
                ZStack{
                    
                    Circle()
                    .trim(from: 0, to: 1)
                        .stroke(Color.black.opacity(0.09), style: StrokeStyle(lineWidth: 35, lineCap: .round))
                    .frame(width: 280, height: 280)
                    
                    Circle()
                        .trim(from: 0, to: self.to)
                        .stroke(Color(hue: 0.845, saturation: 0.362, brightness: 0.848), style: StrokeStyle(lineWidth: 35, lineCap: .round))
                    .frame(width: 280, height: 280)
                    .rotationEffect(.init(degrees: -90))
                    
                    
                    VStack{
                        
                    
                        Text("\(h):\(m):\(s)")
                            .font(.system(size: 40))
                            .fontWeight(.bold)
                        
                        Text("Of")
                            .font(.title)
                            .padding(.top)
                        Text("08:00:00")
                            .font(.title)
                            .padding(.top)
                    }
                }
                
                HStack(spacing: 20)
                {
                    
                    Button(action: {
                        
                        if self.count == 28800{
                            
                            self.count = 0
                            withAnimation(.default){
                                
                                self.to = 0
                            }
                        }
                        self.start.toggle()
                        
                    }) {
                        
                        HStack(spacing: 15){
                            
                            Image(systemName: self.start ? "pause.fill" : "play.fill")
                                .foregroundColor(.white)
                            
                            Text(self.start ? "Pause" : "Play")
                                .foregroundColor(.white)
                        }
                        .padding(.vertical)
                        .frame(width: (UIScreen.main.bounds.width / 2) - 55)
                        .background(Color(hue: 0.845, saturation: 0.362, brightness: 0.848))
                        .clipShape(Capsule())
                        .shadow(radius: 6)
                    }
                    
                    Button(action: {
                        
                        self.count = 0
                        
                        withAnimation(.default){
                            
                            self.to = 0
                        }
                        
                    }) {
                        
                        HStack(spacing: 15){
                            
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(Color(hue: 0.845, saturation: 0.362, brightness: 0.848))
                            
                            Text("Restart")
                                .foregroundColor(Color(hue: 0.845, saturation: 0.362, brightness: 0.848))
                            
                        }
                        .padding(.vertical)
                        .frame(width: (UIScreen.main.bounds.width / 2) - 55)
                        .background(
                        
                            Capsule()
                                .stroke(Color(hue: 0.845, saturation: 0.362, brightness: 0.848))
                        )
                        .shadow(radius: 6)
                    }
                }
                .padding(.top, 55)
                
            }}
            .padding(20)
            NavigationView{
           
                List{
                ForEach(expenses.items) {  item in
                    HStack(){
                        VStack(alignment:.leading){
                            Text(item.name)
                                .font(.headline)
                            Text(item.type)
                        }
                        Spacer()
                        VStack()
                        {
                            Text(item.time)
                                
                                
                            Text("$\(item.amount)")
                            
                        }
                    }
                }
                .onDelete(perform: removeitems)
                }
                .navigationTitle("Tasks for a day:")
                
                .navigationBarItems(trailing:
                    Button(action: {
                        self.showingAddExpense = true
               } ){
            Image(systemName: "plus")
                .sheet(isPresented: $showingAddExpense){
                    AddView(expenses: self.expenses)
                }
           }          )
        
                .colorScheme(.light)
                
                
            }
            
        
        .onAppear(perform: {
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge,.sound,.alert]) { (_, _) in
            }
        })
        .onReceive(self.time) { (_) in
            
            if self.start{
                
                if self.count != 5{
                    
                    self.count += 1
                    
                    
                    withAnimation(.default){
                        
                        self.to = CGFloat(self.count) / 28800
                    }
                }
                else{
                
                    self.start.toggle()
                    self.Notify()
                }

            }
            
        }
        
    }
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    func removeitems(as offsets: IndexSet)  {
        expenses.items.remove(atOffsets: offsets)
        
        
    }
    func Notify(){
        
        let content = UNMutableNotificationContent()
        content.title = "CHILL TIME"
        content.body = "My dear babe, your working day is finished \nLove u ❤️ "
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let req = UNNotificationRequest(identifier: "MSG", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
    }
}
