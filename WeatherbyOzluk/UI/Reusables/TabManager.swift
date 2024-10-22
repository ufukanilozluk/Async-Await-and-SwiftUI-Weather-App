import SwiftUI

struct TabManager: View {
  var body: some View {
    TabView {
      HomeView()
        .tabItem {
          Label("Home", systemImage: "house")
        }
      CitiesView()
        .tabItem {
          Label("Cities", systemImage: "building.2")
        }
    }
  }
}

struct TabPreview: PreviewProvider {
  static var previews: some View {
    TabManager()
  }
}