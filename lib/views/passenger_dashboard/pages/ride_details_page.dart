import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/map_marker_helper.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/services/google_places_service.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/passenger_dashboard/passenger_dashboard_controller.dart';

class RideDetailsPage extends GetView<PassengerDashboardController> {
  const RideDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ride = controller.currentSelectedRide.value ?? controller.availableRides.first;
    final int seatsNeeded = controller.requestedSeats.value;
    final double totalPrice = ride.pricePerSeat * seatsNeeded;

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
                        title: '${ride.driverName} • Verified Driver',
                        subtitle:
                            '${ride.carModel} • ${ride.carPlate}\nTrust Rating ${ride.rating.toStringAsFixed(2)} ★',
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
                                  'Driver is currently offline. You can still send a request, but it might take some extra time for ${ride.driverName} to accept.',
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

              // Your Request Card
              _DetailCard(
                icon: CupertinoIcons.car_detailed,
                iconColor: AppColors.primaryColor,
                iconBg: const Color(0xFFEFF6FF),
                title: 'Your Request',
                subtitle:
                    '${controller.seatsNote.value}\nSeats Needed: $seatsNeeded • Total: \$${totalPrice.toStringAsFixed(0)}',
              ),

              12.verticalSpace,

              // Pickup Suggestion Card
              _DetailCard(
                icon: CupertinoIcons.location,
                iconColor: AppColors.primaryColor,
                iconBg: const Color(0xFFEFF6FF),
                title: 'Pickup Suggestion',
                subtitle: ride.pickupSuggestion,
              ),

              12.verticalSpace,

              // Drop-off Plan Card
              _DetailCard(
                icon: CupertinoIcons.arrow_branch,
                iconColor: AppColors.primaryColor,
                iconBg: const Color(0xFFEFF6FF),
                title: 'Drop-off Plan',
                subtitle: ride.dropOffPlan,
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
                                '\$${ride.pricePerSeat.toStringAsFixed(0)}',
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
                final bool isPending = controller.pendingRequests
                    .any((p) => p.ride.id == ride.id);
                final bool isConfirmed = controller.myBookings
                    .any((b) => b.ride.id == ride.id);

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
                  onTap: () => controller.requestToJoinRide(ride),
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
  late LatLng _pickup;
  late LatLng _dropoff;
  bool _isLoadingRoute = true;
  BitmapDescriptor? _pickupPersonMarker;
  BitmapDescriptor? _dropPinMarker;

  @override
  void initState() {
    super.initState();
    _pickup = LatLng(widget.ride.originLat, widget.ride.originLng);
    _dropoff = LatLng(widget.ride.destinationLat, widget.ride.destinationLng);
    _loadCustomMarkers();
    _loadRealRoute();
  }

  Future<void> _loadCustomMarkers() async {
    final person = await MapMarkerHelper.getPersonMarker();
    final pin = await MapMarkerHelper.getDropPinMarker();
    if (mounted) {
      setState(() {
        _pickupPersonMarker = person;
        _dropPinMarker = pin;
      });
    }
  }

  Future<void> _loadRealRoute() async {
    // If coordinates are default (Perth) or 0,0, geocode real address
    if ((_pickup.latitude == 0.0 && _pickup.longitude == 0.0) ||
        (_pickup.latitude == -31.8156 && _pickup.longitude == 115.8452)) {
      final pGeo = await GooglePlacesService.instance.getCoordinatesForAddress(
        widget.ride.origin,
      );
      if (pGeo != null) {
        _pickup = LatLng(pGeo.latitude, pGeo.longitude);
      }
    }
    if ((_dropoff.latitude == 0.0 && _dropoff.longitude == 0.0) ||
        (_dropoff.latitude == -32.0044 && _dropoff.longitude == 115.8947)) {
      final dGeo = await GooglePlacesService.instance.getCoordinatesForAddress(
        widget.ride.destination,
      );
      if (dGeo != null) {
        _dropoff = LatLng(dGeo.latitude, dGeo.longitude);
      }
    }

    // Fetch driving directions
    final points = await GooglePlacesService.instance.getDirectionsRoute(
      _pickup,
      _dropoff,
    );
    if (!mounted) return;

    setState(() {
      _routePoints = points;
      _isLoadingRoute = false;
    });

    _fitBounds();
  }

  void _fitBounds() {
    if (_mapController == null) return;
    final allPoints =
        _routePoints.isNotEmpty ? _routePoints : [_pickup, _dropoff];
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

    if (minLat == maxLat && minLng == maxLng) {
      minLat -= 0.01;
      maxLat += 0.01;
      minLng -= 0.01;
      maxLng += 0.01;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 36),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRoute || _routePoints.isEmpty) {
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

    final LatLng midPoint = LatLng(
      (_pickup.latitude + _dropoff.latitude) / 2,
      (_pickup.longitude + _dropoff.longitude) / 2,
    );

    final List<LatLng> activePoints = _routePoints.isNotEmpty
        ? _routePoints
        : [_pickup, midPoint, _dropoff];

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
                _fitBounds();
              },
              markers: {
                Marker(
                  markerId: const MarkerId('pickup'),
                  position: _pickup,
                  infoWindow: InfoWindow(title: 'Pickup: ${widget.ride.origin}'),
                  icon: _pickupPersonMarker ??
                      BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                ),
                Marker(
                  markerId: const MarkerId('dropoff'),
                  position: _dropoff,
                  infoWindow: InfoWindow(
                    title: 'Drop-off: ${widget.ride.destination}',
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

