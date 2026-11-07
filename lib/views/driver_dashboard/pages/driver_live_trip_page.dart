import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridelink/core/constants/app_colors.dart';
import 'package:ridelink/core/utils/app_snack_bar.dart';
import 'package:ridelink/core/utils/map_marker_helper.dart';
import 'package:ridelink/core/utils/route_matching_helper.dart';
import 'package:ridelink/core/utils/utils.dart';
import 'package:ridelink/data/services/auth_service.dart';
import 'package:ridelink/data/models/firestore/trip_model.dart';
import 'package:ridelink/data/services/chat_service.dart';
import 'package:ridelink/data/services/device_location_service.dart';
import 'package:ridelink/data/services/google_places_service.dart';
import 'package:ridelink/data/services/trip_service.dart';
import 'package:ridelink/routes/routes_name.dart';
import 'package:ridelink/theme/app_text_style.dart';
import 'package:ridelink/views/driver_dashboard/driver_dashboard_controller.dart';

class DriverLiveTripPage extends StatefulWidget {
  const DriverLiveTripPage({super.key});

  @override
  State<DriverLiveTripPage> createState() => _DriverLiveTripPageState();
}

class _DriverLiveTripPageState extends State<DriverLiveTripPage> {
  final DriverTripsController tripsController =
      Get.find<DriverTripsController>();
  final DriverProfileController profileController =
      Get.find<DriverProfileController>();

  GoogleMapController? _mapController;
  StreamSubscription? _deviceLocationSubscription;

  bool _isLoading = true;
  LatLng? _pickup;
  LatLng? _dropoff;
  List<LatLng> _fullRoute = []; // Pickup -> Dropoff main trip route
  List<LatLng> _driverToPickupRoute = []; // Driver Live Location -> Target stop route leg

  LatLng? _currentDriverLocation;
  double _driverHeading = 0.0;
  double _driverSpeedKmH = 0.0;

  BitmapDescriptor? _pickupPersonMarker;
  BitmapDescriptor? _driverCarMarker;
  BitmapDescriptor? _dropPinMarker;

  bool _isCardExpanded = false;
  String? _manualTargetPassengerId;
  String? _manualTargetType; // 'pickup' | 'dropoff'

  StreamSubscription<List<TripChatMessageModel>>? _chatMessagesSubscription;
  TripChatMessageModel? _activeInAppChatBanner;
  Timer? _chatBannerTimer;
  String? _lastReceivedChatMsgId;
  bool _isCompletingOrFinishing = false;
  final RxBool _isCompletingEntireTrip = false.obs;
  final RxBool _isNotifyingArrival = false.obs;

