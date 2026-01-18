import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_place/google_place.dart';
import 'package:itinerme/core/services/place_image_cache_service.dart';

class GooglePlaceService {
  final GooglePlace place = GooglePlace(dotenv.env['GOOGLE_MAPS_API_KEY']!);

  Future<List<AutocompletePrediction>> autocomplete(
    String query,
    LatLon loc,
  ) async {
    final res = await place.autocomplete.get(
      query,
      location: loc,
      radius: 100000,
      strictbounds: true,
    );
    return res?.predictions ?? [];
  }

  Future<DetailsResult?> getDetails(String placeId) async {
    final res = await place.details.get(placeId);
    return res?.result;
  }

  Future<LatLon?> getLocationCoords(String locationName) async {
    final res = await place.search.getTextSearch(locationName);
    if (res?.results?.isNotEmpty ?? false) {
      final loc = res!.results!.first.geometry!.location!;
      return LatLon(loc.lat!, loc.lng!);
    }
    return null;
  }

  // google_place_service.dart
  Future<DetailsResult?> findBestMatchFromText(String query) async {
    final search = await place.search.getTextSearch(query);
    final match = search?.results?.first;
    if (match?.placeId == null) return null;

    final detail = await place.details.get(match!.placeId!);
    return detail?.result;
  }

  Future<String?> getFirstPhotoCachedUrl({
    required String tripId,
    required String placeId,
    required List<Photo>? photos,
  }) async {
    if (photos == null || photos.isEmpty) return null;

    return PlaceImageCacheService.cachePlacePhoto(
      photoReference: photos.first.photoReference!,
      path: 'destinations/$tripId/$placeId.jpg',
    );
  }

  Future<List<String>> getPhotoReferencesFromLocation(
    String locationName,
  ) async {
    final search = await place.search.getTextSearch(locationName);
    if (search?.results?.isEmpty ?? true) return [];

    final placeId = search!.results!.first.placeId!;
    final detail = await place.details.get(placeId);
    final photos = detail?.result?.photos;
    if (photos == null || photos.isEmpty) return [];

    return photos.map((p) => p.photoReference!).toList();
  }
}
