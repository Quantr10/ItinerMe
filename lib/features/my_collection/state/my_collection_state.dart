import 'package:itinerme/core/models/trip.dart';

class MyCollectionState {
  final List<Trip> createdTrips;
  final List<Trip> savedTrips;
  final List<Trip> displayedTrips;
  final bool isLoading;
  final bool isSearching;
  final bool showingMyTrips;

  const MyCollectionState({
    this.createdTrips = const [],
    this.savedTrips = const [],
    this.displayedTrips = const [],
    this.isLoading = true,
    this.isSearching = false,
    this.showingMyTrips = true,
  });

  MyCollectionState copyWith({
    List<Trip>? createdTrips,
    List<Trip>? savedTrips,
    List<Trip>? displayedTrips,
    bool? isLoading,
    bool? isSearching,
    bool? showingMyTrips,
  }) {
    return MyCollectionState(
      createdTrips: createdTrips ?? this.createdTrips,
      savedTrips: savedTrips ?? this.savedTrips,
      displayedTrips: displayedTrips ?? this.displayedTrips,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      showingMyTrips: showingMyTrips ?? this.showingMyTrips,
    );
  }
}
