//
//  HomeView.swift
//  MyMusicApp
//
//  Created by Rafiul Hasan on 11/12/24.
//

import SwiftUI

struct HomeView: View {
    
    @State var showHomeView: Bool = false
    
    var body: some View {
        OnBoarding(showHomeView: $showHomeView)
    }
}

#Preview {
    HomeView()
}
