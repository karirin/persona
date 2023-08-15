//
//  IconPickerView.swift
//  persona
//
//  Created by hashimo ryoya on 2023/08/13.
//

import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    let icons = ["icon1", "icon2", "icon3"]

    var body: some View {
        VStack {
            Text("アイコンを選択")
                .font(.headline)
            List(icons, id: \.self) { icon in
                Button(action: {
                    self.selectedIcon = icon
                    // ビューシートを閉じる
                    UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
                }) {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
            }
        }
    }
}

struct IconPickerView_Previews: PreviewProvider {
    @State static var icon: String = "icon1" // Stateを使用して変数を作成

    static var previews: some View {
        IconPickerView(selectedIcon: $icon) // $を使用してBindingを渡す
    }
}

