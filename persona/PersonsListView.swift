//
//  PersonsListView.swift
//  persona
//
//  Created by hashimo ryoya on 2023/08/13.
//

import SwiftUI
import Firebase

struct SwipeView: View {
    var person: Person
    @Binding var personToDelete: Person?
    @Binding var showingDeleteAlert: Bool

    var body: some View {
        NavigationLink(destination: PersonDetailView(person: person)) {
            HStack {
                Image(person.icon)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding(.leading)
                Text(person.name)
                Spacer()
                Button(action: {
                    self.personToDelete = person
                    self.showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .background(Color.red)
                        //.cornerRadius(22)
                }
                .frame(maxHeight: .infinity)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
}

struct SwipeToDeleteView: View {
    var person: Person
    @Binding var personToDelete: Person?
    @Binding var showingDeleteAlert: Bool

    @State private var offset: CGFloat = 0
    @State private var isSwiped: Bool = false

    var body: some View {
        ZStack(alignment: .trailing) {
            NavigationLink(destination: PersonDetailView(person: person)) {
                HStack {
                    Image(person.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    Text(person.name)
                        .foregroundColor(.black)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 {
                                self.offset = value.translation.width
                            }
                        }
                        .onEnded { value in
                            if -value.translation.width > 100 {
                                self.isSwiped = true
                                self.offset = -100
                            } else {
                                self.isSwiped = false
                                self.offset = 0
                            }
                        }
                )
            }

            if isSwiped {
                Button(action: {
                    self.personToDelete = person
                    self.showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.red)
                        .cornerRadius(22)
                }
                .frame(width: 100, height: 44)
                .transition(.move(edge: .trailing))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

struct PersonsListView: View {
    @State private var persons: [Person] = []
    @State private var showingDeleteAlert = false
    @State private var personToDelete: Person?
    @State var showAnotherView_post: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Color("Color") // ここで背景色を指定
                    .edgesIgnoringSafeArea(.all) // これにより、背景色が全画面に広がります
                VStack {
                    ForEach(persons) { person in
                        SwipeToDeleteView(person: person, personToDelete: $personToDelete, showingDeleteAlert: $showingDeleteAlert)
                            .padding(.horizontal)
                            .padding(.vertical, 10) // ここで上下にスペースを追加
                    }
                    Spacer()
                }
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(title: Text("確認"),
                          message: Text("本当に\(personToDelete?.name ?? "")さんを削除してもよろしいでしょうか"),
                          primaryButton: .destructive(Text("はい")) {
                            if let person = personToDelete {
                                deletePerson(person: person)
                            }
                          },
                          secondaryButton: .cancel(Text("いいえ")))
                }
                .onAppear(perform: loadData)
                .navigationBarTitle("ユーザー一覧", displayMode: .inline)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            self.showAnotherView_post = true
                        }, label: {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.system(size: 24))
                        })
                        .frame(width: 60, height: 60)
                        .background(Color.gray)
                        .cornerRadius(30.0)
                        .shadow(color: Color(.black).opacity(0.2), radius: 8, x: 0, y: 4)
                        .fullScreenCover(isPresented: $showAnotherView_post, content: {
                            PersonRegistrationView()
                        })
                        .padding(.trailing)
                    }
                }
            }
        }
    }

    
    func loadData() {
        let ref = Database.database().reference().child("persons")
        ref.observe(.value) { (snapshot) in
            var loadedPersons: [Person] = []
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let personDict = snap.value as? [String: Any],
                   let name = personDict["name"] as? String,
                   let icon = personDict["icon"] as? String,
                   let age = personDict["age"] as? Int,
                   let bloodType = personDict["bloodType"] as? String,
                   let birthdayString = personDict["birthday"] as? String,
                   let relationship = personDict["relationship"] as? String,
                   let hobby = personDict["hobby"] as? String,
                   let likes = personDict["likes"] as? String,
                   let dislikes = personDict["dislikes"] as? String,
                   let mutualAcquaintances = personDict["mutualAcquaintances"] as? String {
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                    if let birthday = dateFormatter.date(from: birthdayString) {
                        let person = Person(firebaseKey: snap.key, id: UUID(), name: name, age: age, bloodType: bloodType, birthday: birthday, relationship: relationship, hobby: hobby, likes: likes, dislikes: dislikes, mutualAcquaintances: mutualAcquaintances, icon: icon)
                        loadedPersons.append(person)
                    }
                }
            }
            self.persons = loadedPersons
        }
    }

    func deletePerson(person: Person) {
        let ref = Database.database().reference().child("persons")
        ref.child(person.firebaseKey).removeValue { (error, _) in
            if let error = error {
                print("データの削除に失敗しました: \(error.localizedDescription)")
            } else {
                print("データの削除に成功しました")
                if let index = persons.firstIndex(where: { $0.id == person.id }) {
                    self.persons.remove(at: index)
                }
            }
        }
    }
}

struct PersonsListView_Previews: PreviewProvider {
    static var previews: some View {
        PersonsListView()
    }
}
