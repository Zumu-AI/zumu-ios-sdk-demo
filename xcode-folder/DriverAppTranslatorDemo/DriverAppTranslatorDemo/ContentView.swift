import SwiftUI

struct ContentView: View {
    @State private var selectedTrip: Trip? = Trip.samples[0] // Default to first sample trip
    @State private var showingTripPicker = false
    @State private var showingTripCreation = false
    @State private var newlyCreatedTrip: Trip?

    var body: some View {
        ZStack {
            // Always show the navigation UI with selected trip
            if let trip = selectedTrip {
                RideshareActiveTripView(
                    trip: trip,
                    onChangeTripTapped: { showingTripPicker = true },
                    onCreateTripTapped: { showingTripCreation = true }
                )
            } else {
                // Fallback if no trip selected
                NavigationView {
                    TripSelectionView(
                        selectedTrip: $selectedTrip,
                        showingTripPicker: $showingTripPicker
                    )
                    .navigationTitle("Driver App")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .sheet(isPresented: $showingTripPicker) {
            TripPickerSheet(
                selectedTrip: $selectedTrip,
                showingPicker: $showingTripPicker,
                onCreateNewTapped: {
                    showingTripPicker = false
                    showingTripCreation = true
                }
            )
        }
        .sheet(isPresented: $showingTripCreation) {
            TripCreationView(createdTrip: $newlyCreatedTrip)
        }
        .onChange(of: newlyCreatedTrip) {
            if let trip = newlyCreatedTrip {
                selectedTrip = trip
                newlyCreatedTrip = nil
            }
        }
    }
}
