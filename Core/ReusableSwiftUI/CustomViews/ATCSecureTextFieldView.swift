//
//  ATCSecureTextFieldView.swift
//  ATCSecureTextFieldView
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCSecureTextFieldView: View, AppConfigProtocol {
    @State private var showPassword: Bool = true
    private var password: Binding<String>
    private var placeholder: String
    
    init(placeholder: String,
         text: Binding<String>){
        self.placeholder = placeholder
        self.password = text
    }
    
    var body: some View {
        HStack() {
            if showPassword {
                SecureField(placeholder, text: password)
                    .autocapitalization(.none)
                    .multilineTextAlignment(.center)
                    .modifier(ATCTextModifier(font: appConfig.regularMediumFont,
                                              color: .black))
            } else {
                TextField(placeholder, text: password)
                    .autocapitalization(.none)
                    .multilineTextAlignment(.center)
                    .modifier(ATCTextModifier(font: appConfig.regularMediumFont,
                                              color: .black))
            }
            Image(showPassword ? "show-password-icon" : "hide-password-icon")
                .frame(width: 24, height: 24)
                .onTapGesture {
                    self.showPassword.toggle()
            }
        }
    }
}