  @override
  void initState() {
    super.initState();
    final trip = (Get.arguments is DriverTripModel ? Get.arguments as DriverTripModel : null) ??
        tripsController.liveTrip.value ??
        tripsController.selectedTripForRequests.value ??
        (tripsController.myTrips.isNotEmpty ? tripsController.myTrips.first : null);

    if (trip != null && trip.id.isNotEmpty) {
      _startChatListener(trip);
    }

    // Warm up driver live location immediately from cached position
    LatLng? quickLoc = DeviceLocationService.instance.cachedPosition;
    if (quickLoc == null && Get.isRegistered<DriverDashboardController>()) {
      quickLoc = Get.find<DriverDashboardController>().currentDriverLocation.value;
    }
    if (Get.isRegistered<DriverDashboardController>()) {
      _driverHeading = Get.find<DriverDashboardController>().driverCurrentHeading.value;
    } else {
      _driverHeading = DeviceLocationService.instance.cachedHeading;
    }
    if (quickLoc != null) {
      _currentDriverLocation = quickLoc;
      if (trip != null) {
        trip.currentDriverLat.value = quickLoc.latitude;
        trip.currentDriverLng.value = quickLoc.longitude;
      }
    }

    // Immediately request fresh GPS hardware position from phone
    DeviceLocationService.instance.getCurrentDeviceLocation(forceFresh: true).then((freshLoc) {
      if (freshLoc != null && mounted) {
        setState(() {
          _currentDriverLocation = freshLoc;
          if (trip != null) {
            trip.currentDriverLat.value = freshLoc.latitude;
            trip.currentDriverLng.value = freshLoc.longitude;
            _updateTargetRoute(trip);
          }
        });
        if (trip != null && trip.id.isNotEmpty) {
          TripService.instance.updateDriverLocation(
            trip.id,
            freshLoc.latitude,
            freshLoc.longitude,
            heading: _driverHeading,
            force: true,
          );
        }
      }
    });

    _loadCustomMarkers();
    _startDeviceLocationTracking(trip);
    _initializeRealRoute(trip);
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

  Future<void> _initializeRealRoute(DriverTripModel? trip) async {
    if (trip == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      LatLng? pickupLatLng;
      LatLng? dropoffLatLng;

      // Check if coordinates are valid, otherwise geocode from address strings
      final bool isOriginValid = GooglePlacesService.instance
          .isValidCoordinate(LatLng(trip.fromLat, trip.fromLng));
      final bool isDestValid = GooglePlacesService.instance
          .isValidCoordinate(LatLng(trip.toLat, trip.toLng));

      if (isOriginValid) {
        pickupLatLng = LatLng(trip.fromLat, trip.fromLng);
      } else if (trip.from.isNotEmpty) {
        final geo = await GooglePlacesService.instance
            .getCoordinatesForAddress(trip.from)
            .timeout(const Duration(seconds: 3), onTimeout: () => null);
        if (geo != null &&
            GooglePlacesService.instance
                .isValidCoordinate(LatLng(geo.latitude, geo.longitude))) {
          pickupLatLng = LatLng(geo.latitude, geo.longitude);
        }
      }

      if (isDestValid) {
        dropoffLatLng = LatLng(trip.toLat, trip.toLng);
      } else if (trip.to.isNotEmpty) {
        final geo = await GooglePlacesService.instance
            .getCoordinatesForAddress(trip.to)
            .timeout(const Duration(seconds: 3), onTimeout: () => null);
        if (geo != null &&
            GooglePlacesService.instance
                .isValidCoordinate(LatLng(geo.latitude, geo.longitude))) {
          dropoffLatLng = LatLng(geo.latitude, geo.longitude);
        }
      }

      // If coordinates cannot be resolved, do not fallback to fake Perth defaults
      if (pickupLatLng == null || dropoffLatLng == null) {
        if (mounted) {
          setState(() {
            _pickup = null;
            _dropoff = null;
            _isLoading = false;
          });
        }
        return;
      }

      final LatLng validPickup = pickupLatLng;
      final LatLng validDropoff = dropoffLatLng;

      // Resolve driver live position without blocking
      LatLng? liveVehicleLoc = _currentDriverLocation;
      liveVehicleLoc ??= DeviceLocationService.instance.cachedPosition;
      if (liveVehicleLoc == null && Get.isRegistered<DriverDashboardController>()) {
        liveVehicleLoc = Get.find<DriverDashboardController>().currentDriverLocation.value;
      }
      if (liveVehicleLoc == null &&
          trip.currentDriverLat.value != 0.0 &&
          trip.currentDriverLng.value != 0.0) {
        liveVehicleLoc = LatLng(trip.currentDriverLat.value, trip.currentDriverLng.value);
      }

      if (liveVehicleLoc != null) {
        _currentDriverLocation = liveVehicleLoc;
      }

      final vehicleLocForRoute = liveVehicleLoc;

      // Render the map and routes immediately (<50ms)
      if (mounted) {
        setState(() {
          _pickup = validPickup;
          _dropoff = validDropoff;
          _fullRoute = [validPickup, validDropoff];
          _driverToPickupRoute = (vehicleLocForRoute != null && vehicleLocForRoute != validPickup)
              ? [vehicleLocForRoute, validPickup]
              : [];
          _isLoading = false;
        });
      }

      // Fetch refined road polylines asynchronously in background
      if (vehicleLocForRoute != null) {
        final double distToPickup = ((vehicleLocForRoute.latitude - validPickup.latitude).abs() +
            (vehicleLocForRoute.longitude - validPickup.longitude).abs());
        if (distToPickup > 0.0005) {
          GooglePlacesService.instance
              .getDirectionsRoute(vehicleLocForRoute, validPickup)
              .timeout(const Duration(seconds: 3), onTimeout: () => [vehicleLocForRoute, validPickup])
              .then((points) {
            if (!mounted) return;
            if (points.isNotEmpty) {
              setState(() {
                _driverToPickupRoute = points;
              });
            }
          }).catchError((_) {});
        }
      }

      GooglePlacesService.instance
          .getDirectionsRoute(validPickup, validDropoff)
          .timeout(const Duration(seconds: 3), onTimeout: () => [validPickup, validDropoff])
          .then((points) {
        if (!mounted) return;
        if (points.isNotEmpty) {
          setState(() {
            _fullRoute = points;
          });
        }
      });

      // Sync location to Firestore in background
      if (trip.id.isNotEmpty && liveVehicleLoc != null) {
        trip.currentDriverLat.value = liveVehicleLoc.latitude;
        trip.currentDriverLng.value = liveVehicleLoc.longitude;
        TripService.instance.updateDriverLocation(
          trip.id,
          liveVehicleLoc.latitude,
          liveVehicleLoc.longitude,
          force: true,
        );
      }

      _fitBounds();
    } catch (e) {
      debugPrint('[DriverLiveTripPage] Route init error: $e');
    } finally {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startDeviceLocationTracking(DriverTripModel? trip) {
    _deviceLocationSubscription?.cancel();

    // Prefer listening to DriverDashboardController if available (zero hardware contention)
    if (Get.isRegistered<DriverDashboardController>()) {
      final dashCtrl = Get.find<DriverDashboardController>();
      _deviceLocationSubscription = dashCtrl.currentDriverLocation.listen((devicePos) {
        if (!mounted || devicePos == null) return;
        _handleLivePositionUpdate(
          devicePos,
          trip,
          heading: dashCtrl.driverCurrentHeading.value,
          speed: dashCtrl.driverCurrentSpeed.value,
        );
      });
    } else {
      _deviceLocationSubscription = DeviceLocationService.instance
          .streamDevicePosition(distanceFilterMeters: 0)
          .listen((pos) {
        if (!mounted) return;
        final double speedKmH = pos.speed > 0.0 ? (pos.speed * 3.6) : 0.0;
        _handleLivePositionUpdate(
          LatLng(pos.latitude, pos.longitude),
          trip,
          heading: pos.heading,
          speed: speedKmH,
        );
      });
    }
  }

  void _handleLivePositionUpdate(
    LatLng devicePos,
    DriverTripModel? trip, {
    double? heading,
    double? speed,
  }) {
    setState(() {
      _currentDriverLocation = devicePos;
      if (heading != null && heading >= 0.0) {
        _driverHeading = heading;
      }
      if (speed != null && speed >= 0.0 && !speed.isNaN && !speed.isInfinite) {
        _driverSpeedKmH = speed;
      }
      if (trip != null) {
        final target = _getActiveTargetStop(trip);
        final double dist = ((devicePos.latitude - target.location.latitude).abs() +
            (devicePos.longitude - target.location.longitude).abs());
        if (dist > 0.0005) {
          if (_driverToPickupRoute.isNotEmpty) {
            _driverToPickupRoute[0] = devicePos;
          } else {
            _driverToPickupRoute = [devicePos, target.location];
          }
        } else {
          _driverToPickupRoute = [];
        }
      } else if (_pickup != null) {
        final double dist = ((devicePos.latitude - _pickup!.latitude).abs() +
            (devicePos.longitude - _pickup!.longitude).abs());
        if (dist > 0.0005) {
          if (_driverToPickupRoute.isNotEmpty) {
            _driverToPickupRoute[0] = devicePos;
          } else {
            _driverToPickupRoute = [devicePos, _pickup!];
          }
        } else {
          _driverToPickupRoute = [];
        }
      }
    });

    if (trip != null && trip.id.isNotEmpty) {
      trip.currentDriverLat.value = devicePos.latitude;
      trip.currentDriverLng.value = devicePos.longitude;
      TripService.instance.updateDriverLocation(
        trip.id,
        devicePos.latitude,
        devicePos.longitude,
        heading: heading ?? _driverHeading,
        speed: speed ?? _driverSpeedKmH,
      );
    }
  }

  _ActiveTargetStop _getActiveTargetStop(DriverTripModel trip) {
    final driverPos = _currentDriverLocation ?? _pickup ?? LatLng(trip.fromLat, trip.fromLng);
    final fallbackDrop = _dropoff ?? LatLng(trip.toLat, trip.toLng);

    // 1. Manual Override Stop if selected by driver
    if (_manualTargetPassengerId != null) {
      final manualP = trip.acceptedPassengers.firstWhereOrNull(
        (p) => p.id == _manualTargetPassengerId,
      );
      if (manualP != null) {
        if (_manualTargetType == 'pickup' && manualP.isWaitingPickup) {
          final pLoc = LatLng(
            manualP.pickupLat != 0.0 ? manualP.pickupLat : (_pickup?.latitude ?? trip.fromLat),
            manualP.pickupLng != 0.0 ? manualP.pickupLng : (_pickup?.longitude ?? trip.fromLng),
          );
          return _ActiveTargetStop(
            passenger: manualP,
            type: 'pickup',
            title: 'Pick up ${manualP.passengerName}',
            address: manualP.from.isNotEmpty ? manualP.from : trip.from,
            location: pLoc,
            fare: manualP.fare,
            seats: manualP.seats,
          );
        } else if (_manualTargetType == 'dropoff' && manualP.isOnboard) {
          final dLoc = LatLng(
            manualP.dropLat != 0.0 ? manualP.dropLat : fallbackDrop.latitude,
            manualP.dropLng != 0.0 ? manualP.dropLng : fallbackDrop.longitude,
          );
          return _ActiveTargetStop(
            passenger: manualP,
            type: 'dropoff',
            title: 'Drop off ${manualP.passengerName}',
            address: manualP.to.isNotEmpty ? manualP.to : trip.to,
            location: dLoc,
            fare: manualP.fare,
            seats: manualP.seats,
          );
        }
      }
    }

    // 2. Automated Optimal Sequencing
    // A) If any passenger is waiting to be picked up: target the nearest pickup point
    final waitingPickups = trip.acceptedPassengers.where((p) => p.isWaitingPickup).toList();
    if (waitingPickups.isNotEmpty) {
      waitingPickups.sort((a, b) {
        final locA = LatLng(
          a.pickupLat != 0.0 ? a.pickupLat : (_pickup?.latitude ?? trip.fromLat),
          a.pickupLng != 0.0 ? a.pickupLng : (_pickup?.longitude ?? trip.fromLng),
        );
        final locB = LatLng(
          b.pickupLat != 0.0 ? b.pickupLat : (_pickup?.latitude ?? trip.fromLat),
          b.pickupLng != 0.0 ? b.pickupLng : (_pickup?.longitude ?? trip.fromLng),
        );
        final distA = RouteMatchingHelper.distanceKm(driverPos, locA);
        final distB = RouteMatchingHelper.distanceKm(driverPos, locB);
        return distA.compareTo(distB);
      });

      final nextPickup = waitingPickups.first;
      final targetLoc = LatLng(
        nextPickup.pickupLat != 0.0 ? nextPickup.pickupLat : (_pickup?.latitude ?? trip.fromLat),
        nextPickup.pickupLng != 0.0 ? nextPickup.pickupLng : (_pickup?.longitude ?? trip.fromLng),
      );

      return _ActiveTargetStop(
        passenger: nextPickup,
        type: 'pickup',
        title: 'Pick up ${nextPickup.passengerName}',
        address: nextPickup.from.isNotEmpty ? nextPickup.from : trip.from,
        location: targetLoc,
        fare: nextPickup.fare,
        seats: nextPickup.seats,
      );
    }

    // B) If all waiting passengers have boarded: target the nearest onboard passenger's drop-off
    final onboardPassengers = trip.acceptedPassengers.where((p) => p.isOnboard).toList();
    if (onboardPassengers.isNotEmpty) {
      onboardPassengers.sort((a, b) {
        final locA = LatLng(
          a.dropLat != 0.0 ? a.dropLat : fallbackDrop.latitude,
          a.dropLng != 0.0 ? a.dropLng : fallbackDrop.longitude,
        );
        final locB = LatLng(
          b.dropLat != 0.0 ? b.dropLat : fallbackDrop.latitude,
          b.dropLng != 0.0 ? b.dropLng : fallbackDrop.longitude,
        );
        final distA = RouteMatchingHelper.distanceKm(driverPos, locA);
        final distB = RouteMatchingHelper.distanceKm(driverPos, locB);
        return distA.compareTo(distB);
      });

      final nextDrop = onboardPassengers.first;
      final targetLoc = LatLng(
        nextDrop.dropLat != 0.0 ? nextDrop.dropLat : fallbackDrop.latitude,
        nextDrop.dropLng != 0.0 ? nextDrop.dropLng : fallbackDrop.longitude,
      );

      return _ActiveTargetStop(
        passenger: nextDrop,
        type: 'dropoff',
        title: 'Drop off ${nextDrop.passengerName}',
        address: nextDrop.to.isNotEmpty ? nextDrop.to : trip.to,
        location: targetLoc,
        fare: nextDrop.fare,
        seats: nextDrop.seats,
      );
    }

    // C) If all accepted passengers are dropped off (or solo trip): target is driver's final destination
    return _ActiveTargetStop(
      type: 'destination',
      title: 'Drive to Trip Destination',
      address: trip.to,
      location: fallbackDrop,
      fare: 0.0,
      seats: 0,
    );
  }

  int _calculateEtaMinutes(_ActiveTargetStop activeTarget) {
    final driverPos = _currentDriverLocation ?? _pickup;
    if (driverPos == null) return 5;
    final distMeters = Geolocator.distanceBetween(
      driverPos.latitude,
      driverPos.longitude,
      activeTarget.location.latitude,
      activeTarget.location.longitude,
    );
    if (distMeters < 80) return 0;
    final minutes = (distMeters / 580).ceil();
    return minutes > 0 ? minutes : 1;
  }

  String _calculateDetourText(DriverTripModel trip, _ActiveTargetStop activeTarget) {
    if (activeTarget.passenger == null) return '';
    final p = activeTarget.passenger!;
    if (p.pickupLat == 0.0 || p.dropLat == 0.0 || trip.fromLat == 0.0 || trip.toLat == 0.0) {
      return '+2 mins detour';
    }
    final directDist = Geolocator.distanceBetween(
      trip.fromLat,
      trip.fromLng,
      trip.toLat,
      trip.toLng,
    );
    final detourDist = Geolocator.distanceBetween(
          trip.fromLat,
          trip.fromLng,
          p.pickupLat,
          p.pickupLng,
        ) +
        Geolocator.distanceBetween(
          p.pickupLat,
          p.pickupLng,
          p.dropLat,
          p.dropLng,
        ) +
        Geolocator.distanceBetween(
          p.dropLat,
          p.dropLng,
          trip.toLat,
          trip.toLng,
        );
    final extraMeters = (detourDist - directDist).clamp(0.0, 50000.0);
    final extraKm = extraMeters / 1000.0;

    // Use live speed if moving (> 15 km/h), otherwise fallback to safe 35 km/h (stops / red lights)
    double effectiveSpeed = 35.0;
    if (_driverSpeedKmH >= 15.0 && !_driverSpeedKmH.isNaN && !_driverSpeedKmH.isInfinite) {
      effectiveSpeed = _driverSpeedKmH.clamp(20.0, 100.0);
    }

    final extraMins = (extraKm / effectiveSpeed * 60).round() + 1;
    if (extraMins <= 1) return '+1 min detour (~${extraKm.toStringAsFixed(1)} km)';
    return '+$extraMins mins detour (~${extraKm.toStringAsFixed(1)} km)';
  }

  void _updateTargetRoute(DriverTripModel trip) {
    final target = _getActiveTargetStop(trip);
    final driverPos = _currentDriverLocation ?? _pickup;
    if (driverPos == null) return;

    final double dist = ((driverPos.latitude - target.location.latitude).abs() +
        (driverPos.longitude - target.location.longitude).abs());

    if (dist > 0.0005) {
      _driverToPickupRoute = [driverPos, target.location];
      GooglePlacesService.instance
          .getDirectionsRoute(driverPos, target.location)
          .timeout(const Duration(seconds: 3), onTimeout: () => [driverPos, target.location])
          .then((pts) {
        if (!mounted) return;
        if (pts.isNotEmpty) {
          setState(() {
            _driverToPickupRoute = pts;
          });
        }
      });
    } else {
      _driverToPickupRoute = [];
    }
  }

  Set<Marker> _buildMapMarkers(DriverTripModel trip, _ActiveTargetStop activeTarget) {
    final markers = <Marker>{};

    // 1. Driver's vehicle marker (Live)
    if (_currentDriverLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver_vehicle'),
          position: _currentDriverLocation!,
          zIndexInt: 10,
          anchor: const Offset(0.5, 0.5),
          rotation: _driverHeading,
          flat: true,
          infoWindow: InfoWindow(
            title: 'Your Vehicle (${profileController.vehicleModel.value})',
            snippet: 'Live Vehicle Location',
          ),
          icon: _driverCarMarker ??
              BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
        ),
      );
    }

    // 2. Active Target marker (highlighted)
    markers.add(
      Marker(
        markerId: const MarkerId('active_target_marker'),
        position: activeTarget.location,
        zIndexInt: 5,
        infoWindow: InfoWindow(
          title: activeTarget.title,
          snippet: activeTarget.address,
        ),
        icon: activeTarget.isPickup
            ? (_pickupPersonMarker ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen))
            : (_dropPinMarker ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)),
      ),
    );

