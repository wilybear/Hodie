//
//  EditorAlertType.swift
//  Hodie
//
//  Created by 김현식 on 2021/02/21.
//

import Foundation


enum EditorAlertType: String{
    case none
    case coredataError = "Some error occured while saving task"
    case overlapped = "The task already exists in that time interval. Are you sure you want to delete and register this task?"
    case nilValueInTask = "Enter a name for the task."
    case tooLongText = "Name of the task is too long"
    case tooLongMemo = "Memo of the task is too long"
    case same = "Start time and end time is equal."
}
