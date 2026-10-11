import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/map_marker_helper.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/google_places_service.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class RideDetailsPage extends GetView<PassengerDashboardController> {
  const RideDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final RideModel? argRide = Get.arguments is RideModel
        ? Get.arguments as RideModel
        : (Get.arguments is Map<String, dynamic>
            ? (Get.arguments['ride'] as RideModel?)
            : null);

    final ride = controller.currentSelectedRide.value ??
        argRide ??
        (controller.availableRides.isNotEmpty
            ? controller.availableRides.first
            : null);

    if (ride == null) {
      return Scaffold(
        backgroundColor: AppColors.secondaryBgColor,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.car, size: 48, color: AppColors.secondaryTextColor),
                12.verticalSpace,
                Text('Ride details unavailable', style: AppTextStyle.text16Semibold),
                16.verticalSpace,
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final int seatsNeeded = controller.requestedSeats.value > 0
        ? controller.requestedSeats.value
        : 1;
    final double seatPrice = (ride.isEnRouteMatch &&
            (ride.enRouteSubFare ?? 0) > 0)
        ? ride.enRouteSubFare!
        : ride.pricePerSeat;
    final double totalPrice = seatPrice * seatsNeeded;

    final String passengerPickup = ride.searchedPickupAddress.isNotEmpty
        ? ride.searchedPickupAddress
        : (controller.fromLocationController.text.trim().isNotEmpty
            ? controller.fromLocationController.text.trim()
            : (ride.pickupSuggestion.isNotEmpty
                ? ride.pickupSuggestion
                : (ride.origin.isNotEmpty ? ride.origin : 'Pickup Location')));

    final String passengerDrop = ride.searchedDropAddress.isNotEmpty
        ? ride.searchedDropAddress
        : (controller.toLocationController.text.trim().isNotEmpty
            ? controller.toLocationController.text.trim()
            : (ride.dropOffPlan.isNotEmpty
                ? ride.dropOffPlan
                : (ride.destination.isNotEmpty ? ride.destination : 'Drop-off Destination')));

    String formattedDeparture = 'Scheduled for upcoming trip';
    if (ride.departureTime.isNotEmpty) {
      formattedDeparture = ride.departureTime;
      if (ride.departureDateTime != null) {
        try {
          formattedDeparture += ' • ${DateFormat('EEE, d MMM').format(ride.departureDateTime!)}';
        } catch (_) {}
      }
    }

    final driverDisplayName = ride.driverName.isNotEmpty ? ride.driverName : 'Driver';
    final vehicleModel = ride.carModel.isNotEmpty ? ride.carModel : 'Vehicle';
    final vehiclePlate = ride.carPlate.isNotEmpty ? ride.carPlate : 'Standard';

    return Scaffold(
      backgroundColor: AppColors.secondaryBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Back Navigation & Centered Title
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        CupertinoIcons.back,
                        size: 22.sp,
                        color: AppColors.primaryTextColor,
                      ),
                      splashRadius: 22.r,
                    ),
                  ),
                  Text(
                    'Ride Details',
                    style: AppTextStyle.text20Semibold.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                ],
              ),

              18.verticalSpace,

              // Interactive Google Map Card with Real Road Directions
              _RideRouteMapCard(ride: ride),

              16.verticalSpace,

              // Driver Card with Real-time Online Status Stream
              StreamBuilder<bool>(
                stream: AuthService.instance.streamUserOnlineStatus(ride.driverId),
                initialData: ride.isDriverOnline,
                builder: (context, snapshot) {
                  final bool isDriverOnline = snapshot.data ?? true;

                  return Column(
                    children: [
                      _DetailCard(
                        icon: isDriverOnline
                            ? CupertinoIcons.shield_lefthalf_fill
                            : CupertinoIcons.exclamationmark_shield_fill,
                        iconColor: isDriverOnline
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFD97706),
                        iconBg: isDriverOnline
                            ? const Color(0xFFEFF6FF)
                            : const Color(0xFFFEF3C7),
                        title: '$driverDisplayName • Verified Driver',
                        subtitle:
                            '$vehicleModel • $vehiclePlate\nTrust Rating ${(ride.rating > 0 ? ride.rating : 5.0).toStringAsFixed(1)} ★',
                        trailingBadge: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDriverOnline
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: isDriverOnline
                                  ? const Color(0xFF86EFAC)
                                  : const Color(0xFFFECACA),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDriverOnline
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                              5.horizontalSpace,
                              Text(
                                isDriverOnline ? 'Online' : 'Offline',
                                style: AppTextStyle.text10Medium.copyWith(
                                  color: isDriverOnline
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFFB91C1C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Driver Offline Notice
                      if (!isDriverOnline) ...[
                        10.verticalSpace,
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: const Color(0xFFFDE68A),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                CupertinoIcons.info_circle_fill,
                                color: const Color(0xFFD97706),
                                size: 16.sp,
                              ),
                              10.horizontalSpace,
                              Expanded(
                                child: Text(
                                  'Driver is currently offline. You can still send a request, but it might take some extra time for $driverDisplayName to accept.',
                                  style: AppTextStyle.text12Regular.copyWith(
                                    color: const Color(0xFF92400E),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),

              12.verticalSpace,

              // Scheduled Departure / Ride Start Time Card
              _DetailCard(
                icon: CupertinoIcons.clock,
                iconColor: AppColors.primaryColor,
                iconBg: const Color(0xFFEFF6FF),
                title: 'Ride Start / Departure Time',
                subtitle: formattedDeparture,
              ),

              12.verticalSpace,

              // Your Request Card
              _DetailCard(
                icon: CupertinoIcons.car_detailed,
                iconColor: AppColors.primaryColor,
                iconBg: const Color(0xFFEFF6FF),
                title: 'Your Request',
                subtitle: controller.seatsNote.value.trim().isNotEmpty
                    ? '${controller.seatsNote.value.trim()}\nSeats Needed: $seatsNeeded • Total: ${Utils.formatPrice(totalPrice)}'
                    : 'Seats Needed: $seatsNeeded • Total: ${Utils.formatPrice(totalPrice)}',
              ),

              12.verticalSpace,

              // Pickup Location Card
              _DetailCard(
                icon: CupertinoIcons.location,
                iconColor: AppColors.primaryColor,
                iconBg: const Color(0xFFEFF6FF),
                title: 'Pickup Location',
                subtitle: passengerPickup,
              ),

              12.verticalSpace,

              // Drop-off Destination Card
              _DetailCard(
                icon: CupertinoIcons.arrow_branch,
                iconColor: AppColors.primaryColor,
                iconBg: const Color(0xFFEFF6FF),
                title: 'Drop-off Destination',
                subtitle: passengerDrop,
              ),

              16.verticalSpace,

              // Cost & Detour Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.money_dollar_circle,
                            color: AppColors.primaryColor,
                            size: 18.sp,
                          ),
                          10.horizontalSpace,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cost Each',
                                style: AppTextStyle.text10Medium.copyWith(
                                  color: AppColors.secondaryTextColor,
                                ),
                              ),
                              2.verticalSpace,
                              Text(
                                Utils.formatPrice(ride.pricePerSeat),
                                style: AppTextStyle.text16Semibold.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  12.horizontalSpace,

                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.clock,
                            color: AppColors.primaryColor,
                            size: 18.sp,
                          ),
                          10.horizontalSpace,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detour',
                                style: AppTextStyle.text10Medium.copyWith(
                                  color: AppColors.secondaryTextColor,
                                ),
                              ),
                              2.verticalSpace,
                              Text(
                                '${ride.detourMinutes} min',
                                style: AppTextStyle.text16Semibold.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              20.verticalSpace,

              // Dynamic Request Button State: Disabled if already requested/pending
              Obx(() {
                final currentUid = AuthService.instance.currentUser?.uid ?? '';
                final bool isMyOwnRide = currentUid.isNotEmpty &&
                    ride.driverId.isNotEmpty &&
                    ride.driverId == currentUid;

                // Always observe reactive lists first so GetX tracks dependencies
                final bool isPending = controller.pendingRequests
                    .any((p) => p.ride.id.isNotEmpty && p.ride.id == ride.id);
                final bool isConfirmed = controller.myBookings
                    .any((b) => b.ride.id.isNotEmpty && b.ride.id == ride.id);

                if (isMyOwnRide) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 14.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFF64748B),
                              size: 20,
                            ),
                            8.horizontalSpace,
                            Text(
                              'This is Your Published Ride',
                              style: AppTextStyle.text14Semibold.copyWith(
                                color: const Color(0xFF334155),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        6.verticalSpace,
                        Text(
                          "You can't request a ride on your own published trip.",
                          style: AppTextStyle.text12Regular.copyWith(
                            color: AppColors.secondaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (isPending) {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                            8.horizontalSpace,
                            Text(
                              'Request Pending Approval',
                              style: AppTextStyle.text16Semibold.copyWith(
                                color: const Color(0xFFB45309),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      8.verticalSpace,
                      Text(
                        'You have already requested this ride. Waiting for driver approval.',
                        style: AppTextStyle.text12Regular.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }

                if (isConfirmed) {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF16A34A),
                              size: 20,
                            ),
                            8.horizontalSpace,
                            Text(
                              'Ride Already Confirmed',
                              style: AppTextStyle.text16Semibold.copyWith(
                                color: const Color(0xFF15803D),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      10.verticalSpace,
                      OutlinedButton.icon(
                        onPressed: () {
                          controller.currentSelectedRide.value = ride;
                          Get.toNamed(AppRoutes.liveTripTracking);
                        },
                        icon: const Icon(
                          CupertinoIcons.location_fill,
                          size: 16,
                          color: AppColors.primaryColor,
                        ),
                        label: Text(
                          'Track Live Trip on Map',
                          style: AppTextStyle.text14Semibold.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 44.h),
                          side: const BorderSide(color: AppColors.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return GestureDetector(
                  onTap: () => controller.requestToJoinRide(ride, seats: seatsNeeded),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        8.horizontalSpace,
                        Text(
                          'Request to Join',
                          style: AppTextStyle.text16Semibold.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              24.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final Widget? trailingBadge;

  const _DetailCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.trailingBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyle.text14Semibold.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ?trailingBadge,
                  ],
                ),
                3.verticalSpace,
                Text(
                  subtitle,
                  style: AppTextStyle.text12Regular.copyWith(
                    color: AppColors.secondaryTextColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RideRouteMapCard extends StatefulWidget {
  final RideModel ride;

  const _RideRouteMapCard({required this.ride});

  @override
  State<_RideRouteMapCard> createState() => _RideRouteMapCardState();
}

class _RideRouteMapCardState extends State<_RideRouteMapCard> {
  GoogleMapController? _mapController;
  List<LatLng> _routePoints = [];
  LatLng? _pickup;
  LatLng? _dropoff;
  bool _isLoadingRoute = true;
  bool _hasValidCoordinates = false;
  BitmapDescriptor? _pickupPersonMarker;
  BitmapDescriptor? _dropPinMarker;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
    _loadRealRoute();
  }

  bool _isValidCoordinate(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (lat.isNaN || lng.isNaN || lat.isInfinite || lng.isInfinite) return false;
    if (lat == 0.0 && lng == 0.0) return false;
    // World bounds
    if (lat < -90.0 || lat > 90.0 || lng < -180.0 || lng > 180.0) {
      return false;
    }
    return true;
  }

  Future<void> _loadCustomMarkers() async {
    try {
      final person = await MapMarkerHelper.getPersonMarker();
      final pin = await MapMarkerHelper.getDropPinMarker();
      if (mounted) {
        setState(() {
          _pickupPersonMarker = person;
          _dropPinMarker = pin;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadRealRoute() async {
    try {
      double pLat = widget.ride.searchedPickupLat != 0.0
          ? widget.ride.searchedPickupLat
          : widget.ride.originLat;
      double pLng = widget.ride.searchedPickupLng != 0.0
          ? widget.ride.searchedPickupLng
          : widget.ride.originLng;
      double dLat = widget.ride.searchedDropLat != 0.0
          ? widget.ride.searchedDropLat
          : widget.ride.destinationLat;
      double dLng = widget.ride.searchedDropLng != 0.0
          ? widget.ride.searchedDropLng
          : widget.ride.destinationLng;

      // If coordinates are missing or invalid, attempt real-time geocoding
      if (!_isValidCoordinate(pLat, pLng) && widget.ride.origin.trim().isNotEmpty) {
        final pGeo = await GooglePlacesService.instance.getCoordinatesForAddress(
          widget.ride.origin,
        );
        if (pGeo != null && _isValidCoordinate(pGeo.latitude, pGeo.longitude)) {
          pLat = pGeo.latitude;
          pLng = pGeo.longitude;
        }
      }

      if (!_isValidCoordinate(dLat, dLng) && widget.ride.destination.trim().isNotEmpty) {
        final dGeo = await GooglePlacesService.instance.getCoordinatesForAddress(
          widget.ride.destination,
        );
        if (dGeo != null && _isValidCoordinate(dGeo.latitude, dGeo.longitude)) {
          dLat = dGeo.latitude;
          dLng = dGeo.longitude;
        }
      }

      // If either pickup or dropoff does not have valid coordinates, do NOT use default fake coordinates
      if (!_isValidCoordinate(pLat, pLng) || !_isValidCoordinate(dLat, dLng)) {
        if (!mounted) return;
        setState(() {
          _pickup = null;
          _dropoff = null;
          _hasValidCoordinates = false;
          _isLoadingRoute = false;
          _routePoints = [];
        });
        return;
      }

      final pickup = LatLng(pLat, pLng);
      final dropoff = LatLng(dLat, dLng);

      // Fetch driving directions
      final points = await GooglePlacesService.instance.getDirectionsRoute(
        pickup,
        dropoff,
      );
      if (!mounted) return;

      setState(() {
        _pickup = pickup;
        _dropoff = dropoff;
        _hasValidCoordinates = true;
        _routePoints = points.isNotEmpty ? points : [pickup, dropoff];
        _isLoadingRoute = false;
      });

      _fitBounds();
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
          _hasValidCoordinates = false;
        });
      }
    }
  }

  void _fitBounds() {
    final pickup = _pickup;
    final dropoff = _dropoff;
    if (_mapController == null || pickup == null || dropoff == null) return;
    try {
      final allPoints =
          _routePoints.isNotEmpty ? _routePoints : [pickup, dropoff];
      if (allPoints.isEmpty) return;

      double minLat = allPoints.first.latitude;
      double maxLat = allPoints.first.latitude;
      double minLng = allPoints.first.longitude;
      double maxLng = allPoints.first.longitude;

      for (final p in allPoints) {
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

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 36),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRoute) {
      return Container(
        height: 195.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 32.w,
                height: 32.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 3.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                ),
              ),
              12.verticalSpace,
              Text(
                'Calculating Road Route...',
                style: AppTextStyle.text12Regular.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final pickup = _pickup;
    final dropoff = _dropoff;

    // Clean container when coordinates or route data are unavailable
    if (!_hasValidCoordinates || pickup == null || dropoff == null) {
      return Container(
        height: 195.h,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.location_slash,
                color: AppColors.primaryColor,
                size: 24.sp,
              ),
            ),
            10.verticalSpace,
            Text(
              'Route Map Unavailable',
              style: AppTextStyle.text14Semibold.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            4.verticalSpace,
            Text(
              'GPS coordinates are not available for this route.',
              textAlign: TextAlign.center,
              style: AppTextStyle.text12Regular.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            12.verticalSpace,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  6.horizontalSpace,
                  Flexible(
                    child: Text(
                      widget.ride.origin.isNotEmpty
                          ? widget.ride.origin
                          : 'Origin',
                      style: AppTextStyle.text10Medium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  8.horizontalSpace,
                  Icon(
                    CupertinoIcons.arrow_right,
                    size: 11.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  8.horizontalSpace,
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                  ),
                  6.horizontalSpace,
                  Flexible(
                    child: Text(
                      widget.ride.destination.isNotEmpty
                          ? widget.ride.destination
                          : 'Destination',
                      style: AppTextStyle.text10Medium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final LatLng midPoint = LatLng(
      (pickup.latitude + dropoff.latitude) / 2,
      (pickup.longitude + dropoff.longitude) / 2,
    );

    final List<LatLng> activePoints = _routePoints.isNotEmpty
        ? _routePoints
        : [pickup, midPoint, dropoff];

    return Container(
      height: 195.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: midPoint,
                zoom: 10.5,
              ),
              onMapCreated: (map) {
                _mapController = map;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _fitBounds();
                });
              },
              markers: {
                Marker(
                  markerId: const MarkerId('pickup'),
                  position: pickup,
                  infoWindow: InfoWindow(
                    title: widget.ride.origin.isNotEmpty
                        ? 'Pickup: ${widget.ride.origin}'
                        : 'Pickup',
                  ),
                  icon: _pickupPersonMarker ??
                      BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                ),
                Marker(
                  markerId: const MarkerId('dropoff'),
                  position: dropoff,
                  infoWindow: InfoWindow(
                    title: widget.ride.destination.isNotEmpty
                        ? 'Drop-off: ${widget.ride.destination}'
                        : 'Drop-off',
                  ),
                  icon: _dropPinMarker ??
                      BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                ),
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route_preview'),
                  points: activePoints,
                  color: const Color(0xFF2563EB),
                  width: 5,
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              indoorViewEnabled: false,
            ),

            // Overlay Badge to clearly denote Live Route
            Positioned(
              top: 12.h,
              left: 12.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 5.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    6.horizontalSpace,
                    Text(
                      'Live Route Preview',
                      style: AppTextStyle.text10Medium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

