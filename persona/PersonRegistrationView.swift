//
//  PersonRegistrationView.swift
//  persona
//
//  Created by hashimo ryoya on 2023/08/13.
//

import SwiftUI
import Firebase

struct Person: Identifiable {
    var firebaseKey: String
    var id: UUID
    var name: String
    var age: Int
    var bloodType: String
    var birthday: Date
    var relationship: String
    var hobby: String
    var likes: String
    var dislikes: String
    var mutualAcquaintances: String
    var icon: String
}

struct PersonRegistrationView: View {
    @State private var name = "test"
    @State private var age = "test"
    @State private var bloodType = "test"
    @State private var birthday = Date()
    @State private var relationship = "test"
    @State private var hobby = "test"
    @State private var likes = "test"
    @State private var dislikes = "test"
    @State private var mutualAcquaintances = "test"
    @ObservedObject var authManager = AuthManager.shared
    @State private var selectedIcon: String = "icon1"
    let icons = ["icon1", "icon2", "icon3"]
    @State private var showingIconPicker = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("基本情報")) {
                        TextField("名前", text: $name)
                        TextField("年齢", text: $age)
                        TextField("血液型", text: $bloodType)
                        DatePicker("誕生日", selection: $birthday, displayedComponents: .date)
                    }
                    
                    Section(header: Text("詳細情報")) {
                        TextField("関係性", text: $relationship)
                        TextField("趣味", text: $hobby)
                        TextField("好きなもの", text: $likes)
                        TextField("嫌いなもの", text: $dislikes)
                        TextField("共通の知人", text: $mutualAcquaintances)
                    }
                    
                    Section(header: Text("アイコン選択")) {
                        Button(action: {
                            self.showingIconPicker.toggle()
                        }) {
                            HStack {
                                Image(selectedIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                Text("アイコンを選択")
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("ユーザー登録", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("戻る") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("登録") {
                        // 以前の登録ロジック
                        guard let userId = self.authManager.user?.uid else {
                            print("ユーザーIDが取得できませんでした")
                            return
                        }
                        
                        let ref = Database.database().reference().child("persons")
                        let personData: [String: Any] = [
                            "userId": userId,
                            "name": self.name,
                            "age": Int(self.age) ?? 0,
                            "bloodType": self.bloodType,
                            "birthday": "\(self.birthday)",
                            "relationship": self.relationship,
                            "hobby": self.hobby,
                            "likes": self.likes,
                            "dislikes": self.dislikes,
                            "mutualAcquaintances": self.mutualAcquaintances,
                            "icon": self.selectedIcon
                        ]
                        ref.childByAutoId().setValue(personData) { (error, ref) in
                            if let error = error {
                                print("データの保存に失敗しました: \(error.localizedDescription)")
                            } else {
                                print("データの保存に成功しました")
                                self.presentationMode.wrappedValue.dismiss() // ここでビューを閉じる
                            }
                        }
                    }
                }
            }
        }
    }
}

struct PersonRegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        PersonRegistrationView()
    }
}

