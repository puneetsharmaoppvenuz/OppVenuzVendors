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
            HomeDashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            MyOrdersView()
                .tabItem {
                    Label("My Orders", systemImage: "bag.fill")
                }
            
            WalletView()
                .tabItem {
                    Label("Wallet", systemImage: "creditcard")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
        }
    }
}

// MARK: - Home tab (with header icons)

struct HomeDashboardView: View {
    @State private var showProfile = false
    @State private var showNotifications = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // HEADER
                        HomeHeaderCard(
                            onProfileTap: { showProfile = true },
                            onNotificationsTap: { showNotifications = true }
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                        // DASHBOARD METRICS
                        DashboardSummarySection()
                            .padding(.horizontal, 16)

                        // CHOICE / ELITE
                        ChoiceSection()
                            .padding(.horizontal, 16)

                        // PROMO BANNER
                        BestDealBanner()
                            .padding(.horizontal, 16)

                        // MY PRODUCTS
                        MyProductsSection()
                            .padding(.horizontal, 16)

                        // RECENT ACTIVITY
                        RecentActivitySection()
                            .padding(.horizontal, 16)

                        // BOOK CELEBRITY
                        BookCelebritySection()
                            .padding(.horizontal, 16)

                        // GALLERY
                        GallerySection()
                            .padding(.horizontal, 16)

                        // FEEDBACK
                        FeedbackSection()
                            .padding(.horizontal, 16)

                        Spacer(minLength: 24)
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showProfile) {
                NavigationView {
                    ProfileViewStub()
                        .navigationTitle("Profile")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .sheet(isPresented: $showNotifications) {
                NavigationView {
                    NotificationsViewStub()
                        .navigationTitle("Notifications")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

// MARK: - Header
struct HomeHeaderCard: View {
    var onProfileTap: () -> Void
    var onNotificationsTap: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Gradient background
            LinearGradient(
                colors: [.primaryGradientStart, .primaryGradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    // Profile avatar
                    Button(action: onProfileTap) {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 52, height: 52)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(.white)
                            )
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hi,")
                            .font(.roboto(.regular, size: 14))
                            .foregroundColor(.white.opacity(0.85))

                        Text("Sweet Delights Cakes")
                            .font(.roboto(.bold, size: 20))
                            .foregroundColor(.white)

                        // Badge
                        HStack(spacing: 8) {
                            Text("Oppvenuz Business Partner")
                                .font(.roboto(.medium, size: 11))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.22))
                                .cornerRadius(20)

                            Text("Verified by OppVenuz")
                                .font(.roboto(.regular, size: 10))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 4)
                    }

                    Spacer()

                    // Notification bell
                    Button(action: onNotificationsTap) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.18))
                                .frame(width: 40, height: 40)
                            Image(systemName: "bell.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                }

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.7))
                    Text("Search customer name, order ID ...")
                        .font(.roboto(.regular, size: 13))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.15))
                .cornerRadius(24)
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
    }
}

// MARK: - Dashboard summary

struct DashboardSummarySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dashboard")
                .font(.roboto(.medium, size: 16))
                .foregroundColor(.headlineText)

            HStack(spacing: 12) {
                MetricCard(
                    title: "Total Orders",
                    value: "80",
                    subtitle: "This Month",
                    footerText: "Repeat Customers: 12"
                )

                RewardsCard()
            }
        }
    }
}

