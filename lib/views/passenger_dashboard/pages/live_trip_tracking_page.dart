import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/map_marker_helper.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/data/models/firestore/trip_model.dart';
import 'package:ridelink/data/services/google_places_service.dart';
import 'package:ridelink/data/services/trip_service.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class LiveTripTrackingPage extends StatefulWidget {
  const LiveTripTrackingPage({super.key});

  @override
  State<LiveTripTrackingPage> createState() => _LiveTripTrackingPageState();
}

class _LiveTripTrackingPageState extends State<LiveTripTrackingPage> {
  final PassengerDashboardController controller =
      Get.find<PassengerDashboardController>();

  GoogleMapController? _mapController;
  StreamSubscription<TripModel?>? _tripLocationSubscription;

  bool _isLoading = true;
  LatLng? _pickup;
  LatLng? _dropoff;
  List<LatLng> _fullRoute = [];
  List<LatLng> _driverToPickupRoute = [];

  LatLng? _currentDriverLocation;
  final int _minutesToArrival = 7;

  BitmapDescriptor? _pickupPersonMarker;
  BitmapDescriptor? _driverCarMarker;
  BitmapDescriptor? _dropPinMarker;

  bool _isCardExpanded = false;

  @override
  void initState() {
    super.initState();
    final ride =
        controller.currentSelectedRide.value ??
        (Get.arguments is RideModel
            ? Get.arguments as RideModel
            : (Get.arguments is Map &&
                      (Get.arguments as Map)['ride'] is RideModel
                  ? (Get.arguments as Map)['ride'] as RideModel
                  : controller.availableRides.firstOrNull));
    _loadCustomMarkers();
    _startLiveDriverLocationTracking(ride);
    _initializeRealRoute(ride);
  }

  Future<void> _loadCustomMarkers() async {
    final person = await MapMarkerHelper.getPersonMarker();
    final car = await MapMarkerHelper.getCarMarker();
    final pin = await MapMarkerHelper.getDropPinMarker();
    if (mounted) {
      setState(() {
        _pickupPersonMarker = person;
        _driverCarMarker = car;
        _dropPinMarker = pin;
      });
    }
  }

