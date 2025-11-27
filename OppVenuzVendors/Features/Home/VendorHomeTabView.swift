//
//  HometabVC.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 25/11/25.
//

import SwiftUI

struct VendorHomeTabView: View {
    var body: some View {
        TabView {
            Text("Dashboard")
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            Text("Bookings")
                .tabItem {
                    Label("Bookings", systemImage: "calendar")
                }

            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}
