import 'package:google_place/google_place.dart';
import 'package:flutter/material.dart';
import 'package:itinerme/core/repositories/trip_repository.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/trip_detail_state.dart';

import '../../../core/enums/transportation_enums.dart';
import '../../../core/models/trip.dart';
import '../../../core/models/destination.dart';
import '../../../core/models/itinerary_day.dart';

import '../../../core/services/google_place_service.dart';
import '../../../core/services/travel_service.dart';
import '../../../core/services/trip_ai_service.dart';
import '../../../core/services/trip_media_service.dart';

class TripDetailController extends ChangeNotifier {
  final Trip trip;
  final TripRepository tripRepo;
  final TripAIService aiService;
  final GooglePlaceService placeService;
  final TravelService travelService;
  final TripMediaService coverService;

  TripDetailState _state = const TripDetailState();
  TripDetailState get state => _state;

  TripDetailController({
    required this.trip,
    required this.tripRepo,
    required this.aiService,
    required this.placeService,
    required this.travelService,
    required this.coverService,
  }) {
    checkEditPermission();
  }

  Future<void> checkEditPermission() async {
    try {
      final createdIds = await tripRepo.getCreatedTripIds();
      _state = _state.copyWith(canEdit: createdIds.contains(trip.id));
      notifyListeners();
    } catch (_) {
      // nếu fail thì cứ giữ canEdit = false
    }
  }

  void toggleExpand(String placeId) {
    final updated = Set<String>.from(_state.expandedDestinations);
    if (updated.contains(placeId)) {
      updated.remove(placeId);
    } else {
      updated.add(placeId);
    }
    _state = _state.copyWith(expandedDestinations: updated);
    notifyListeners();
  }

