//
//  ContentView.swift
//  hodie
//
//  Created by 김현식 on 2021/02/10.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var context
    @FetchRequest(fetchRequest: Scheduler.fetchRequest(.all)) var schedulers: FetchedResults<Scheduler>
    
    @State private var newScheduler = ""
    init(){
        print("contentView init called")
    }
    
    var body: some View {
        NavigationView{
            List{
                HStack{
                    TextField("New Scheduler", text: $newScheduler)
                    Button(action: addNewScheduler, label: {
                        Image(systemName: "plus.circle")
                            .imageScale(.large)
                    })
                }
                ForEach(schedulers){ scheduler in
                    NavigationLink(destination: SchedulerView().environmentObject(scheduler)){
                        VStack{
                            Text(scheduler.name ?? "untitled")
                                .font(.largeTitle)
                            Text("\(scheduler.createdAt!)")
                                .font(.caption)
                        }
                    }
                }
            }.navigationTitle(Text("TODO TEST LIST"))
            .navigationBarItems(leading: Button(action: {}, label: {
                Image(systemName: "plus.circle")
            }),trailing: EditButton())
        }.onAppear{
            whereIsMySQLite()
        }
    }
    
    private func addNewScheduler() -> (Void){
        let scheduler = Scheduler(context: context)
        scheduler.name = newScheduler
        scheduler.createdAt = Date()
       
        do {
            try context.save()
        }catch{
            print(error)
        }
        newScheduler = ""
    }
}
func whereIsMySQLite() {
    let path = FileManager
        .default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)
        .last?
        .absoluteString
        .replacingOccurrences(of: "file://", with: "")
        .removingPercentEncoding

    print("check out lLLL\(path ?? "Not found")")
}
