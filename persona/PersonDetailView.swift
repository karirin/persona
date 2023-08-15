//
//  PersonDetailView.swift
//  persona
//
//  Created by hashimo ryoya on 2023/08/13.
//

import SwiftUI
import Firebase

struct PersonDetailView: View {
    @State var person: Person
    @State private var isEditing = false

    var body: some View {
        List {
            Section(header: Text("基本情報")) {
                if isEditing {
                    TextField("名前", text: $person.name)
                    TextField("年齢", value: $person.age, formatter: NumberFormatter())
                    TextField("血液型", text: $person.bloodType)
                    DatePicker("誕生日", selection: $person.birthday, displayedComponents: .date)
                } else {
                    Text("名前: \(person.name)")
                    Text("年齢: \(person.age)")
                    Text("血液型: \(person.bloodType)")
                    Text("誕生日: \(person.birthday, formatter: DateFormatter())")
                }
            }

            Section(header: Text("詳細情報")) {
                if isEditing {
                    TextField("関係性", text: $person.relationship)
                    TextField("趣味", text: $person.hobby)
                    TextField("好きなもの", text: $person.likes)
                    TextField("嫌いなもの", text: $person.dislikes)
                    TextField("共通の知人", text: $person.mutualAcquaintances)
                } else {
                    Text("関係性: \(person.relationship)")
                    Text("趣味: \(person.hobby)")
                    Text("好きなもの: \(person.likes)")
                    Text("嫌いなもの: \(person.dislikes)")
                    Text("共通の知人: \(person.mutualAcquaintances)")
                }
            }
        }
        .navigationBarTitle(person.name, displayMode: .inline)
        .navigationBarItems(trailing: Button(isEditing ? "保存" : "編集") {
            if isEditing {
//                saveChanges()
            }
            isEditing.toggle()
        })
        .onChange(of: isEditing) { editing in
            if editing {
                person.birthday = Date() // 現在日時に更新
            }
        }
    }

    func saveChanges() {
        let ref = Database.database().reference().child("persons").child(person.firebaseKey)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z" // フォーマットを設定
        let birthdayString = dateFormatter.string(from: person.birthday) // 誕生日を文字列に変換

        let personData: [String: Any] = [
            "name": person.name,
            "age": person.age,
            "bloodType": person.bloodType,
            "birthday": birthdayString, // 変換した誕生日の文字列を使用
            "relationship": person.relationship,
            "hobby": person.hobby,
            "likes": person.likes,
            "dislikes": person.dislikes,
            "mutualAcquaintances": person.mutualAcquaintances,
            "icon": person.icon
        ]
        ref.updateChildValues(personData) { (error, _) in
            if let error = error {
                print("データの更新に失敗しました: \(error.localizedDescription)")
            } else {
                print("データの更新に成功しました")
            }
        }
    }
}

struct PersonDetailView_Previews: PreviewProvider {
    static var dummyPerson = Person(firebaseKey: "dummyKey", id: UUID(), name: "山田太郎", age: 30, bloodType: "A", birthday: Date(), relationship: "友人", hobby: "読書", likes: "リンゴ", dislikes: "バナナ", mutualAcquaintances: "佐藤次郎", icon: "icon1")

    static var previews: some View {
        PersonDetailView(person: dummyPerson)
    }
}