struct MetricCard: View {
    var title: String
    var value: String
    var subtitle: String
    var footerText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.roboto(.medium, size: 14))
                .foregroundColor(.white.opacity(0.9))

            Text(value)
                .font(.roboto(.bold, size: 28))
                .foregroundColor(.white)

            Text(subtitle)
                .font(.roboto(.regular, size: 11))
                .foregroundColor(.white.opacity(0.8))

            Spacer()

            Text(footerText)
                .font(.roboto(.regular, size: 11))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(
            LinearGradient(
                colors: [.primaryGradientStart, .primaryGradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(18)
    }
}

struct RewardsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Oppvenuz Rewards")
                .font(.roboto(.medium, size: 14))
                .foregroundColor(.white)

            Text("₹ 500K")
                .font(.roboto(.bold, size: 24))
                .foregroundColor(.white)

            Text("Total Earnings")
                .font(.roboto(.regular, size: 11))
                .foregroundColor(.white.opacity(0.85))

            Spacer()

            Text("250 Opp Coins this Month")
                .font(.roboto(.medium, size: 11))
                .foregroundColor(.accentOrange)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.15))
                .cornerRadius(14)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(
            LinearGradient(
                colors: [.rewardsGradientStart, .rewardsGradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(18)
    }
}

// MARK: - Choice & Elite

struct ChoiceSection: View {
    var body: some View {
        VStack(spacing: 10) {
            FeatureRowCard(
                title: "Oppvenuz Choice",
                subtitle: "Boost your Business, Unlock premium trust and visibility",
                buttonTitle: "View"
            )

            FeatureRowCard(
                title: "Elite",
                subtitle: "Boost your Business, Unlock premium benefits",
                buttonTitle: "View"
            )
        }
    }
}

struct FeatureRowCard: View {
    var title: String
    var subtitle: String
    var buttonTitle: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.roboto(.medium, size: 14))
                    .foregroundColor(.headlineText)
                Text(subtitle)
                    .font(.roboto(.regular, size: 12))
                    .foregroundColor(.subtitleText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Text(buttonTitle)
                .font(.roboto(.medium, size: 13))
                .foregroundColor(.accentPurple)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.appBackground)
                .cornerRadius(16)
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - Best Deal Banner

struct BestDealBanner: View {
    var body: some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: [.accentPurple, .accentPink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(20)

            VStack(alignment: .leading, spacing: 10) {
                Text("Create your")
                    .font(.roboto(.regular, size: 16))
                    .foregroundColor(.white.opacity(0.9))

                Text("Best Deal")
                    .font(.roboto(.bold, size: 24))
                    .foregroundColor(.white)

                Text("Get more visibility with combo offers.")
                    .font(.roboto(.regular, size: 12))
                    .foregroundColor(.white.opacity(0.9))

                HStack(spacing: 10) {
                    CapsuleButton(
                        title: "Create your Best Deal",
                        filled: true
                    )
                    CapsuleButton(
                        title: "View my Best Deals",
                        filled: false
                    )
                }
                .padding(.top, 6)
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
    }
}

struct CapsuleButton: View {
    var title: String
    var filled: Bool

    var body: some View {
        Text(title)
            .font(.roboto(.medium, size: 12))
            .foregroundColor(filled ? .accentPurple : .white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                filled ? Color.white : Color.white.opacity(0.15)
            )
            .clipShape(Capsule())
    }
}

// MARK: - My Products

struct MyProductsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("My Products")
                .font(.roboto(.medium, size: 16))
                .foregroundColor(.headlineText)

            Text("You have added 6 Products")
                .font(.roboto(.regular, size: 12))
                .foregroundColor(.subtitleText)

            HStack(spacing: 10) {
                OutlineSmallButton(title: "View all")
                FilledSmallButton(title: "Add New")
            }
        }
        .padding(14)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

struct OutlineSmallButton: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.roboto(.medium, size: 12))
            .foregroundColor(.accentPurple)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.accentPurple.opacity(0.6), lineWidth: 1)
            )
    }
}

struct FilledSmallButton: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.roboto(.medium, size: 12))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: [.primaryGradientStart, .primaryGradientEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
    }
}

// MARK: - Recent Activity

struct RecentActivitySection: View {
    // dummy data for now
    let items: [OrderActivity] = [
        .init(name: "Patel Vijay", date: "July 20, 2025", status: .onGoing),
        .init(name: "Akash",       date: "July 15, 2025", status: .cancelled),
        .init(name: "Akash",       date: "July 15, 2025", status: .completed),
        .init(name: "Akash",       date: "July 15, 2025", status: .inQueue)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Activity")
                    .font(.roboto(.medium, size: 16))
                    .foregroundColor(.headlineText)
                Spacer()
                Text("See All")
                    .font(.roboto(.regular, size: 12))
                    .foregroundColor(.accentPurple)
            }

            VStack(spacing: 8) {
                ForEach(items) { item in
                    RecentActivityRow(activity: item)
                }
            }
        }
    }
}

struct OrderActivity: Identifiable {
    let id = UUID()
    let name: String
    let date: String
    let status: OrderStatus
}

enum OrderStatus {
    case onGoing
    case cancelled
    case completed
    case inQueue

    var title: String {
        switch self {
        case .onGoing:   return "Order On-going"
        case .cancelled: return "Order Cancelled"
        case .completed: return "Order Completed"
        case .inQueue:   return "Order in queue"
        }
    }

