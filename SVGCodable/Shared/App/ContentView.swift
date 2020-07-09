//
//  ContentView.swift
//  Shared
//
//  Created by Karthikkeyan Bala Sundaram on 7/8/20.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var service = ImageService()
    
    var body: some View {
        ScrollView {
            VStack {
                Button("Fetch") {
                    service.fetchImage()
                }.padding(.bottom, 16)

                SwiftUI.Text(service.result).padding(.all, 16)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
