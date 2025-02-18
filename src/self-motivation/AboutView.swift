//
//  AboutView.swift
//  self-motivation
//
//  Created by Matthew Manela on 2/2/25.
//


import SwiftUI
import SwiftData

struct AboutView: View {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let repoUrl = "https://github.com/mmanela/quick_motivation"
    let copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String
    let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 128, height: 128)
            
            Text(displayName!)
                .font(.title)
                .bold()
            
            Text("Version \(appVersion)")
                .font(.system(size: 12))
            
            Link(destination: URL(string: repoUrl)!) {
                HStack(spacing: 8) {
                    Image("github-mark-white")
                        .resizable()
                        .frame(width: 16, height: 16)
                    Text("View on GitHub")
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black)
                .cornerRadius(6)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 5)
            
            
            Text(copyright!)
                .font(.system(size: 11))
            
        }
        .frame(width: 300, height: 300)
        .padding()
    }
}

#Preview {
    AboutView()
}
