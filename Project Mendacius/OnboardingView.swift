//
//  OnboardingView.swift
//  Project Mendacius
//
//  Created by Praneet S on 26/01/21.
//

import SwiftUI

struct featureView: View {
    var img: String
    var title: String
    var desc: String
    var body: some View {
        HStack {
            Image(img)
                .resizable()
                .antialiased(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                .frame(width: 40, height: 40, alignment: .center)
                .padding(.horizontal)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 15, weight: .heavy, design: .default))
                Text(desc)
                    .font(.body)
            }
            Spacer()
        }
        .padding()
    }
}

struct gradientBackgroundStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: 140, maxHeight: 10)
            .padding()
            .foregroundColor(.white)
            .background(LinearGradient(gradient: .init(colors: [.blue, .green]), startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/))
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
    }
}

struct OnboardingView: View {
    
    @Binding var onboardingComplete: Bool
    
    var body: some View {
        VStack {
            Text("What's New")
                .font(.system(size: 32, weight: .heavy, design: .default))
                .bold()
            featureView(img: "heart", title: "COMPATIBILITY", desc: "Supports Apple Silicon (arm64) and Intel (x86) based SoCs and processors straight out of the box")
            featureView(img: "performance", title: "PERFORMANCE", desc: "Built with performance and efficiency in mind, minimising memory and CPU overhead.")
            featureView(img: "ux", title: "USER EXPERIENCE", desc: "Starting from eliminating the process of installation to configuring VMs and automating complex tasks, everything is too simple")
            Button(action: {
                UserDefaults.standard.set(true, forKey: "isOnboardingComplete")
                onboardingComplete = true
            }) {
                Text("Let's go!")
                    .font(.headline)
                    .bold()
            }
            .buttonStyle(gradientBackgroundStyle())
            .padding(.top)
        }.frame(width: 500, height: 500, alignment: .center)
    }
}
