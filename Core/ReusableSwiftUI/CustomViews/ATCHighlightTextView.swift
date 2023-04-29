//
//  ATCHighlightTextView.swift
//  FitnessApp
//
//  Copyright © 2020 iOSAppTemplates. All rights reserved.
//

import SwiftUI

struct ATCHighlightTextView: View, AppConfigProtocol {
    private let originalString: String
    private let highlightString: String
    private let fontOriginalSize: UIFont
    private let fontHighlightSize: UIFont
    init(originalString: String,
         highlightString: String,
         fontOriginalSize: UIFont = UIFont(name: "Rubik-Bold", size: 24)!,
         fontHighlightSize: UIFont = UIFont(name: "Rubik-Bold", size: 24)!) {
        self.originalString = originalString
        self.highlightString = highlightString
        self.fontOriginalSize = fontOriginalSize
        self.fontHighlightSize = fontHighlightSize
    }
    
    private var splitedStringArray: [String] {
        return splitString(originalString, highlightString: highlightString)
    }
    
    var body: some View {
        Group {
            Text(splitedStringArray[0])
                .font(.custom(fontOriginalSize.familyName,
                              size: fontOriginalSize.pointSize))
                .foregroundColor(Color.black)
                + Text(highlightString)
                    .font(.custom(fontHighlightSize.familyName,
                                  size: fontHighlightSize.pointSize))
                    .foregroundColor(Color(appConfig.mainThemeForegroundColor))
                + Text(splitedStringArray[1])
                    .font(.custom(fontOriginalSize.familyName,
                                  size: fontOriginalSize.pointSize))
                    .foregroundColor(Color.black)
        }.multilineTextAlignment(.center)
    }
    
    private func splitString(_ originalString: String, highlightString: String) -> [String] {
        return originalString.components(separatedBy: highlightString)
    }
}