  Future<bool> removeDestination(int dayIndex, int destIndex) async {
    try {
      final removed = trip.itinerary[dayIndex].destinations.removeAt(destIndex);

      final updated = Set<String>.from(_state.expandedDestinations)
        ..remove(removed.name);

      _state = _state.copyWith(expandedDestinations: updated);
      notifyListeners();

      await tripRepo.updateItinerary(trip.id, trip.itinerary);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteDay(int dayIndex) async {
    try {
      trip.itinerary[dayIndex].destinations.clear();
      _state = _state.copyWith(expandedDestinations: {});
      notifyListeners();

      await tripRepo.updateItinerary(trip.id, trip.itinerary);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, String>?> getTravelInfo({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required TransportationType preferredTransport,
  }) {
    return travelService.getDirections(
      oLat: originLat,
      oLng: originLng,
      dLat: destLat,
      dLng: destLng,
      mode: preferredTransport.googleMode,
    );
  }

  //   Future<bool> generateSingleDay(int dayIndex) async {
  //     _state = _state.copyWith(isLoading: true);
  //     notifyListeners();

  //     try {
  //       final prompt = '''
  // You are a professional travel planner. Your task is to generate a precise list of tourist attractions in ${trip.location} for one day.

  // Each day should have 3-5 destinations and **fully utilized** with realistic visit durations.
  // Prioritize must-visit places but **reorder them for optimal routing**.
  // Use **precise place names**, avoiding nicknames or abbreviations.
  // Make each day's destinations **geographically logical**. Cluster nearby locations together and do not split adjacent spots into different days.

  // Return a valid JSON array only, no explanation or markdown:
  // [
  //   {
  //     "name": "Place Name",
  //     "description": "Detail description",
  //     "durationMinutes": 90,
  //   }
  // ]

  // ''';

  //       final res = await http.post(
  //         Uri.parse('https://api.openai.com/v1/chat/completions'),
  //         headers: {
  //           'Authorization': 'Bearer ${dotenv.env['OPENAI_API_KEY']}',
  //           'Content-Type': 'application/json',
  //         },
  //         body: jsonEncode({
  //           'model': 'gpt-4',
  //           'messages': [
  //             {'role': 'user', 'content': prompt},
  //           ],
  //         }),
  //       );

  //       final content =
  //           jsonDecode(
  //                 utf8.decode(res.bodyBytes),
  //               )['choices'][0]['message']['content']
  //               .replaceAll('```json', '')
  //               .replaceAll('```', '')
  //               .trim();

  //       final List<dynamic> places = jsonDecode(content);

  //       final List<Destination> newDest = [];
  //       final existingNames =
  //           trip.itinerary
  //               .expand((d) => d.destinations)
  //               .map((d) => d.name.toLowerCase().trim())
  //               .toSet();

  //       for (final p in places) {
  //         final normalized = p['name'].toString().toLowerCase().trim();
  //         if (existingNames.contains(normalized)) continue;
  //         final search = await googlePlace.search.getTextSearch(
  //           '${p['name']}, ${trip.location}',
  //         );
  //         final match = search?.results?.first;
  //         if (match == null) continue;

  //         final detail = await googlePlace.details.get(match.placeId!);
  //         final result = detail?.result;
  //         if (result == null) continue;

  //         String? imageUrl;
  //         if (result.photos?.isNotEmpty == true) {
  //           imageUrl = await PlaceImageCacheService.cachePlacePhoto(
  //             photoReference: result.photos!.first.photoReference!,
  //             path: 'destinations/${trip.id}/${result.placeId}.jpg',
  //           );
  //         }
  //         final exists = trip.itinerary
  //             .expand((d) => d.destinations)
  //             .any((d) => d.placeId == result.placeId);

  //         if (exists) continue;
  //         existingNames.add(normalized);

  //         newDest.add(
  //           Destination(
  //             placeId: result.placeId!,
  //             name: result.name!,
  //             description: p['description'],
  //             durationMinutes: p['durationMinutes'],
  //             latitude: result.geometry!.location!.lat!,
  //             longitude: result.geometry!.location!.lng!,
  //             address: result.formattedAddress ?? '',
  //             imageUrl: imageUrl,
  //           ),
  //         );
  //       }

  //       trip.itinerary[dayIndex].destinations.addAll(newDest);

  //       await FirebaseFirestore.instance.collection('trips').doc(trip.id).update({
  //         'itinerary': trip.itinerary.map((e) => e.toJson()).toList(),
  //       });

  //       notifyListeners();
  //       return true;
  //     } catch (_) {
  //       return false;
  //     } finally {
  //       _state = _state.copyWith(isLoading: false);
  //       notifyListeners();
  //     }
  //   }

  Future<bool> generateSingleDay(int dayIndex) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final places = await aiService.generateDayPlan(trip.location);

      final existingNames =
          trip.itinerary
              .expand((d) => d.destinations)
              .map((d) => d.name.toLowerCase().trim())
              .toSet();

      final List<Destination> newDest = [];

      for (final p in places) {
        final rawName = p['name']?.toString() ?? '';
        final normalized = rawName.toLowerCase().trim();
        if (normalized.isEmpty || existingNames.contains(normalized)) continue;

        // 1) search details by text -> place service (mình đưa thêm function gợi ý bên dưới)
        final result = await placeService.findBestMatchFromText(
          '$rawName, ${trip.location}',
        );
        if (result == null || result.placeId == null) continue;

        // 2) cache photo (service place sẽ trả imageUrl luôn, hoặc bạn gọi cache service tại placeService)
        final imageUrl = await placeService.getFirstPhotoCachedUrl(
          tripId: trip.id,
          placeId: result.placeId!,
          photos: result.photos,
        );

        // 3) tránh duplicate placeId
        final exists = trip.itinerary
            .expand((d) => d.destinations)
            .any((d) => d.placeId == result.placeId);
        if (exists) continue;

        existingNames.add(normalized);

        newDest.add(
          Destination(
            placeId: result.placeId!,
            name: result.name ?? rawName,
            description: p['description']?.toString() ?? '',
            durationMinutes: (p['durationMinutes'] as num?)?.toInt() ?? 60,
            latitude: result.geometry?.location?.lat ?? 0.0,
            longitude: result.geometry?.location?.lng ?? 0.0,
            address: result.formattedAddress ?? '',
            imageUrl: imageUrl,
          ),
        );
      }

      trip.itinerary[dayIndex].destinations.addAll(newDest);

      await tripRepo.updateItinerary(trip.id, trip.itinerary);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    } finally {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  Future<bool> updateCoverFromDevice() async {
    try {
      final url = await coverService.uploadFromDevice(trip.id);
      if (url == null) return false;

      trip.coverImageUrl = url;
      await tripRepo.updateCover(trip.id, url);

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> openDirections(
    double oLat,
    double oLng,
    double dLat,
    double dLng,
    String mode,
  ) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&origin=$oLat,$oLng&destination=$dLat,$dLng&travelmode=$mode',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<bool> addDestinationFromSearch(
    int dayIndex,
    AutocompletePrediction prediction,
  ) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final placeId = prediction.placeId!;
      final details = await placeService.getDetails(placeId);
      if (details == null) return false;

      final exists = trip.itinerary
          .expand((d) => d.destinations)
          .any((d) => d.placeId == details.placeId);
      if (exists) return false;

      final aiData = await aiService.generatePlaceInfo(
        details.name ?? 'Unnamed',
        details.formattedAddress ?? '',
      );

      final imageUrl = await placeService.getFirstPhotoCachedUrl(
        tripId: trip.id,
        placeId: details.placeId!,
        photos: details.photos,
      );

      final newDest = Destination(
        placeId: details.placeId ?? '',
        name: details.name ?? 'Unnamed',
        address: details.formattedAddress ?? '',
        description: aiData['description']?.toString() ?? '',
        durationMinutes: (aiData['durationMinutes'] as num?)?.toInt() ?? 60,
        latitude: details.geometry?.location?.lat ?? 0.0,
        longitude: details.geometry?.location?.lng ?? 0.0,
        imageUrl: imageUrl,
        rating: details.rating,
        userRatingsTotal: details.userRatingsTotal,
        website: details.website,
        openingHours: details.openingHours?.weekdayText,
        types: details.types,
        url: details.url,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(
          Duration(minutes: (aiData['durationMinutes'] as num?)?.toInt() ?? 60),
        ),
      );

      trip.itinerary[dayIndex].destinations.add(newDest);

      await tripRepo.updateItinerary(trip.id, trip.itinerary);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    } finally {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  Future<bool> updateCoverFromGooglePhoto(String photoReference) async {
    try {
      final url = await coverService.uploadFromGoogle(trip.id, photoReference);
      if (url == null) return false;

      trip.coverImageUrl = url;
      await tripRepo.updateCover(trip.id, url);

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<LatLon?> getTripCoordinates() {
    return placeService.getLocationCoords(trip.location);
  }

  Future<List<AutocompletePrediction>> searchDestinationInTrip(
    String query,
  ) async {
    final coords = await getTripCoordinates();
    if (coords == null) return [];
    return placeService.autocomplete(query, coords);
  }

  Future<List<String>> getTripPhotoReferences() async {
    final refs = await placeService.getPhotoReferencesFromLocation(
      trip.location,
    );
    return refs;
  }

  Future<bool> changeDateRange(DateTime start, DateTime end) async {
    try {
      final oldDays = trip.itinerary;
      final oldLength = oldDays.length;
      final newLength = end.difference(start).inDays + 1;

      final newItinerary = List.generate(newLength, (i) {
        final date = start.add(Duration(days: i));
        if (i < oldLength) {
          return ItineraryDay(
            date: date,
            destinations: oldDays[i].destinations,
          );
        }
        return ItineraryDay(date: date, destinations: []);
      });

      trip.startDate = start;
      trip.endDate = end;
      trip.itinerary = newItinerary;

      await tripRepo.updateDates(trip.id, start, end, newItinerary);

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
