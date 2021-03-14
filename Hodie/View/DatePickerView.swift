//
//  DatePickerView.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/17.
//

import SwiftUI

struct DatePickerView: View {

    @Binding var selectedDate: Date
    @State private var draft: Date

    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        _draft = State(wrappedValue: selectedDate.wrappedValue)
    }

    var body: some View {
        VStack {
            HStack {
                Button {
                    withAnimation {
                    }
                } label: { Text(LocalizedStringKey("Cancel"))}
                .padding()

                Spacer()

                Button {
                    withAnimation {
                        selectedDate = draft
                    }
                } label: { Text(LocalizedStringKey("Done")) }
                .padding()
            }

            DatePicker("Select Date", selection: $draft, displayedComponents: .date )
                .datePickerStyle(GraphicalDatePickerStyle())
        }
    }
}