    var color: Color {
        switch self {
        case .onGoing:   return .accentPurple
        case .cancelled: return .red
        case .completed: return .green
        case .inQueue:   return .accentOrange
        }
    }

    var systemIcon: String {
        switch self {
        case .onGoing:   return "clock.arrow.circlepath"
        case .cancelled: return "xmark.circle.fill"
        case .completed: return "checkmark.circle.fill"
        case .inQueue:   return "bag.badge.clock"
        }
    }
}

struct RecentActivityRow: View {
    let activity: OrderActivity

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.appBackground)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(activity.name.prefix(1)))
                        .font(.roboto(.medium, size: 16))
                        .foregroundColor(.accentPurple)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.name)
                    .font(.roboto(.medium, size: 14))
                    .foregroundColor(.headlineText)
                Text(activity.date)
                    .font(.roboto(.regular, size: 11))
                    .foregroundColor(.subtitleText)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: activity.status.systemIcon)
                    .font(.system(size: 14))
                    .foregroundColor(activity.status.color)
                Text(activity.status.title)
                    .font(.roboto(.regular, size: 11))
                    .foregroundColor(activity.status.color)
            }
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - Book Celebrity

struct BookCelebritySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Book Your Celebrity")
                .font(.roboto(.medium, size: 16))
                .foregroundColor(.headlineText)

            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [.accentPurple, .accentPink],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .cornerRadius(20)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Book your")
                        .font(.roboto(.regular, size: 14))
                        .foregroundColor(.white.opacity(0.9))
                    Text("CELEBRITY")
                        .font(.roboto(.bold, size: 24))
                        .foregroundColor(.white)

                    Text("Make your event memorable with top celebrity appearances.")
                        .font(.roboto(.regular, size: 11))
                        .foregroundColor(.white.opacity(0.9))

                    Spacer()

                    FilledSmallButton(title: "Book Now")
                        .padding(.bottom, 10)
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity, minHeight: 150)
        }
    }
}

// MARK: - Gallery

struct GallerySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Gallery")
                .font(.roboto(.medium, size: 16))
                .foregroundColor(.headlineText)

            HStack(spacing: 12) {
                GalleryItemCard(title: "Photos")
                GalleryItemCard(title: "Videos")
            }
        }
    }
}

struct GalleryItemCard: View {
    var title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.softCardBackground)
                .frame(height: 80)
                .overlay(
                    Image(systemName: title == "Photos" ? "photo.on.rectangle" : "play.rectangle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.accentPurple)
                )

            Text(title)
                .font(.roboto(.medium, size: 13))
                .foregroundColor(.headlineText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Feedback

struct FeedbackSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Feedback")
                    .font(.roboto(.medium, size: 16))
                    .foregroundColor(.headlineText)
                Spacer()
                Text("See All")
                    .font(.roboto(.regular, size: 12))
                    .foregroundColor(.accentPurple)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < 4 ? "star.fill" : "star.lefthalf.fill")
                            .foregroundColor(.accentOrange)
                            .font(.system(size: 14))
                    }
                }

                Text("Opp Venuz made planning our engagement so easy. The vendors were professional and aligned perfectly with our vision and budget. Highly recommended!")
                    .font(.roboto(.regular, size: 12))
                    .foregroundColor(.subtitleText)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.appBackground)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text("R")
                                .font(.roboto(.medium, size: 16))
                                .foregroundColor(.accentPurple)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ritika & Aarav")
                            .font(.roboto(.medium, size: 13))
                            .foregroundColor(.headlineText)
                    }
                }
            }
            .padding(14)
            .background(Color.cardBackground)
            .cornerRadius(16)
        }
    }
}


// MARK: - Other tabs (stubs)

struct MyOrdersView: View {
    var body: some View {
        NavigationView {
            Text("My Orders")
                .font(.title2)
                .navigationTitle("My Orders")
        }
    }
}

struct WalletView: View {
    var body: some View {
        NavigationView {
            Text("Wallet")
                .font(.title2)
                .navigationTitle("Wallet")
        }
    }
}

struct HistoryView: View {
    var body: some View {
        NavigationView {
            Text("History")
                .font(.title2)
                .navigationTitle("History")
        }
    }
}

// MARK: - Stub Profile & Notifications views

struct ProfileViewStub: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Profile Screen")
                .font(.headline)
            Text("TODO: Implement vendor profile UI.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct NotificationsViewStub: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Notifications")
                .font(.headline)
            Text("TODO: Implement notifications list.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
