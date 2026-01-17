import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_place/google_place.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import '../../../core/models/trip.dart';
import '../../../core/widgets/main_scaffold.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/trip_detail_controller.dart';
import '../widgets/itinerary_day_section.dart';
import '../widgets/trip_cover_header.dart';
import '../widgets/trip_info_header.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;
  final int currentIndex;

  const TripDetailScreen({
    super.key,
    required this.trip,
    this.currentIndex = 0,
  });

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _dayKeys = {};

  late TripDetailController controller;

  @override
  void initState() {
    super.initState();
    controller = TripDetailController(widget.trip);
    _syncDayKeys();

    controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _syncDayKeys() {
    _dayKeys.clear();
    for (int i = 0; i < widget.trip.itinerary.length; i++) {
      _dayKeys[i] = GlobalKey();
    }
  }

  void _scrollToDay(int index) {
    final keyContext = _dayKeys[index]?.currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: AppTheme.animationDuration,
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _openDateRangePicker() async {
    List<DateTime?> selectedDates = [
      widget.trip.startDate,
      widget.trip.endDate,
    ];

    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Select Date',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppTheme.largeFontSize,
            ),
          ),
          insetPadding: AppTheme.largePadding,
          content: SizedBox(
            height: 250,
            width: 350,
            child: CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                calendarType: CalendarDatePicker2Type.range,
                selectedDayHighlightColor: AppTheme.primaryColor,
                centerAlignModePicker: true,
                dayTextStyle: const TextStyle(
                  fontSize: AppTheme.defaultFontSize,
                ),
                weekdayLabelTextStyle: const TextStyle(
                  fontSize: AppTheme.defaultFontSize,
                  fontWeight: FontWeight.bold,
                ),
                controlsHeight: 50,
                useAbbrLabelForMonthModePicker: true,
                daySplashColor: Colors.transparent,
                disabledDayTextStyle: const TextStyle(
                  color: AppTheme.hintColor,
                ),
                modePickersGap: 8,

                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              ),
              value: selectedDates,
              onValueChanged: (dates) => selectedDates = dates,
            ),
          ),
          actions: [
            AppTheme.dialogCancelButton(dialogContext),
            AppTheme.dialogPrimaryButton(
              context: dialogContext,
              label: 'Save',
              onPressed: () async {
                if (selectedDates.length == 2 &&
                    selectedDates[0] != null &&
                    selectedDates[1] != null) {
                  final newStart = DateTime(
                    selectedDates[0]!.year,
                    selectedDates[0]!.month,
                    selectedDates[0]!.day,
                  );
                  final newEnd = DateTime(
                    selectedDates[1]!.year,
                    selectedDates[1]!.month,
                    selectedDates[1]!.day,
                    23,
                    59,
                  );

                  final success = await controller.changeDateRange(
                    newStart,
                    newEnd,
                  );

                  Navigator.pop(dialogContext, success);
                } else {
                  Navigator.pop(dialogContext, false);
                }
              },
            ),
          ],
        );
      },
    );

    if (ok == true) {
      _syncDayKeys();
      AppTheme.success('Date range updated');
    } else if (ok == false) {
      AppTheme.error('Failed to update date');
    }
  }

  Future<void> _showAddDestinationDialog(int dayIndex) async {
    String query = '';
    List<AutocompletePrediction> results = [];
    AutocompletePrediction? selectedPrediction;
    final TextEditingController _searchController = TextEditingController();

    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Add Destination',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppTheme.largeFontSize,
                ),
              ),
              insetPadding: AppTheme.largePadding,
              content: SizedBox(
                height: 250,
                width: 350,
                child: Column(
                  children: [
                    // ===== GIỮ NGUYÊN TEXTFIELD CỦA BẠN =====
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadius,
                        ),
                        boxShadow: [AppTheme.defaultShadow],
                      ),
                      child: SizedBox(
                        height: AppTheme.fieldHeight,
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: (value) async {
                            query = value.trim();
                            if (query.isEmpty) {
                              if (Navigator.of(context).canPop()) {
                                setModalState(() => results = []);
                              }
                              return;
                            }
                            final list = await controller
                                .searchDestinationInTrip(query);
                            if (!context.mounted ||
                                !Navigator.of(context).canPop())
                              return;
                            setModalState(() => results = list);
                          },
                          decoration: AppTheme.inputDecoration(
                            'Type a place',
                            onClear: () => _searchController.clear(),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppTheme.primaryColor,
                              size: AppTheme.largeIconFont,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: AppTheme.defaultFontSize,
                          ),
                        ),
                      ),
                    ),

                    AppTheme.smallSpacing,

                    if (results.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (_, index) {
                            final prediction = results[index];
                            return ListTile(
                              leading: const Icon(
                                Icons.place,
                                color: AppTheme.primaryColor,
                              ),
                              title: Text(
                                prediction.description ?? '',
                                style: const TextStyle(
                                  fontSize: AppTheme.defaultFontSize,
                                  color: Colors.black,
                                ),
                              ),
                              selected: selectedPrediction == prediction,
                              onTap: () {
                                setModalState(() {
                                  selectedPrediction = prediction;
                                  _searchController.text =
                                      prediction.description ?? '';
                                  results = [];
                                });
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                AppTheme.dialogCancelButton(dialogContext),

                AppTheme.dialogPrimaryButton(
                  context: dialogContext,
                  label: 'Add',
                  onPressed:
                      selectedPrediction == null
                          ? null
                          : () async {
                            final success = await controller
                                .addDestinationFromSearch(
                                  dayIndex,
                                  selectedPrediction!,
                                );

                            // return result
                            Navigator.pop(dialogContext, success);
                          },
                ),
              ],
            );
          },
        );
      },
    );

    // ===== SNACKBAR OUTSIDE =====
    if (ok == true) {
      AppTheme.success('Destination added');
    } else if (ok == false) {
      AppTheme.error('Destination already exists');
    }
  }

  void _showCoverImageOptions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'Choose Cover Image',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppTheme.largeFontSize,
              ),
            ),
            insetPadding: AppTheme.largePadding,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.image_search,
                    size: AppTheme.largeIconFont,
                  ),
                  title: const Text('Choose from Google'),
                  onTap: () {
                    Navigator.pop(context);
                    _selectCoverFromGooglePhotos();
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Upload from your phone'),
                  onTap: () async {
                    Navigator.pop(context);
                    final ok = await controller.updateCoverFromDevice();
                    if (ok) {
                      AppTheme.success('Cover photo updated');
                    } else {
                      AppTheme.error('Failed to update cover photo');
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _selectCoverFromGooglePhotos() async {
    final photos = await controller.getTripPhotoReferences();

    if (photos.isEmpty) {
      AppTheme.error('No photos available for this location');
      return;
    }

    String? selectedPhotoReference;

    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Choose Cover Image',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppTheme.largeFontSize,
                ),
              ),
              backgroundColor: Colors.white,
              insetPadding: AppTheme.largePadding,
              content: SizedBox(
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: photos.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 9,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final ref = photos[index];
                    final url =
                        'https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=$ref&key=${dotenv.env['GOOGLE_MAPS_API_KEY']}';

                    final isSelected = selectedPhotoReference == ref;

                    return GestureDetector(
                      onTap:
                          () => setState(() {
                            selectedPhotoReference = ref;
                          }),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: Positioned.fill(
                                    child: AppTheme.loadingScreen(),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.broken_image),
                                );
                              },
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              actions: [
                AppTheme.dialogCancelButton(dialogContext),
                AppTheme.dialogPrimaryButton(
                  context: dialogContext,
                  label: 'Select',
                  onPressed:
                      selectedPhotoReference == null
                          ? null
                          : () async {
                            final success = await controller
                                .updateCoverFromGooglePhoto(
                                  selectedPhotoReference!,
                                );
                            Navigator.pop(dialogContext, success);
                          },
                ),
              ],
            );
          },
        );
      },
    );

    // ===== Snackbar OUTSIDE dialog =====
    if (ok == true) {
      AppTheme.success('Cover photo updated');
    } else if (ok == false) {
      AppTheme.error('Failed to update cover photo');
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    return Stack(
      children: [
        MainScaffold(
          currentIndex: widget.currentIndex,
          body: Stack(
            children: [
              Padding(
                padding: AppTheme.defaultPadding,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      TripCoverHeader(
                        trip: trip,
                        canEdit: controller.state.canEdit,
                        onBack: () => Navigator.pop(context),
                        onChangeCover: _showCoverImageOptions,
                      ),
                      AppTheme.smallSpacing,
                      TripInfoHeader(
                        trip: trip,
                        canEdit: controller.state.canEdit,
                        onPickDate: _openDateRangePicker,
                        onSelectDay: _scrollToDay,
                      ),
                      AppTheme.mediumSpacing,
                      ...trip.itinerary.asMap().entries.map((entry) {
                        final dayIndex = entry.key;
                        final day = entry.value;

                        return ItineraryDaySection(
                          trip: trip,
                          day: day,
                          dayIndex: dayIndex,
                          controller: controller,
                          sectionKey: _dayKeys[dayIndex]!,
                          onAddDestination:
                              () => _showAddDestinationDialog(dayIndex),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (controller.state.isLoading)
          Positioned.fill(child: AppTheme.loadingScreen(overlay: true)),
      ],
    );
  }
}