  Future<void> _initializeRealRoute(RideModel? ride) async {
    if (ride == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    LatLng? pickupLatLng;
    LatLng? dropoffLatLng;

    // Check if ride already has valid coordinates (not 0,0 and not Perth defaults)
    final bool isOriginPerthOrZero =
        (ride.originLat == 0.0 && ride.originLng == 0.0) ||
        (ride.originLat == -31.8156 && ride.originLng == 115.8452);
    try {
      final bool isDestPerthOrZero =
          (ride.destinationLat == 0.0 && ride.destinationLng == 0.0) ||
          (ride.destinationLat == -32.0044 && ride.destinationLng == 115.8947);

      if (!isOriginPerthOrZero) {
        pickupLatLng = LatLng(ride.originLat, ride.originLng);
      } else if (ride.origin.isNotEmpty) {
        final geo = await GooglePlacesService.instance
            .getCoordinatesForAddress(ride.origin)
            .timeout(const Duration(seconds: 3), onTimeout: () => null);
        if (geo != null) {
          pickupLatLng = LatLng(geo.latitude, geo.longitude);
        }
      }

      if (!isDestPerthOrZero) {
        dropoffLatLng = LatLng(ride.destinationLat, ride.destinationLng);
      } else if (ride.destination.isNotEmpty) {
        final geo = await GooglePlacesService.instance
            .getCoordinatesForAddress(ride.destination)
            .timeout(const Duration(seconds: 3), onTimeout: () => null);
        if (geo != null) {
          dropoffLatLng = LatLng(geo.latitude, geo.longitude);
        }
      }

      // Safe fallback coordinates so map always initializes
      pickupLatLng ??= const LatLng(-31.9505, 115.8605);
      dropoffLatLng ??= const LatLng(-31.9555, 115.8655);

      // Determine vehicle location based on real driver broadcast from Firestore or trip model
      LatLng? initialVehicleLoc;
      if (ride.id.isNotEmpty) {
        try {
          final liveTrip = await TripService.instance
              .getTrip(ride.id)
              .timeout(const Duration(seconds: 3), onTimeout: () => null);
          if (liveTrip != null &&
              liveTrip.currentDriverLat != 0.0 &&
              liveTrip.currentDriverLng != 0.0) {
            initialVehicleLoc = LatLng(
              liveTrip.currentDriverLat,
              liveTrip.currentDriverLng,
            );
          }
        } catch (_) {}
      }

      if (initialVehicleLoc == null &&
          ride.currentDriverLat != 0.0 &&
          ride.currentDriverLng != 0.0) {
        initialVehicleLoc = LatLng(ride.currentDriverLat, ride.currentDriverLng);
      }

      initialVehicleLoc ??= pickupLatLng;

      // Render initial map and routes immediately (<50ms)
      if (mounted) {
        setState(() {
          _pickup = pickupLatLng;
          _dropoff = dropoffLatLng;
          _fullRoute = [pickupLatLng!, dropoffLatLng!];
          _driverToPickupRoute = (initialVehicleLoc != pickupLatLng)
              ? [initialVehicleLoc!, pickupLatLng]
              : [];
          _currentDriverLocation = _currentDriverLocation ?? initialVehicleLoc;
          _isLoading = false;
        });
      }

      // Fetch refined road polylines asynchronously in background
      final double distToPickup = ((initialVehicleLoc.latitude - pickupLatLng.latitude).abs() +
              (initialVehicleLoc.longitude - pickupLatLng.longitude).abs());

      GooglePlacesService.instance
          .getDirectionsRoute(pickupLatLng, dropoffLatLng)
          .timeout(const Duration(seconds: 3), onTimeout: () => [pickupLatLng!, dropoffLatLng!])
          .then((points) {
        if (!mounted) return;
        if (points.isNotEmpty) {
          setState(() {
            _fullRoute = points;
          });
        }
      });

      if (distToPickup > 0.001) {
        GooglePlacesService.instance
            .getDirectionsRoute(initialVehicleLoc, pickupLatLng)
            .timeout(const Duration(seconds: 3), onTimeout: () => [initialVehicleLoc!, pickupLatLng!])
            .then((legPoints) {
          if (!mounted) return;
          if (legPoints.isNotEmpty) {
            setState(() {
              _driverToPickupRoute = legPoints;
            });
          }
        });
      }

      _fitBounds();
    } catch (e) {
      debugPrint('[LiveTripTrackingPage] Route init error: $e');
    } finally {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startLiveDriverLocationTracking(RideModel? ride) {
    if (ride == null || ride.id.isEmpty) return;
    _tripLocationSubscription?.cancel();
    _tripLocationSubscription = TripService.instance.streamTrip(ride.id).listen(
      (liveTrip) {
        if (liveTrip == null) return;

        // Check if driver has completed the trip / dropped off the passenger
        if (liveTrip.status.toLowerCase() == 'completed' && mounted) {
          _tripLocationSubscription?.cancel();
          _showTripCompletedArrivalDialog(ride, liveTrip);
          return;
        }

        if (liveTrip.currentDriverLat != 0.0 &&
            liveTrip.currentDriverLng != 0.0 &&
            mounted) {
          final newLoc = LatLng(
            liveTrip.currentDriverLat,
            liveTrip.currentDriverLng,
          );
          setState(() {
            _currentDriverLocation = newLoc;
            if (_pickup != null) {
              final double distToPickup = ((newLoc.latitude - _pickup!.latitude).abs() +
                      (newLoc.longitude - _pickup!.longitude).abs());
              if (distToPickup > 0.0005) {
                if (_driverToPickupRoute.isNotEmpty) {
                  _driverToPickupRoute[0] = newLoc;
                } else {
                  _driverToPickupRoute = [newLoc, _pickup!];
                }
              } else {
                _driverToPickupRoute = [];
              }
            }
          });
        }
      },
    );
  }

  void _showTripCompletedArrivalDialog(RideModel ride, TripModel trip) {
    double passengerRating = 5.0;
    final List<String> availableBadges = [
      'Punctual',
      'Smooth Driver',
      'Clean Vehicle',
      'Friendly Conversation',
      'Felt Very Safe',
    ];
    final Set<String> selectedBadges = {'Smooth Driver', 'Felt Very Safe'};
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20.w,
              18.h,
              20.w,
              MediaQuery.of(context).padding.bottom + 20.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  16.verticalSpace,
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: const Color(0xFF16A34A),
                      size: 44.sp,
                    ),
                  ),
                  12.verticalSpace,
                  Text(
                    'You Have Arrived! 🏁',
                    style: AppTextStyle.text20Semibold.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  6.verticalSpace,
                  Text(
                    'Your driver ${ride.driverName} has dropped you off at ${ride.destination}.\nPayment of \$${ride.pricePerSeat.toStringAsFixed(0)} AUD has been settled.',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.text12Regular.copyWith(
                      color: AppColors.secondaryTextColor,
                      height: 1.4,
                    ),
                  ),
                  16.verticalSpace,

                  // Star rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final star = index + 1.0;
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() => passengerRating = star);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: Icon(
                            index < passengerRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 38.sp,
                          ),
                        ),
                      );
                    }),
                  ),
                  6.verticalSpace,
                  Text(
                    '${passengerRating.toStringAsFixed(1)} Stars',
                    style: AppTextStyle.text14Semibold.copyWith(
                      color: const Color(0xFFD97706),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  14.verticalSpace,

                  // Badges
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    alignment: WrapAlignment.center,
                    children: availableBadges.map((b) {
                      final isSelected = selectedBadges.contains(b);
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            if (isSelected) {
                              selectedBadges.remove(b);
                            } else {
                              selectedBadges.add(b);
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            b,
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: isSelected
                                  ? const Color(0xFF1D4ED8)
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  14.verticalSpace,

                  // Note
                  TextField(
                    controller: commentController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Share a note about your journey...',
                      hintStyle: AppTextStyle.text12Regular.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: EdgeInsets.all(12.w),
                    ),
                  ),
                  18.verticalSpace,

                  // Submit and Return
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(); // dismiss sheet
                        Get.back(); // exit tracking page back to dashboard
                        AppSnackBar.success(
                          message:
                              'Thank you for riding with RideLink! Review for ${ride.driverName} submitted.',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'Submit Review & Complete',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _fitBounds() {
    if (_mapController == null) return;
    try {
      final List<LatLng> pointsToFit = List<LatLng>.from(_fullRoute);
      if (_driverToPickupRoute.isNotEmpty) {
        pointsToFit.addAll(_driverToPickupRoute);
      }
      if (_currentDriverLocation != null) {
        pointsToFit.add(_currentDriverLocation!);
      }
      if (pointsToFit.isEmpty) return;

      double minLat = pointsToFit.first.latitude;
      double maxLat = pointsToFit.first.latitude;
      double minLng = pointsToFit.first.longitude;
      double maxLng = pointsToFit.first.longitude;

      for (final p in pointsToFit) {
        if (p.latitude < minLat) minLat = p.latitude;
        if (p.latitude > maxLat) maxLat = p.latitude;
        if (p.longitude < minLng) minLng = p.longitude;
        if (p.longitude > maxLng) maxLng = p.longitude;
      }

      if ((maxLat - minLat).abs() < 0.005) {
        minLat -= 0.005;
        maxLat += 0.005;
      }
      if ((maxLng - minLng).abs() < 0.005) {
        minLng -= 0.005;
        maxLng += 0.005;
      }

      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 40));
    } catch (_) {}
  }

  MapType _currentMapType = MapType.normal;
  bool _trafficEnabled = false;

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _recenterVehicle() {
    if (_currentDriverLocation == null) return;
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentDriverLocation!, zoom: 15.5, tilt: 35.0),
      ),
    );
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _toggleTraffic() {
    setState(() {
      _trafficEnabled = !_trafficEnabled;
    });
  }

  void _showCancelBookingConfirmation(RideModel ride) {
    String selectedReason = 'Change of plans';
    final List<String> reasons = [
      'Change of plans',
      'Emergency came up',
      'Found another ride',
      'Driver delayed',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(
            20.w,
            16.h,
            20.w,
            MediaQuery.of(context).padding.bottom + 20.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              18.verticalSpace,
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: AppColors.red,
                      size: 24.sp,
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cancel Active Ride?',
                          style: AppTextStyle.text18Semibold.copyWith(
                            color: AppColors.primaryTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        2.verticalSpace,
                        Text(
                          'Driver: ${ride.driverName}',
                          style: AppTextStyle.text12Regular.copyWith(
                            color: AppColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              14.verticalSpace,
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_rounded,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                    10.horizontalSpace,
                    Expanded(
                      child: Text(
                        'Cancelling this ride will immediately notify ${ride.driverName} and release your seat.',
                        style: AppTextStyle.text12Regular.copyWith(
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              16.verticalSpace,
              Text(
                'Reason for cancellation (optional):',
                style: AppTextStyle.text12Semibold.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              8.verticalSpace,
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: reasons.map((r) {
                  final isSelected = selectedReason == r;
                  return ChoiceChip(
                    label: Text(r),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        setSheetState(() => selectedReason = r);
                      }
                    },
                    selectedColor: const Color(0xFFFEE2E2),
                    backgroundColor: AppColors.containerFillColor,
                    labelStyle: AppTextStyle.text10Medium.copyWith(
                      color: isSelected
                          ? AppColors.red
                          : AppColors.primaryTextColor,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.red
                            : AppColors.borderColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
              20.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        side: const BorderSide(color: AppColors.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Keep Ride',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: AppColors.primaryTextColor,
                        ),
                      ),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        // Find active booking for this ride
                        final booking = controller.myBookings.firstWhereOrNull(
                          (b) => b.ride.id == ride.id,
                        );
                        if (booking != null) {
                          controller.cancelBooking(
                            booking,
                            reason: selectedReason,
                          );
                        } else {
                          // Try pending request
                          final pending = controller.pendingRequests
                              .firstWhereOrNull((p) => p.ride.id == ride.id);
                          if (pending != null) {
                            controller.cancelPendingRequest(
                              pending,
                              reason: selectedReason,
                            );
                          } else {
                            TripService.instance.cancelTripBooking(
                              bookingId: 'trip_${ride.id}',
                              tripId: ride.id,
                              driverId: ride.driverId,
                              seats: controller.requestedSeats.value,
                              wasAccepted: true,
                              reason: selectedReason,
                            );
                            AppSnackBar.info(
                              message:
                                  'Ride cancelled. The driver has been notified.',
                            );
                          }
                        }
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Cancel Ride',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tripLocationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ride =
        controller.currentSelectedRide.value ??
        (Get.arguments is RideModel
            ? Get.arguments as RideModel
            : (Get.arguments is Map &&
                      (Get.arguments as Map)['ride'] is RideModel
                  ? (Get.arguments as Map)['ride'] as RideModel
                  : controller.availableRides.firstOrNull));

    // Show center circular spinner only while essential data is resolving
    if (_isLoading || _pickup == null || _dropoff == null || ride == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              CupertinoIcons.arrow_left,
              color: Color(0xFF0F172A),
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Live Trip Tracking',
            style: AppTextStyle.text18Bold.copyWith(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 44.w,
                height: 44.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                ),
              ),
              20.verticalSpace,
              Text(
                'Loading live route & tracking...',
                style: AppTextStyle.text16Semibold.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              8.verticalSpace,
              Text(
                'Connecting to real-time driver coordinates and route',
                style: AppTextStyle.text12Regular.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Full Screen Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentDriverLocation ?? _pickup!,
              zoom: 14.5,
            ),
            onMapCreated: (map) {
              _mapController = map;
              Future.delayed(const Duration(milliseconds: 350), () {
                if (mounted) _fitBounds();
              });
            },
            markers: {
              Marker(
                markerId: const MarkerId('pickup_marker'),
                position: _pickup!,
                zIndexInt: 2,
                infoWindow: InfoWindow(title: 'Pickup: ${ride.origin}'),
                icon:
                    _pickupPersonMarker ??
                    BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ),
              ),
              Marker(
                markerId: const MarkerId('driver_vehicle'),
                position: _currentDriverLocation!,
                zIndexInt: 10,
                anchor: const Offset(0.5, 0.5),
                flat: true,
                infoWindow: InfoWindow(
                  title: '${ride.driverName} (${ride.carModel})',
                  snippet: 'Driver Vehicle Location',
                ),
                icon:
                    _driverCarMarker ??
                    BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    ),
              ),
              Marker(
                markerId: const MarkerId('dropoff_marker'),
                position: _dropoff!,
                zIndexInt: 3,
                infoWindow: InfoWindow(title: 'Drop-off: ${ride.destination}'),
                icon:
                    _dropPinMarker ??
                    BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
              ),
            },
            polylines: {
              if (_driverToPickupRoute.isNotEmpty)
                Polyline(
                  polylineId: const PolylineId('driver_to_pickup_route'),
                  points: _driverToPickupRoute,
                  color: const Color(0xFF0D9488), // Teal: Driver approaching pickup
                  width: 5,
                  patterns: [PatternItem.dash(20), PatternItem.gap(10)],
                ),
              Polyline(
                polylineId: const PolylineId('active_trip_route'),
                points: _fullRoute,
                color: const Color(0xFF2563EB), // Blue: Pickup to drop-off
                width: 5,
              ),
            },
            mapType: _currentMapType,
            trafficEnabled: _trafficEnabled,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            indoorViewEnabled: false,
          ),

          // Floating Map Shortcuts Toolbar (Right side floating action column)
          Positioned(
            right: 16.w,
            top: MediaQuery.of(context).padding.top + 72.h,
            child: Column(
              children: [
                // 1. Recenter / Target vehicle
                _MapShortcutButton(
                  icon: CupertinoIcons.location_fill,
                  tooltip: 'Recenter Vehicle',
                  iconColor: const Color(0xFF2563EB),
                  onTap: _recenterVehicle,
                ),
                10.verticalSpace,

                // 2. Fit Route
                _MapShortcutButton(
                  icon: CupertinoIcons.arrow_up_left_arrow_down_right,
                  tooltip: 'Fit Full Route',
                  iconColor: const Color(0xFF0F172A),
                  onTap: _fitBounds,
                ),
                10.verticalSpace,

                // 3. Zoom In & Out Pill
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16.r),
                          ),
                          onTap: _zoomIn,
                          child: Padding(
                            padding: EdgeInsets.all(10.r),
                            child: const Icon(
                              Icons.add_rounded,
                              size: 20,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 26.w,
                        height: 1,
                        color: const Color(0xFFE2E8F0),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(16.r),
                          ),
                          onTap: _zoomOut,
                          child: Padding(
                            padding: EdgeInsets.all(10.r),
                            child: const Icon(
                              Icons.remove_rounded,
                              size: 20,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                10.verticalSpace,

                // 4. Map Type Switcher (Normal / Satellite)
                _MapShortcutButton(
                  icon: _currentMapType == MapType.satellite
                      ? Icons.layers_rounded
                      : Icons.layers_outlined,
                  tooltip: 'Toggle Satellite',
                  iconColor: _currentMapType == MapType.satellite
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF475569),
                  isActive: _currentMapType == MapType.satellite,
                  onTap: _toggleMapType,
                ),
                10.verticalSpace,

                // 5. Traffic Toggle
                _MapShortcutButton(
                  icon: Icons.traffic_rounded,
                  tooltip: 'Toggle Traffic',
                  iconColor: _trafficEnabled
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF475569),
                  isActive: _trafficEnabled,
                  onTap: _toggleTraffic,
                ),
              ],
            ),
          ),

          // Top Header Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.back,
                      color: AppColors.primaryTextColor,
                      size: 20,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      8.horizontalSpace,
                      Text(
                        'Live Trip In Progress',
                        style: AppTextStyle.text12Semibold.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.passengerSafetySos),
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      color: Color(0xFFDC2626),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Slide Card: Driver details, live ETA, and actions
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: MediaQuery.of(context).padding.bottom + 12.h,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag / Expand Handle
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isCardExpanded = !_isCardExpanded;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 4.h,
                          horizontal: 16.w,
                        ),
                        color: Colors.transparent,
                        child: Container(
                          width: 36.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                  4.verticalSpace,

                  // Minimal Header: Driver Avatar, Name & ETA
                  Row(
                    children: [
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            ride.driverName.substring(0, 1),
                            style: AppTextStyle.text16Semibold.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      10.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride.driverName,
                              style: AppTextStyle.text14Semibold.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${ride.carModel} • ${ride.carPlate}',
                              style: AppTextStyle.text10Medium.copyWith(
                                color: AppColors.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          'ETA $_minutesToArrival min',
                          style: AppTextStyle.text10Medium.copyWith(
                            color: const Color(0xFF16A34A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      4.horizontalSpace,
                      // Quick expand/collapse chevron
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          _isCardExpanded
                              ? CupertinoIcons.chevron_down
                              : CupertinoIcons.chevron_up,
                          size: 18,
                          color: const Color(0xFF64748B),
                        ),
                        onPressed: () {
                          setState(() {
                            _isCardExpanded = !_isCardExpanded;
                          });
                        },
                      ),
                    ],
                  ),

                  8.verticalSpace,
                  // Quick PIN banner for boarding
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.lock_shield_fill,
                              color: Color(0xFF2563EB),
                              size: 14,
                            ),
                            6.horizontalSpace,
                            Text(
                              'Pickup PIN (Share with driver):',
                              style: AppTextStyle.text10Medium.copyWith(
                                color: const Color(0xFF1E40AF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: const Color(0xFF93C5FD)),
                          ),
                          child: Text(
                            '1234',
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: const Color(0xFF1E3A8A),
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Expanded Details: Fare & Contact Actions
                  if (_isCardExpanded) ...[
                    10.verticalSpace,
                    const Divider(color: AppColors.borderColor, height: 1),
                    10.verticalSpace,

                    // Cash Fare
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.containerFillColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.payments_rounded,
                                color: Color(0xFF16A34A),
                                size: 16,
                              ),
                              6.horizontalSpace,
                              Text(
                                'Fare (Cash Only)',
                                style: AppTextStyle.text10Medium.copyWith(
                                  color: AppColors.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '\$${(ride.pricePerSeat * controller.requestedSeats.value).toStringAsFixed(0)} AUD',
                            style: AppTextStyle.text12Semibold.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    12.verticalSpace,

                    // Action Buttons: Chat & Call Driver
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Get.toNamed(
                                AppRoutes.rideChat,
                                arguments: {
                                  'tripId': ride.id,
                                  'driverName': ride.driverName,
                                  'carModel': ride.carModel,
                                  'route':
                                      '${ride.origin} → ${ride.destination}',
                                },
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.borderColor,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 9.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            icon: const Icon(
                              CupertinoIcons.chat_bubble_2_fill,
                              size: 16,
                            ),
                            label: Text(
                              'Chat',
                              style: AppTextStyle.text12Semibold.copyWith(
                                color: AppColors.primaryTextColor,
                              ),
                            ),
                          ),
                        ),
                        10.horizontalSpace,
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await Utils.launchURL('tel:0412345678');
                              } catch (_) {
                                AppSnackBar.info(
                                  message: 'Dialing driver phone...',
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 9.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            icon: const Icon(
                              CupertinoIcons.phone_fill,
                              size: 16,
                            ),
                            label: Text(
                              'Call Driver',
                              style: AppTextStyle.text12Semibold.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    10.verticalSpace,

                    // Cancel Ride Option
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () => _showCancelBookingConfirmation(ride),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.red,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                        ),
                        icon: const Icon(
                          CupertinoIcons.xmark_circle,
                          size: 16,
                          color: AppColors.red,
                        ),
                        label: Text(
                          'Cancel Ride',
                          style: AppTextStyle.text12Semibold.copyWith(
                            color: AppColors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapShortcutButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color iconColor;
  final bool isActive;
  final VoidCallback onTap;

  const _MapShortcutButton({
    required this.icon,
    required this.tooltip,
    required this.iconColor,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEFF6FF) : Colors.white,
        shape: BoxShape.circle,
        border: isActive
            ? Border.all(color: const Color(0xFF93C5FD), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Tooltip(
            message: tooltip,
            child: Padding(
              padding: EdgeInsets.all(10.r),
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