    // 3. Markers for all accepted passengers
    for (int i = 0; i < trip.acceptedPassengers.length; i++) {
      final p = trip.acceptedPassengers[i];
      if (p.isWaitingPickup && p != activeTarget.passenger) {
        final pLoc = LatLng(
          p.pickupLat != 0.0 ? p.pickupLat : (_pickup?.latitude ?? trip.fromLat),
          p.pickupLng != 0.0 ? p.pickupLng : (_pickup?.longitude ?? trip.fromLng),
        );
        markers.add(
          Marker(
            markerId: MarkerId('passenger_pickup_${p.id}'),
            position: pLoc,
            zIndexInt: 3,
            infoWindow: InfoWindow(
              title: 'Pickup: ${p.passengerName}',
              snippet: p.from,
            ),
            icon: _pickupPersonMarker ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );
      } else if (p.isOnboard && p != activeTarget.passenger) {
        final dLoc = LatLng(
          p.dropLat != 0.0 ? p.dropLat : (_dropoff?.latitude ?? trip.toLat),
          p.dropLng != 0.0 ? p.dropLng : (_dropoff?.longitude ?? trip.toLng),
        );
        markers.add(
          Marker(
            markerId: MarkerId('passenger_dropoff_${p.id}'),
            position: dLoc,
            zIndexInt: 3,
            infoWindow: InfoWindow(
              title: 'Drop-off: ${p.passengerName}',
              snippet: p.to,
            ),
            icon: _dropPinMarker ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
    }

    // 4. Trip final destination marker
    if (_dropoff != null && !activeTarget.isDestination) {
      markers.add(
        Marker(
          markerId: const MarkerId('trip_final_destination'),
          position: _dropoff!,
          zIndexInt: 2,
          infoWindow: InfoWindow(title: 'Final Destination: ${trip.to}'),
          icon: _dropPinMarker ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
        ),
      );
    }

    return markers;
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

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 40),
      );
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
        CameraPosition(
          target: _currentDriverLocation!,
          zoom: 15.5,
          tilt: 35.0,
        ),
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

  @override
  void dispose() {
    _deviceLocationSubscription?.cancel();
    _chatMessagesSubscription?.cancel();
    _chatBannerTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _startChatListener(DriverTripModel trip) {
    final String driverUid = AuthService.instance.currentUser?.uid ?? '';
    _chatMessagesSubscription?.cancel();
    bool isInitialLoad = true;
    _chatMessagesSubscription = ChatService.instance
        .streamTripChatMessages(trip.id)
        .listen((messages) {
      if (!mounted || messages.isEmpty) return;
      if (isInitialLoad) {
        isInitialLoad = false;
        _lastReceivedChatMsgId = messages.last.id;
        return;
      }
      final latest = messages.last;
      if (latest.senderId != driverUid && latest.id != _lastReceivedChatMsgId) {
        _lastReceivedChatMsgId = latest.id;
        setState(() {
          _activeInAppChatBanner = latest;
        });
        _chatBannerTimer?.cancel();
        _chatBannerTimer = Timer(const Duration(seconds: 8), () {
          if (mounted) {
            setState(() => _activeInAppChatBanner = null);
          }
        });
      }
    });
  }

  void _finishAndReturnToDriverHome({String? snackbarMessage}) {
    if (_isCompletingOrFinishing) return;
    _isCompletingOrFinishing = true;

    AppSnackBar.clear();
    _chatMessagesSubscription?.cancel();
    _chatBannerTimer?.cancel();
    _deviceLocationSubscription?.cancel();

    if (Get.isRegistered<DriverTripsController>()) {
      final tc = Get.find<DriverTripsController>();
      tc.liveTrip.value = null;
      tc.livePassenger.value = null;
      tc.reloadDriverTrips();
    }
    if (Get.isRegistered<DriverHomeController>()) {
      Get.find<DriverHomeController>().reloadStats();
    }
    if (Get.isRegistered<DriverProfileController>()) {
      Get.find<DriverProfileController>().reloadProfile();
    }
    if (Get.isRegistered<DriverDashboardController>()) {
      Get.find<DriverDashboardController>().switchTab(0);
    }

    // Safely return to driver dashboard cleanly without stuck routes or modal conflicts
    Get.offAllNamed(AppRoutes.driverDashboard);

    if (snackbarMessage != null) {
      Future.delayed(const Duration(milliseconds: 350), () {
        AppSnackBar.success(message: snackbarMessage);
      });
    }
  }

  void _showConfirmPassengerBoardingSheet(
    DriverTripModel trip,
    PassengerRequestModel passenger,
  ) {
    final RxBool isSubmitting = false.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 12.h,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top drag handle pill
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
              16.verticalSpace,

              // Passenger Icon
              Container(
                width: 52.w,
                height: 52.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    CupertinoIcons.person_crop_circle_badge_checkmark,
                    color: Color(0xFF2563EB),
                    size: 28,
                  ),
                ),
              ),
              14.verticalSpace,

              Text(
                'Confirm Passenger Boarding',
                style: AppTextStyle.text18Bold.copyWith(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              6.verticalSpace,

              Text(
                'Has ${passenger.passengerName} met you and boarded your vehicle?',
                textAlign: TextAlign.center,
                style: AppTextStyle.text13Regular.copyWith(
                  color: const Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
              16.verticalSpace,

              // Pickup Details Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.location_solid,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                    8.horizontalSpace,
                    Expanded(
                      child: Text(
                        passenger.from,
                        style: AppTextStyle.text12Medium.copyWith(
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              20.verticalSpace,

              // Action buttons: Cancel & Confirm Boarding
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderColor),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyle.text14Semibold.copyWith(
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    flex: 2,
                    child: Obx(() => ElevatedButton(
                          onPressed: isSubmitting.value
                              ? null
                              : () async {
                                  isSubmitting.value = true;
                                  await tripsController
                                      .confirmPassengerBoardingDirectly(passenger);
                                  isSubmitting.value = false;

                                  if (sheetCtx.mounted) {
                                    Get.back();
                                  }
                                  await Future.delayed(
                                    const Duration(milliseconds: 200),
                                  );
                                  AppSnackBar.success(
                                    message:
                                        '${passenger.passengerName} is onboard! Proceeding to drop-off.',
                                  );
                                  setState(() {
                                    _manualTargetPassengerId = null;
                                    _manualTargetType = null;
                                    _updateTargetRoute(trip);
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: isSubmitting.value
                              ? SizedBox(
                                  width: 18.w,
                                  height: 18.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Confirm Boarding',
                                  style: AppTextStyle.text14Semibold.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        )),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRatePassengerSheet(
    DriverTripModel trip,
    PassengerRequestModel passenger, {
    bool isCompletingEntireTrip = false,
  }) {
    double selectedRating = 5.0;
    final List<String> availableBadges = [
      'Punctual',
      'Polite & Respectful',
      'Great Communication',
      'Clean & Quiet',
      'Followed Safety Rules',
    ];
    final Set<String> selectedBadges = {'Punctual', 'Polite & Respectful'};
    final TextEditingController commentController = TextEditingController();
    bool isSubmitting = false;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              20.w,
              16.h,
              20.w,
              24.h + MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.borderColor,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  16.verticalSpace,
                  Text(
                    'Trip Completed! 🎉',
                    style: AppTextStyle.text20Semibold.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  6.verticalSpace,
                  Text(
                    'Rate your passenger experience with ${passenger.passengerName}',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.text14Regular.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  18.verticalSpace,

                  // Passenger Avatar & Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50.r,
                        height: 50.r,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            passenger.passengerName.isNotEmpty
                                ? passenger.passengerName[0]
                                : 'P',
                            style: AppTextStyle.text20Semibold.copyWith(
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      12.horizontalSpace,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            passenger.passengerName,
                            style: AppTextStyle.text16Semibold.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${passenger.seats} Seat(s) • ${Utils.formatPrice(passenger.fare)} AUD collected',
                            style: AppTextStyle.text12Regular.copyWith(
                              color: const Color(0xFF16A34A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  16.verticalSpace,

                  // Star Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (starIndex) {
                      final starValue = starIndex + 1.0;
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            selectedRating = starValue;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: Icon(
                            starIndex < selectedRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 38.sp,
                          ),
                        ),
                      );
                    }),
                  ),

                  8.verticalSpace,
                  Text(
                    '${selectedRating.toStringAsFixed(1)} Stars',
                    style: AppTextStyle.text14Semibold.copyWith(
                      color: const Color(0xFFD97706),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  16.verticalSpace,

                  // Badges
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    alignment: WrapAlignment.center,
                    children: availableBadges.map((badge) {
                      final isSelected = selectedBadges.contains(badge);
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            if (isSelected) {
                              selectedBadges.remove(badge);
                            } else {
                              selectedBadges.add(badge);
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 7.h,
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
                            badge,
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: isSelected
                                  ? const Color(0xFF1D4ED8)
                                  : const Color(0xFF475569),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Payment Method Confirmation Selector
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF16A34A),
                              size: 18,
                            ),
                            6.horizontalSpace,
                            Text(
                              'Payment Settlement',
                              style: AppTextStyle.text12Semibold.copyWith(
                                color: const Color(0xFF15803D),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${Utils.formatPrice(passenger.fare)} AUD',
                              style: AppTextStyle.text14Semibold.copyWith(
                                color: const Color(0xFF15803D),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        4.verticalSpace,
                        Text(
                          'Payment received from passenger for ${passenger.seats} seat(s). Driver wallet will be credited automatically upon confirmation.',
                          style: AppTextStyle.text10Medium.copyWith(
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                  ),

                  16.verticalSpace,

                  // Comment Input
                  TextField(
                    controller: commentController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Add an optional note about this passenger...',
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
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: EdgeInsets.all(12.w),
                    ),
                  ),

                  20.verticalSpace,

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setSheetState(() => isSubmitting = true);
                              try {
                                await tripsController.submitPassengerRating(
                                  passengerId:
                                      passenger.passengerId ?? passenger.id,
                                  passengerName: passenger.passengerName,
                                  rating: selectedRating,
                                  comment: commentController.text.trim(),
                                  trip: trip,
                                  bookingId: passenger.id,
                                  fare: passenger.fare,
                                  paymentMethod: 'cash',
                                );
                                final bool allRated = trip.acceptedPassengers.every((p) => p.isRated.value);
                                if (isCompletingEntireTrip || trip.status.value == 'Completed' || allRated) {
                                  trip.status.value = 'Completed';
                                  tripsController.myTrips.refresh();
                                  final driverUid =
                                      AuthService.instance.currentUser?.uid ?? '';
                                  if (trip.id.isNotEmpty) {
                                    await TripService.instance.completeEntireTrip(
                                      tripId: trip.id,
                                      driverId: driverUid,
                                    );
                                  }
                                  if (Get.isRegistered<DriverHomeController>()) {
                                    Get.find<DriverHomeController>()
                                        .completedTripsCount
                                        .value++;
                                  }
                                  if (Get.isBottomSheetOpen == true) {
                                    Get.back();
                                  }
                                  await Future.delayed(const Duration(milliseconds: 200));
                                  _finishAndReturnToDriverHome(
                                    snackbarMessage: 'Trip completed successfully!',
                                  );
                                } else {
                                  Get.back();
                                  final nextUnrated = trip.acceptedPassengers.firstWhereOrNull((p) => !p.isRated.value);
                                  if (nextUnrated != null && isCompletingEntireTrip) {
                                    _showRatePassengerSheet(trip, nextUnrated, isCompletingEntireTrip: true);
                                  } else {
                                    setState(() {
                                      _manualTargetPassengerId = null;
                                      _manualTargetType = null;
                                      _updateTargetRoute(trip);
                                    });
                                  }
                                }
                              } catch (_) {
                                if (context.mounted) {
                                  setSheetState(() => isSubmitting = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF16A34A).withValues(alpha: 0.6),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: isSubmitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18.r,
                                  height: 18.r,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                10.horizontalSpace,
                                Text(
                                  'Confirming Dropoff & Payment...',
                                  style: AppTextStyle.text14Semibold.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Confirm Dropoff & Payment (${Utils.formatPrice(passenger.fare)} AUD)',
                              style: AppTextStyle.text14Semibold.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  if (isCompletingEntireTrip) ...[
                    8.verticalSpace,
                    TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setSheetState(() => isSubmitting = true);
                              try {
                                trip.status.value = 'Completed';
                                tripsController.myTrips.refresh();
                                final driverUid =
                                    AuthService.instance.currentUser?.uid ?? '';
                                if (trip.id.isNotEmpty) {
                                  await TripService.instance.completeEntireTrip(
                                    tripId: trip.id,
                                    driverId: driverUid,
                                  );
                                }
                                if (Get.isRegistered<DriverHomeController>()) {
                                  Get.find<DriverHomeController>()
                                      .completedTripsCount
                                      .value++;
                                }
                                _finishAndReturnToDriverHome(
                                  snackbarMessage: 'Trip completed successfully!',
                                );
                              } catch (_) {
                                if (context.mounted) {
                                  setSheetState(() => isSubmitting = false);
                                }
                              }
                            },
                      child: isSubmitting
                          ? SizedBox(
                              width: 16.r,
                              height: 16.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64748B)),
                              ),
                            )
                          : Text(
                              'Skip Rating & Finish Trip',
                              style: AppTextStyle.text14Medium.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = (Get.arguments is DriverTripModel ? Get.arguments as DriverTripModel : null) ??
        tripsController.liveTrip.value ??
        tripsController.selectedTripForRequests.value ??
        tripsController.myTrips.firstOrNull ??
        DriverTripModel(
          id: 'trip_fallback',
          from: 'Pickup Location',
          to: 'Drop-off Destination',
          time: 'Now',
          pricePerSeat: 15.0,
          totalSeats: 3,
          bookedSeats: 0,
          status: 'Active',
        );
    // Show center circular spinner or unavailable state if coordinates are missing
    if (_isLoading || _pickup == null || _dropoff == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.arrow_left, color: Color(0xFF0F172A)),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Live Driver Navigation',
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
              if (_isLoading) ...[
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
                  'Loading route navigation...',
                  style: AppTextStyle.text16Semibold.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                8.verticalSpace,
                Text(
                  'Calculating live route & pickup markers',
                  style: AppTextStyle.text12Regular.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
              ] else ...[
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.location_slash,
                    color: AppColors.primaryColor,
                    size: 32.sp,
                  ),
                ),
                14.verticalSpace,
                Text(
                  'Route Map Unavailable',
                  style: AppTextStyle.text16Semibold.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                6.verticalSpace,
                Text(
                  'GPS coordinates could not be found for this trip.',
                  style: AppTextStyle.text12Regular.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                18.verticalSpace,
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Obx(() {
        final activeTarget = _getActiveTargetStop(trip);

        return Stack(
          children: [
            // Full Screen Google Map
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentDriverLocation ?? _pickup!,
                zoom: 15.0,
              ),
              onMapCreated: (map) {
                _mapController = map;
                Future.delayed(const Duration(milliseconds: 350), () {
                  if (mounted) _fitBounds();
                });
              },
              markers: _buildMapMarkers(trip, activeTarget),
              polylines: {
                if (_driverToPickupRoute.isNotEmpty)
                  Polyline(
                    polylineId: const PolylineId('driver_to_pickup_route'),
                    points: _driverToPickupRoute,
                    color: const Color(0xFF0D9488), // Teal: Driver approaching target stop
                    width: 5,
                    patterns: [PatternItem.dash(20), PatternItem.gap(10)],
                  ),
                Polyline(
                  polylineId: const PolylineId('active_trip_route'),
                  points: _fullRoute,
                  color: const Color(0xFF2563EB), // Blue: Route corridor
                  width: 5,
                ),
              },
              mapType: _currentMapType,
              trafficEnabled: _trafficEnabled,
              myLocationEnabled: true,
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
                _DriverMapShortcutButton(
                  icon: CupertinoIcons.location_fill,
                  tooltip: 'Recenter Vehicle',
                  iconColor: const Color(0xFF2563EB),
                  onTap: _recenterVehicle,
                ),
                10.verticalSpace,

                // 2. Fit Full Route
                _DriverMapShortcutButton(
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
                _DriverMapShortcutButton(
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
                _DriverMapShortcutButton(
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
                  onTap: () => Get.toNamed(AppRoutes.driverSafetySos),
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

          // In-App Chat Alert Banner
          if (_activeInAppChatBanner != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 58.h,
              left: 16.w,
              right: 16.w,
              child: GestureDetector(
                onTap: () {
                  setState(() => _activeInAppChatBanner = null);
                  final target = activeTarget.passenger ??
                      (trip.acceptedPassengers.isNotEmpty
                          ? trip.acceptedPassengers.first
                          : null);
                  if (target != null) {
                    tripsController.openDriverChat(
                      passenger: target,
                      tripId: trip.id,
                      route: '${trip.from} → ${trip.to}',
                    );
                  }
                },
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16.r),
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(7.r),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0284C7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.chat_bubble_2_fill,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        10.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _activeInAppChatBanner!.senderName.isNotEmpty
                                    ? _activeInAppChatBanner!.senderName
                                    : 'Passenger',
                                style: AppTextStyle.text12Semibold.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              2.verticalSpace,
                              Text(
                                _activeInAppChatBanner!.message,
                                style: AppTextStyle.text12Regular.copyWith(
                                  color: const Color(0xFFE2E8F0),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        8.horizontalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            'Reply',
                            style: AppTextStyle.text10Medium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Bottom Slide Card: Passenger Details & Trip Controls
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
                        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
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

                  // Target Stop Sub-Header Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: activeTarget.isPickup
                                ? (activeTarget.passenger?.passengerStatus.value == 'arrived'
                                    ? const Color(0xFFF0FDFA)
                                    : const Color(0xFFFEF3C7))
                                : (activeTarget.isDropoff
                                    ? const Color(0xFFEFF6FF)
                                    : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: activeTarget.isPickup
                                  ? (activeTarget.passenger?.passengerStatus.value == 'arrived'
                                      ? const Color(0xFF99F6E4)
                                      : const Color(0xFFFDE68A))
                                  : (activeTarget.isDropoff
                                      ? const Color(0xFFBFDBFE)
                                      : const Color(0xFFCBD5E1)),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                activeTarget.isPickup
                                    ? (activeTarget.passenger?.passengerStatus.value == 'arrived'
                                        ? Icons.pin_drop_rounded
                                        : Icons.navigation_rounded)
                                    : (activeTarget.isDropoff
                                        ? CupertinoIcons.placemark_fill
                                        : Icons.flag_rounded),
                                size: 12.sp,
                                color: activeTarget.isPickup
                                    ? (activeTarget.passenger?.passengerStatus.value == 'arrived'
                                        ? const Color(0xFF0D9488)
                                        : const Color(0xFF92400E))
                                    : (activeTarget.isDropoff
                                        ? const Color(0xFF1D4ED8)
                                        : const Color(0xFF334155)),
                              ),
                              4.horizontalSpace,
                              Flexible(
                                child: Text(
                                  activeTarget.isPickup
                                      ? (activeTarget.passenger?.passengerStatus.value == 'arrived'
                                          ? 'ARRIVED • WAITING BOARD'
                                          : 'NEXT STOP: PICKUP')
                                      : (activeTarget.isDropoff
                                          ? 'NEXT STOP: DROP-OFF'
                                          : 'FINAL DESTINATION'),
                                  style: AppTextStyle.text10Medium.copyWith(
                                    color: activeTarget.isPickup
                                        ? (activeTarget.passenger?.passengerStatus.value == 'arrived'
                                            ? const Color(0xFF0F766E)
                                            : const Color(0xFF92400E))
                                        : (activeTarget.isDropoff
                                            ? const Color(0xFF1D4ED8)
                                            : const Color(0xFF334155)),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      6.horizontalSpace,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (activeTarget.passenger != null &&
                              _calculateDetourText(trip, activeTarget).isNotEmpty) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                _calculateDetourText(trip, activeTarget),
                                style: AppTextStyle.text10Medium.copyWith(
                                  color: const Color(0xFF2563EB),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            6.horizontalSpace,
                          ],
                          Builder(builder: (context) {
                            final eta = _calculateEtaMinutes(activeTarget);
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                eta == 0
                                    ? 'Arriving now'
                                    : 'ETA $eta min${eta > 1 ? 's' : ''}',
                                style: AppTextStyle.text10Medium.copyWith(
                                  color: const Color(0xFF16A34A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                  8.verticalSpace,

                  // Active Target Stop Header Row
                  Row(
                    children: [
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          color: activeTarget.isPickup
                              ? const Color(0xFFFEF3C7)
                              : (activeTarget.isDropoff
                                  ? const Color(0xFFEFF6FF)
                                  : const Color(0xFFF1F5F9)),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: activeTarget.passenger != null
                              ? Text(
                                  activeTarget.passenger!.passengerName.isNotEmpty
                                      ? activeTarget.passenger!.passengerName[0].toUpperCase()
                                      : 'P',
                                  style: AppTextStyle.text16Semibold.copyWith(
                                    color: activeTarget.isPickup
                                        ? const Color(0xFFD97706)
                                        : AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const Icon(
                                  Icons.flag_rounded,
                                  color: Color(0xFF475569),
                                  size: 18,
                                ),
                        ),
                      ),
                      10.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    activeTarget.title,
                                    style: AppTextStyle.text14Semibold.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (activeTarget.passenger != null) ...[
                                  6.horizontalSpace,
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star_rounded,
                                          color: const Color(0xFFD97706),
                                          size: 12.sp,
                                        ),
                                        2.horizontalSpace,
                                        Text(
                                          (activeTarget.passenger!.rating.value > 0
                                                  ? activeTarget.passenger!.rating.value
                                                  : 5.0)
                                              .toStringAsFixed(1),
                                          style: AppTextStyle.text10Medium.copyWith(
                                            color: const Color(0xFF92400E),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              activeTarget.passenger != null
                                  ? '${activeTarget.seats} seat${activeTarget.seats > 1 ? 's' : ''} • ${activeTarget.address}'
                                  : activeTarget.address,
                              style: AppTextStyle.text10Medium.copyWith(
                                color: AppColors.secondaryTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
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

                  // Cash Settlement Banner for Drop-off
                  if (activeTarget.isDropoff) ...[
                    8.verticalSpace,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.payments_rounded,
                                  color: Color(0xFF16A34A),
                                  size: 16,
                                ),
                                6.horizontalSpace,
                                Flexible(
                                  child: Text(
                                    'Fare to Collect (Cash):',
                                    style: AppTextStyle.text10Medium.copyWith(
                                      color: const Color(0xFF15803D),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          8.horizontalSpace,
                          Text(
                            '${Utils.formatPrice(activeTarget.fare)} AUD',
                            style: AppTextStyle.text12Semibold.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  12.verticalSpace,

                  // Main Target Action Controls
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tier 1: Primary Target Progression Action
                      Row(
                        children: [
                          if (activeTarget.isPickup &&
                              activeTarget.passenger?.passengerStatus.value != 'arrived') ...[
                            // Pickup En Route: "Arrived at Pickup" & "Board"
                            Expanded(
                              flex: 6,
                              child: Obx(() {
                                final isNotifying = _isNotifyingArrival.value;
                                return ElevatedButton.icon(
                                  onPressed: isNotifying
                                      ? null
                                      : () async {
                                          _isNotifyingArrival.value = true;
                                          try {
                                            await tripsController.updatePassengerTripStatus(
                                              passenger: activeTarget.passenger!,
                                              newStatus: 'arrived',
                                            );
                                            AppSnackBar.success(
                                              message:
                                                  'Notified ${activeTarget.passenger!.passengerName} that you have arrived!',
                                            );
                                          } finally {
                                            _isNotifyingArrival.value = false;
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D9488),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        const Color(0xFF0D9488).withValues(alpha: 0.6),
                                    disabledForegroundColor: Colors.white70,
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(vertical: 11.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  icon: isNotifying
                                      ? SizedBox(
                                          width: 14.r,
                                          height: 14.r,
                                          child: const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          CupertinoIcons.location_fill,
                                          size: 15,
                                        ),
                                  label: Text(
                                    isNotifying ? 'Notifying...' : 'Arrived at Pickup',
                                    style: AppTextStyle.text12Semibold.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                            ),
                            8.horizontalSpace,
                            Expanded(
                              flex: 4,
                              child: OutlinedButton.icon(
                                onPressed: () => _showConfirmPassengerBoardingSheet(
                                  trip,
                                  activeTarget.passenger!,
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF2563EB),
                                    width: 1.5,
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 11.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.person_add_alt_1_rounded,
                                  size: 15,
                                  color: Color(0xFF2563EB),
                                ),
                                label: Text(
                                  'Board',
                                  style: AppTextStyle.text12Semibold.copyWith(
                                    color: const Color(0xFF2563EB),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ] else if (activeTarget.isPickup) ...[
                            // Pickup Arrived: "Confirm Picked Up (Boarded)"
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showConfirmPassengerBoardingSheet(
                                  trip,
                                  activeTarget.passenger!,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(vertical: 11.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                ),
                                label: Text(
                                  'Confirm Picked Up (Boarded)',
                                  style: AppTextStyle.text12Semibold.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ] else if (activeTarget.isDropoff) ...[
                            // Dropoff: "Drop Off & Paid"
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final bool isLastPassenger = trip.acceptedPassengers
                                      .where((p) =>
                                          p.status.value != 'Dropped Off' &&
                                          p.status.value != 'Completed' &&
                                          p != activeTarget.passenger)
                                      .isEmpty;
                                  _showRatePassengerSheet(
                                    trip,
                                    activeTarget.passenger!,
                                    isCompletingEntireTrip: isLastPassenger,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(vertical: 11.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                icon: const Icon(
                                  CupertinoIcons.checkmark_circle_fill,
                                  size: 16,
                                ),
                                label: Text(
                                  'Drop Off & Paid (${Utils.formatPrice(activeTarget.fare)} AUD)',
                                  style: AppTextStyle.text12Semibold.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ] else ...[
                            // Final Destination: "Complete Entire Trip"
                            Expanded(
                              child: Obx(() {
                                final isCompleting = _isCompletingEntireTrip.value;
                                return ElevatedButton.icon(
                                  onPressed: isCompleting
                                      ? null
                                      : () async {
                                          final unratedPassenger =
                                              trip.acceptedPassengers.firstWhereOrNull(
                                            (p) => !p.isRated.value,
                                          );
                                          if (unratedPassenger != null) {
                                            _showRatePassengerSheet(
                                              trip,
                                              unratedPassenger,
                                              isCompletingEntireTrip: true,
                                            );
                                            return;
                                          }

                                          _isCompletingEntireTrip.value = true;
                                          try {
                                            trip.status.value = 'Completed';
                                            tripsController.myTrips.refresh();
                                            final driverUid =
                                                AuthService.instance.currentUser?.uid ?? '';
                                            if (trip.id.isNotEmpty) {
                                              await TripService.instance.completeEntireTrip(
                                                tripId: trip.id,
                                                driverId: driverUid,
                                              );
                                            }
                                            if (Get.isRegistered<DriverHomeController>()) {
                                              Get.find<DriverHomeController>()
                                                  .completedTripsCount
                                                  .value++;
                                            }
                                            _finishAndReturnToDriverHome(
                                              snackbarMessage:
                                                  'Trip completed successfully!',
                                            );
                                          } finally {
                                            _isCompletingEntireTrip.value = false;
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E293B),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        const Color(0xFF1E293B).withValues(alpha: 0.6),
                                    disabledForegroundColor: Colors.white70,
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(vertical: 11.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  icon: isCompleting
                                      ? SizedBox(
                                          width: 14.r,
                                          height: 14.r,
                                          child: const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.flag_rounded,
                                          size: 16,
                                        ),
                                  label: Text(
                                    isCompleting
                                        ? 'Completing Trip...'
                                        : 'Complete Entire Trip',
                                    style: AppTextStyle.text12Semibold.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ],
                      ),

                      // Tier 2: Secondary Communication Controls (Chat & Call) if passenger exists
                      if (activeTarget.passenger != null) ...[
                        8.verticalSpace,
                        Row(
                          children: [
                            // Chat Button
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => tripsController.openDriverChat(
                                  passenger: activeTarget.passenger!,
                                  tripId: trip.id,
                                  route: '${trip.from} → ${trip.to}',
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.borderColor),
                                  padding: EdgeInsets.symmetric(vertical: 9.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                                icon: const Icon(
                                  CupertinoIcons.chat_bubble_2_fill,
                                  size: 15,
                                  color: AppColors.primaryTextColor,
                                ),
                                label: Text(
                                  'Chat',
                                  style: AppTextStyle.text12Medium.copyWith(
                                    color: AppColors.primaryTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            8.horizontalSpace,
                            // Call Button
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  try {
                                    await Utils.launchURL(
                                      'tel:${activeTarget.passenger!.emergencyContactPhone}',
                                    );
                                  } catch (_) {}
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF93C5FD)),
                                  backgroundColor: const Color(0xFFEFF6FF),
                                  padding: EdgeInsets.symmetric(vertical: 9.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                                icon: const Icon(
                                  CupertinoIcons.phone_fill,
                                  color: Color(0xFF2563EB),
                                  size: 15,
                                ),
                                label: Text(
                                  'Call',
                                  style: AppTextStyle.text12Medium.copyWith(
                                    color: const Color(0xFF2563EB),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),

                  // Collapsible Expanded Details (All Stops List + SOS Emergency Info)
                  if (_isCardExpanded) ...[
                    14.verticalSpace,
                    const Divider(color: AppColors.borderColor, height: 1),
                    12.verticalSpace,

                    // Stops Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Route Itinerary (${trip.acceptedPassengers.length} passenger${trip.acceptedPassengers.length == 1 ? '' : 's'})',
                          style: AppTextStyle.text12Semibold.copyWith(
                            color: AppColors.primaryTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_manualTargetPassengerId != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _manualTargetPassengerId = null;
                                _manualTargetType = null;
                                _updateTargetRoute(trip);
                              });
                            },
                            child: Text(
                              'Reset to Auto',
                              style: AppTextStyle.text10Medium.copyWith(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    8.verticalSpace,

                    if (trip.acceptedPassengers.isNotEmpty) ...[
                      // List each passenger's stop
                      ...trip.acceptedPassengers.map((p) {
                        final isWaiting = p.isWaitingPickup;
                        final isOnboard = p.isOnboard;
                        final isDone = p.isDroppedOff;

                        return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: AppColors.containerFillColor,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: activeTarget.passenger?.id == p.id
                                  ? AppColors.primaryColor
                                  : AppColors.borderColor,
                              width: activeTarget.passenger?.id == p.id ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12.r,
                                    backgroundColor: const Color(0xFFEFF6FF),
                                    child: Text(
                                      p.passengerName.isNotEmpty ? p.passengerName[0] : 'P',
                                      style: AppTextStyle.text10Medium.copyWith(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  8.horizontalSpace,
                                  Expanded(
                                    child: Text(
                                      '${p.passengerName} (${p.seats} seat${p.seats > 1 ? 's' : ''})',
                                      style: AppTextStyle.text12Semibold.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDone
                                          ? const Color(0xFFDCFCE7)
                                          : (isOnboard
                                              ? const Color(0xFFEFF6FF)
                                              : (p.passengerStatus.value == 'arrived'
                                                  ? const Color(0xFFF0FDFA)
                                                  : const Color(0xFFFEF3C7))),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      isDone
                                          ? 'Completed'
                                          : (isOnboard
                                              ? 'Onboard'
                                              : (p.passengerStatus.value == 'arrived'
                                                  ? 'At Pickup'
                                                  : 'To Pickup')),
                                      style: AppTextStyle.text10Medium.copyWith(
                                        color: isDone
                                            ? const Color(0xFF16A34A)
                                            : (isOnboard
                                                ? const Color(0xFF2563EB)
                                                : (p.passengerStatus.value == 'arrived'
                                                    ? const Color(0xFF0D9488)
                                                    : const Color(0xFFD97706))),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              6.verticalSpace,
                              Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.location_solid,
                                    size: 12,
                                    color: Color(0xFF16A34A),
                                  ),
                                  4.horizontalSpace,
                                  Expanded(
                                    child: Text(
                                      'Pickup: ${p.from}',
                                      style: AppTextStyle.text10Medium.copyWith(
                                        color: AppColors.secondaryTextColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isWaiting) ...[
                                    GestureDetector(
                                      onTap: () => _showConfirmPassengerBoardingSheet(trip, p),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(6.r),
                                          border: Border.all(color: const Color(0xFFBFDBFE)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.person_add_alt_1_rounded,
                                              size: 11,
                                              color: Color(0xFF2563EB),
                                            ),
                                            3.horizontalSpace,
                                            Text(
                                              'Board',
                                              style: AppTextStyle.text10Medium.copyWith(
                                                color: const Color(0xFF2563EB),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (activeTarget.passenger?.id != p.id || !activeTarget.isPickup) ...[
                                      6.horizontalSpace,
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _manualTargetPassengerId = p.id;
                                            _manualTargetType = 'pickup';
                                            _updateTargetRoute(trip);
                                          });
                                        },
                                        child: Text(
                                          'Target',
                                          style: AppTextStyle.text10Medium.copyWith(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                              4.verticalSpace,
                              Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.placemark_fill,
                                    size: 12,
                                    color: Color(0xFFDC2626),
                                  ),
                                  4.horizontalSpace,
                                  Expanded(
                                    child: Text(
                                      'Drop: ${p.to}',
                                      style: AppTextStyle.text10Medium.copyWith(
                                        color: AppColors.secondaryTextColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isOnboard &&
                                      (activeTarget.passenger?.id != p.id ||
                                          !activeTarget.isDropoff))
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _manualTargetPassengerId = p.id;
                                          _manualTargetType = 'dropoff';
                                          _updateTargetRoute(trip);
                                        });
                                      },
                                      child: Text(
                                        'Target Drop',
                                        style: AppTextStyle.text10Medium.copyWith(
                                          color: const Color(0xFF16A34A),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ] else ...[
                      // Solo trip note
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          'No passengers on this trip yet. Open seats are discoverable along your corridor.',
                          style: AppTextStyle.text10Medium.copyWith(
                            color: const Color(0xFF1E40AF),
                          ),
                        ),
                      ),
                      10.verticalSpace,
                      OutlinedButton(
                        onPressed: () =>
                            tripsController.confirmCancelTrip(context, trip),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFCA5A5)),
                          backgroundColor: const Color(0xFFFEF2F2),
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel Trip',
                            style: AppTextStyle.text12Semibold.copyWith(
                              color: const Color(0xFFDC2626),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // SOS Emergency info for active passenger if present
                    if (activeTarget.passenger != null) ...[
                      10.verticalSpace,
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.shield_fill,
                              color: const Color(0xFFDC2626),
                              size: 15.sp,
                            ),
                            8.horizontalSpace,
                            Expanded(
                              child: Text(
                                'SOS: ${activeTarget.passenger!.emergencyContactName} (${activeTarget.passenger!.emergencyContactRelation})',
                                style: AppTextStyle.text10Medium.copyWith(
                                  color: const Color(0xFFB91C1C),
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                CupertinoIcons.phone_fill,
                                color: Color(0xFFDC2626),
                                size: 16,
                              ),
                              onPressed: () async {
                                try {
                                  await Utils.launchURL(
                                    'tel:${activeTarget.passenger!.emergencyContactPhone}',
                                  );
                                } catch (_) {}
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    }),
  );
  }
}

class _DriverMapShortcutButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color iconColor;
  final bool isActive;
  final VoidCallback onTap;

  const _DriverMapShortcutButton({
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
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveTargetStop {
  final PassengerRequestModel? passenger;
  final String type; // 'pickup' | 'dropoff' | 'destination'
  final String title;
  final String address;
  final LatLng location;
  final double fare;
  final int seats;

  const _ActiveTargetStop({
    this.passenger,
    required this.type,
    required this.title,
    required this.address,
    required this.location,
    this.fare = 0.0,
    this.seats = 1,
  });

  bool get isPickup => type == 'pickup';
  bool get isDropoff => type == 'dropoff';
  bool get isDestination => type == 'destination';
}
