import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:itinerme/core/models/trip.dart';

import '../state/my_collection_state.dart';

class MyCollectionController {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  MyCollectionController({required this.firestore, required this.auth});

  Future<MyCollectionState> loadTrips() async {
    final user = auth.currentUser;
    if (user == null) return const MyCollectionState(isLoading: false);

    final userDoc = await firestore.collection('users').doc(user.uid).get();

    final createdIds = List<String>.from(
      userDoc.data()?['createdTripIds'] ?? [],
    );
    final savedIds = List<String>.from(userDoc.data()?['savedTripIds'] ?? []);

    final tripsSnap = await firestore.collection('trips').get();
    final trips =
        tripsSnap.docs
            .map((d) => Trip.fromJson({...d.data(), 'id': d.id}))
            .toList();

    final createdTrips = trips.where((t) => createdIds.contains(t.id)).toList();
    final savedTrips = trips.where((t) => savedIds.contains(t.id)).toList();

    return MyCollectionState(
      createdTrips: createdTrips,
      savedTrips: savedTrips,
      displayedTrips: createdTrips,
      isLoading: false,
    );
  }

  MyCollectionState toggleTab(MyCollectionState state, bool showMyTrips) {
    return state.copyWith(
      showingMyTrips: showMyTrips,
      displayedTrips: showMyTrips ? state.createdTrips : state.savedTrips,
    );
  }

  MyCollectionState search(MyCollectionState state, String query) {
    final base = state.showingMyTrips ? state.createdTrips : state.savedTrips;

    final q = query.toLowerCase();

    return state.copyWith(
      displayedTrips:
          base
              .where(
                (t) =>
                    t.name.toLowerCase().contains(q) ||
                    t.location.toLowerCase().contains(q),
              )
              .toList(),
    );
  }

  Future<void> deleteTrip(String tripId) async {
    final user = auth.currentUser!;
    await firestore.collection('trips').doc(tripId).delete();

    await firestore.collection('users').doc(user.uid).update({
      'createdTripIds': FieldValue.arrayRemove([tripId]),
    });
  }

  Future<void> unsaveTrip(String tripId) async {
    final user = auth.currentUser!;
    await firestore.collection('users').doc(user.uid).update({
      'savedTripIds': FieldValue.arrayRemove([tripId]),
    });
  }

  Future<Trip> copyTrip(Trip original, {required String customName}) async {
    final user = auth.currentUser!;
    final doc = firestore.collection('trips').doc();

    final newTrip = Trip(
      id: doc.id,
      name: customName,
      location: original.location,
      coverImageUrl: original.coverImageUrl,
      budget: original.budget,
      startDate: original.startDate,
      endDate: original.endDate,
      transportation: original.transportation,
      interests: List.from(original.interests),
      mustVisitPlaces: List.from(original.mustVisitPlaces),
      itinerary: List.from(original.itinerary),
    );

    await doc.set(newTrip.toJson());

    await firestore.collection('users').doc(user.uid).update({
      'createdTripIds': FieldValue.arrayUnion([doc.id]),
    });

    return newTrip;
  }
}
