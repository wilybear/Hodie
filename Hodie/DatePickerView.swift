//
//  DatePickerView.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/17.
//

import SwiftUI
import PartialSheet

struct DatePickerView: View {
    @Binding var selectedDate: Date
    @State private var draft: Date
    
    @EnvironmentObject var partialSheetManager: PartialSheetManager
    
    
    init(selectedDate : Binding<Date>) {
        self._selectedDate = selectedDate
        _draft = State(wrappedValue: selectedDate.wrappedValue)
    }
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    withAnimation{
                        partialSheetManager.closePartialSheet()
                    }
                }){
                    Text("Cancel")
                }
                .padding()
                Spacer()
                Button(action: {
                    withAnimation{
                        selectedDate = draft
                        partialSheetManager.closePartialSheet()
                    }
                }){
                    Text("Done")
                }
                .padding()
            }
            
            DatePicker("Select Date", selection: $draft, displayedComponents: .date )
                .datePickerStyle(GraphicalDatePickerStyle())
           
        }
    }
}
