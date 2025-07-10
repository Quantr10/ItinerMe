import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  String id;
  String name;
  String location;
  String coverImageUrl;
  int budget;
  DateTime startDate;
  DateTime endDate;
  String transportation;
  List<String> interests;
  List<MustVisitPlace> mustVisitPlaces;
  List<ItineraryDay> itinerary;

  Trip({
    required this.id,
    required this.name,
    required this.location,
    required this.coverImageUrl,
    required this.budget,
    required DateTime startDate,
    required DateTime endDate,
    required this.transportation,
    required this.interests,
    required this.mustVisitPlaces,
    required this.itinerary,
  }) : startDate = DateTime(
         startDate.year,
         startDate.month,
         startDate.day,
         0,
         0,
       ),
       endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'coverImageUrl': coverImageUrl,
    'budget': budget,
    'startDate': Timestamp.fromDate(startDate),
    'endDate': Timestamp.fromDate(endDate),
    'transportation': transportation,
    'interests': interests,
    'mustVisitPlaces': mustVisitPlaces.map((e) => e.toJson()).toList(),
    'itinerary': itinerary.map((e) => e.toJson()).toList(),
  };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json['id'],
    name: json['name'],
    location: json['location'],
    coverImageUrl: json['coverImageUrl'],
    budget: json['budget'],
    startDate:
        json['startDate'] is Timestamp
            ? (json['startDate'] as Timestamp).toDate()
            : DateTime.parse(json['startDate']),
    endDate:
        json['endDate'] is Timestamp
            ? (json['endDate'] as Timestamp).toDate()
            : DateTime.parse(json['endDate']),
    transportation: json['transportation'],
    interests: List<String>.from(json['interests']),
    mustVisitPlaces:
        (json['mustVisitPlaces'] as List)
            .map((e) => MustVisitPlace.fromJson(e))
            .toList(),
    itinerary:
        (json['itinerary'] as List)
            .map((e) => ItineraryDay.fromJson(e))
            .toList(),
  );
}

class ItineraryDay {
  final DateTime date;
  final List<Destination> destinations;

  ItineraryDay({required this.date, required this.destinations});

  Map<String, dynamic> toJson() => {
    'date': Timestamp.fromDate(date),
    'destinations': destinations.map((e) => e.toJson()).toList(),
  };

  factory ItineraryDay.fromJson(Map<String, dynamic> json) => ItineraryDay(
    date:
        json['date'] is Timestamp
            ? (json['date'] as Timestamp).toDate()
            : DateTime.parse(json['date']),
    destinations:
        (json['destinations'] as List)
            .map((e) => Destination.fromJson(e))
            .toList(),
  );
}

class Destination {
  String placeId;
  String name;
  String address;
  String description;
  double latitude;
  double longitude;
  String? photoReference;
  int durationMinutes;
  DateTime? startTime;
  DateTime? endTime;
  List<String>? types;
  String? website;
  List<String>? openingHours;
  double? rating;
  int? userRatingsTotal;
  String? url;

  Destination({
    required this.placeId,
    required this.name,
    required this.address,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.durationMinutes,
    this.startTime,
    this.endTime,
    this.photoReference,
    this.types,
    this.website,
    this.openingHours,
    this.rating,
    this.userRatingsTotal,
    this.url,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'placeId': placeId,
      'name': name,
      'address': address,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'photoReference': photoReference,
      'durationMinutes': durationMinutes,
      'types': types,
      'website': website,
      'openingHours': openingHours,
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
      'url': url,
    };

    if (startTime != null) {
      map['startTime'] = Timestamp.fromDate(startTime!);
    }
    if (endTime != null) {
      map['endTime'] = Timestamp.fromDate(endTime!);
    }

    return map;
  }

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
    placeId: json['placeId'] ?? '',
    name: json['name'] ?? '',
    address: json['address'] ?? '',
    description: json['description'] ?? '',
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    photoReference: json['photoReference'],
    durationMinutes: json['durationMinutes'] ?? 0,
    startTime:
        json['startTime'] != null
            ? (json['startTime'] is Timestamp
                ? (json['startTime'] as Timestamp).toDate()
                : DateTime.tryParse(json['startTime']))
            : null,
    endTime:
        json['endTime'] != null
            ? (json['endTime'] is Timestamp
                ? (json['endTime'] as Timestamp).toDate()
                : DateTime.tryParse(json['endTime']))
            : null,
    types: json['types'] != null ? List<String>.from(json['types']) : null,
    website: json['website'],
    openingHours:
        json['openingHours'] != null
            ? List<String>.from(json['openingHours'])
            : null,
    rating: (json['rating'] as num?)?.toDouble(),
    userRatingsTotal: json['userRatingsTotal'],
    url: json['url'],
  );

  Destination copyWith({
    String? placeId,
    String? name,
    String? address,
    String? description,
    double? latitude,
    double? longitude,
    String? photoReference,
    int? durationMinutes,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? types,
    String? website,
    List<String>? openingHours,
    double? rating,
    int? userRatingsTotal,
    String? url,
  }) {
    return Destination(
      placeId: placeId ?? this.placeId,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoReference: photoReference ?? this.photoReference,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      types: types ?? this.types,
      website: website ?? this.website,
      openingHours: openingHours ?? this.openingHours,
      rating: rating ?? this.rating,
      userRatingsTotal: userRatingsTotal ?? this.userRatingsTotal,
      url: url ?? this.url,
    );
  }
}

class MustVisitPlace {
  final String name;
  final String placeId;

  MustVisitPlace({required this.name, required this.placeId});

  Map<String, dynamic> toJson() => {'name': name, 'placeId': placeId};

  factory MustVisitPlace.fromJson(Map<String, dynamic> json) =>
      MustVisitPlace(name: json['name'], placeId: json['placeId']);
}
