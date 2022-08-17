//
//  Model.swift
//  Memo
//
//  Created by 김용재 on 2022/08/12.
//

import Foundation

class Memo {
    var content: String
    var insertDate: Date

    init(content: String) {
        self.content = content
        insertDate = Date()
    }
    static var dummyMemoList = [
    Memo(content: "Lorem Ipsum"),
    Memo(content: "Subscribe + 👍 = ♥️")
    ]
}
