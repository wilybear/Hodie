//
//  DatePickerView.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/17.
//

import SwiftUI
import PartialSheet

struct DatePickerView: View {

    @EnvironmentObject var partialSheetManager: PartialSheetManager

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
                        partialSheetManager.closePartialSheet()
                    }
                } label: { Text("Cancel")}
                .padding()

                Spacer()

                Button {
                    withAnimation {
                        selectedDate = draft
                        partialSheetManager.closePartialSheet()
                    }
                } label: { Text("Done") }
                .padding()
            }

            DatePicker("Select Date", selection: $draft, displayedComponents: .date )
                .datePickerStyle(GraphicalDatePickerStyle())
        }
    }
}
