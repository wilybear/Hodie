//
//  ContentView.swift
//  hodie
//
//  Created by 김현식 on 2021/02/10.
//

import SwiftUI
import PartialSheet
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var context
    @State private var selectedDate: Date = Date()
    
    @EnvironmentObject var partialSheetManager: PartialSheetManager
    
    // TODO: multiple scheduler is added
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    withAnimation{
                        selectedDate = Calendar.current.date(byAdding: .day,value: -1, to: selectedDate)!
                    }
                }, label: {
                    Image(systemName: "arrowtriangle.left")
                })
                .padding([.leading])
                Text(DateFormatter.dateOnlyFormatter.string(from: selectedDate))
                    .transition(.opacity)
                    .id("\(selectedDate)")
                    .onTapGesture {
                        partialSheetManager.showPartialSheet(content:{ DatePickerView(selectedDate: $selectedDate)})
                    }
                Button(action: {
                    withAnimation{
                        selectedDate = Calendar.current.date(byAdding: .day,value: 1, to: selectedDate)!
                    }
                }, label: {
                    Image(systemName: "arrowtriangle.right")
                })
                Spacer()
            }
            .padding()
            SchedulerView(selectedDate: selectedDate)
            .onAppear{
                whereIsMySQLite()
            }
        }
        .addPartialSheet()
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
