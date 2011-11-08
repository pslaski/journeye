/**
 * Created by JetBrains RubyMine.
 * User: pslaski
 * Date: 07.11.11
 * Time: 10:58
 * To change this template use File | Settings | File Templates.
 */



  var map = null;

  var geocoderService = null;
  var elevationService = null;
  var directionsService = null;

  var markers = [];
  var polyline = null;
  var elevations = null;

  var SAMPLES = 256;

   var examples = [{
    // Z Strbske Pleso na Rysy
    latlngs: [
      [49.120456, 20.064983],
      [49.184509, 20.083094]
    ],
    mapType: google.maps.MapTypeId.TERRAIN,
    travelMode: 'direct'
  }]

  // Set a callback to run when the Google Visualization API is loaded.
  google.setOnLoadCallback(initialize);

  function initialize() {
    var myLatlng = new google.maps.LatLng(15, 0);
    var myOptions = {
      zoom: 1,
      center: myLatlng,
      mapTypeId: google.maps.MapTypeId.TERRAIN
    }

    map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

    geocoderService = new google.maps.Geocoder();
    elevationService = new google.maps.ElevationService();
    directionsService = new google.maps.DirectionsService();

    google.maps.event.addListener(map, 'click', function(event) {
      addMarker(event.latLng, true);
    });

    loadExample(0);
  }

  // Takes an array of ElevationResult objects, draws the path on the map
  // and plots the elevation profile on a GViz ColumnChart
  function plotElevation(results) {
    elevations = results;

    var path = [];
    for (var i = 0; i < results.length; i++) {
      path.push(elevations[i].location);
    }

    if (polyline) {
      polyline.setMap(null);
    }

    polyline = new google.maps.Polyline({
      path: path,
      strokeColor: "#000000",
      map: map});


  }



  // Geocode an address and add a marker for the result
  function addAddress() {
    var address = document.getElementById('address').value;
    geocoderService.geocode({ 'address': address }, function(results, status) {
      document.getElementById('address').value = "";
      if (status == google.maps.GeocoderStatus.OK) {
        var latlng = results[0].geometry.location;
        addMarker(latlng, true);
        if (markers.length > 1) {
          var bounds = new google.maps.LatLngBounds();
          for (var i in markers) {
            bounds.extend(markers[i].getPosition());
          }
          map.fitBounds(bounds);
        } else {
          map.fitBounds(results[0].geometry.viewport);
        }
      } else if (status == google.maps.GeocoderStatus.ZERO_RESULTS) {
        alert("Address not found");
      } else {
        alert("Address lookup failed");
      }
    })
  }

  // Add a marker and trigger recalculation of the path and elevation
  function addMarker(latlng, doQuery) {
    if (markers.length < 10) {

      var marker = new google.maps.Marker({
        position: latlng,
        map: map,
        draggable: true
      })

      google.maps.event.addListener(marker, 'dragend', function(e) {
        updateElevation();
      });

      markers.push(marker);

      if (doQuery) {
        updateElevation();
      }

      if (markers.length == 10) {
        document.getElementById('address').disabled = true;
      }
    } else {
      alert("No more than 10 points can be added");
    }
  }

  // Trigger the elevation query for point to point
  // or submit a directions request for the path between points
  function updateElevation() {
    if (markers.length > 1) {
      var travelMode = document.getElementById("mode").value;
      if (travelMode != 'direct') {
        calcRoute(travelMode);
      } else {
        var latlngs = [];
        for (var i in markers) {
          latlngs.push(markers[i].getPosition())
        }
        elevationService.getElevationAlongPath({
          path: latlngs,
          samples: SAMPLES
        }, plotElevation);
      }
    }
  }

  // Submit a directions request for the path between points and an
  // elevation request for the path once returned
  function calcRoute(travelMode) {
    var origin = markers[0].getPosition();
    var destination = markers[markers.length - 1].getPosition();

    var waypoints = [];
    for (var i = 1; i < markers.length - 1; i++) {
      waypoints.push({
        location: markers[i].getPosition(),
        stopover: true
      });
    }

    var request = {
      origin: origin,
      destination: destination,
      waypoints: waypoints
    };

    switch (travelMode) {
      case "bicycling":
        request.travelMode = google.maps.DirectionsTravelMode.BICYCLING;
        break;
      case "driving":
        request.travelMode = google.maps.DirectionsTravelMode.DRIVING;
        break;
      case "walking":
        request.travelMode = google.maps.DirectionsTravelMode.WALKING;
        break;
    }

    directionsService.route(request, function(response, status) {
      if (status == google.maps.DirectionsStatus.OK) {
        elevationService.getElevationAlongPath({
          path: response.routes[0].overview_path,
          samples: SAMPLES
        }, plotElevation);
      } else if (status == google.maps.DirectionsStatus.ZERO_RESULTS) {
        alert("Could not find a route between these points");
      } else {
        alert("Directions request failed");
      }
    });
  }

  // Trigger a geocode request when the Return key is
  // pressed in the address field
  function addressKeyHandler(e) {
    var keycode;
    if (window.event) {
      keycode = window.event.keyCode;
    } else if (e) {
      keycode = e.which;
    } else {
      return true;
    }

    if (keycode == 13) {
       addAddress();
       return false;
    } else {
       return true;
    }
  }

  function loadExample(n) {
    resetMarkers();
    map.setMapTypeId(examples[n].mapType);
    document.getElementById('mode').value = examples[n].travelMode;
    var bounds = new google.maps.LatLngBounds();
    for (var i = 0; i < examples[n].latlngs.length; i++) {
      var latlng = new google.maps.LatLng(
        examples[n].latlngs[i][0],
        examples[n].latlngs[i][1]
      );
      addMarker(latlng, false);
      bounds.extend(latlng);
    }
    map.fitBounds(bounds);
    updateElevation();
  }

  // Clear all overlays, reset the array of points, and hide the chart
  function resetMarkers() {
    if (polyline) {
      polyline.setMap(null);
    }

    if(markers){
      for (var i in markers) {
      markers[i].setMap(null);
    }

    markers = [];
    }



  }

//send data to controller
  function sendData() {
      var locations = [];

      for(var i in markers){
         locations.push(markers[i].getPosition());
      }
      /*jQuery.ajax("trails/create", {data: {locations:locations}})*/
      $("input[name=locations]").val(locations);
      /*$("form#new_trail").submit();*/
  }


