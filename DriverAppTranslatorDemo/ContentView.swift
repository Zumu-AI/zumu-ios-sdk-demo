import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TranslatorViewModel()
    @State private var selectedTrip: Trip?
    @State private var showingTripPicker = false

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isSessionActive, let trip = viewModel.currentTrip {
                    ActiveTripView(viewModel: viewModel, trip: trip)
                } else {
                    TripSelectionView(
                        selectedTrip: $selectedTrip,
                        showingTripPicker: $showingTripPicker,
                        viewModel: viewModel
                    )
                }
            }
            .navigationTitle("Driver App")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
