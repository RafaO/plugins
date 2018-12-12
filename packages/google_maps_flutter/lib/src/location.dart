// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

/// A pair of latitude and longitude coordinates, stored as degrees.
class LatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  /// The latitude is clamped to the inclusive interval from -90.0 to +90.0.
  ///
  /// The longitude is normalized to the half-open interval from -180.0
  /// (inclusive) to +180.0 (exclusive)
  const LatLng(double latitude, double longitude)
      : assert(latitude != null),
        assert(longitude != null),
        latitude =
            (latitude < -90.0 ? -90.0 : (90.0 < latitude ? 90.0 : latitude)),
        longitude = (longitude + 180.0) % 360.0 - 180.0;

  /// The latitude in degrees between -90.0 and 90.0, both inclusive.
  final double latitude;

  /// The longitude in degrees between -180.0 (inclusive) and 180.0 (exclusive).
  final double longitude;

  dynamic _toJson() {
    return <double>[latitude, longitude];
  }

  static LatLng _fromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    return LatLng(json[0], json[1]);
  }

  @override
  String toString() => '$runtimeType($latitude, $longitude)';

  @override
  bool operator ==(Object o) {
    return o is LatLng && o.latitude == latitude && o.longitude == longitude;
  }

  @override
  int get hashCode => hashValues(latitude, longitude);
}

/// Provides a way for creating bounds based on a list of [Marker], provided
/// through the method include.
/// It will iterate through all the markers and retrieve a new instance of the
/// class [LatLngBounds] with the southwest and northeast edges.
class LatLngBoundsBuilder {
  List<LatLng> _positions = <LatLng>[];

  LatLngBoundsBuilder include(LatLng marker) {
    _positions.add(marker);
    return this;
  }

  LatLngBounds build() {
    double south = double.negativeInfinity;
    double west = double.negativeInfinity;
    double north = double.maxFinite;
    double east = double.maxFinite;

    _positions.forEach((LatLng position) {
      if (south == double.negativeInfinity || position.latitude < south) {
        south = position.latitude;
      }
      if (west == double.negativeInfinity || position.longitude < west) {
        west = position.longitude;
      }
      if (north == double.maxFinite || position.latitude > north) {
        north = position.latitude;
      }
      if (east == double.maxFinite || position.longitude > east) {
        east = position.longitude;
      }
    });
    return LatLngBounds(
        southwest: LatLng(south, west), northeast: LatLng(north, east));
  }
}

/// A latitude/longitude aligned rectangle.
///
/// The rectangle conceptually includes all points (lat, lng) where
/// * lat ∈ [`southwest.latitude`, `northeast.latitude`]
/// * lng ∈ [`southwest.longitude`, `northeast.longitude`],
///   if `southwest.longitude` ≤ `northeast.longitude`,
/// * lng ∈ [-180, `northeast.longitude`] ∪ [`southwest.longitude`, 180[,
///   if `northeast.longitude` < `southwest.longitude`
class LatLngBounds {
  /// Creates geographical bounding box with the specified corners.
  ///
  /// The latitude of the southwest corner cannot be larger than the
  /// latitude of the northeast corner.
  LatLngBounds({@required this.southwest, @required this.northeast})
      : assert(southwest != null),
        assert(northeast != null),
        assert(southwest.latitude <= northeast.latitude);

  /// The southwest corner of the rectangle.
  final LatLng southwest;

  /// The northeast corner of the rectangle.
  final LatLng northeast;

  static LatLngBoundsBuilder builder() {
    return LatLngBoundsBuilder();
  }

  dynamic _toList() {
    return <dynamic>[southwest._toJson(), northeast._toJson()];
  }

  @visibleForTesting
  static LatLngBounds fromList(dynamic json) {
    if (json == null) {
      return null;
    }
    return LatLngBounds(
      southwest: LatLng._fromJson(json[0]),
      northeast: LatLng._fromJson(json[1]),
    );
  }

  @override
  String toString() {
    return '$runtimeType($southwest, $northeast)';
  }

  @override
  bool operator ==(Object o) {
    return o is LatLngBounds &&
        o.southwest == southwest &&
        o.northeast == northeast;
  }

  @override
  int get hashCode => hashValues(southwest, northeast);
}
