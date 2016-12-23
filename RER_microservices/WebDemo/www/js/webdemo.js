var trips;
var map;
var markers = [];
var chart = [];
var config = [];
var last_monitor_index;
var current_stop;
var labels = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuwxyz0123456789';
var labelIndex = 0;
var registry;

/* other functions */
function goHome() {
  $("#main-content").load( "home.html" );
  $("#controlbar").hide();
}

function showMap( cityName, registryName ) {
  $("#controlbar").show();
  $("#main-content").html( "<h3>"
  + cityName + "</h3><div class=\"panel panel-default\" id=\"map\"></div>" );
  $("#myNavbar li").removeClass("active");
  initMap( cityName );
  JolieClient.getRoutes( { "registry_name":registryName }, function( data ) {
    clearPanelContent();
    $("#controlbar-title").html("Routes");
    $("#controlbar-content").append("<table class=\"table\" id=\"routes_table\"></table>");
    for( var i = 0; i < data.routes.length; i++ ) {
        $( "#routes_table").append("<tr><td class='stop_id'>" + data.routes[ i ].route_id
            + "</td><td class='route-name' onclick='getTrips(\""
            + registryName + "\",\"" + data.routes[ i ].route_id + "\",\"0\")'>" + data.routes[ i ].route_long_name + "</td></tr>");
        $( "#routes_table").append("<tr><td class='stop_id_opposite'>"
            + data.routes[ i ].route_id + "</td><td class='route-name' onclick='getTrips(\""
            + registryName + "\",\"" + data.routes[ i ].route_id + "\",\"1\")'>" + data.routes[ i ].route_long_name
            + " (Return)</td></tr>");
    }
  }, onError )
  $("#routes").show();
}

function clearPanelContent() {
    $("#controlbar-title").html("");
    $("#controlbar-content").empty();
}

function hideStopTimes() {
  $("#stop-times").hide();
}


function monitor( token, index ) {
    console.log("getting monitor info for token " + token );
    request = { 'token': token };
    JolieClient.getMonitorInfo( request, function( data ) {
        for( var m = last_monitor_index; m < data.monitor.length; m++ ) {
            console.log ( "analyzing monitor stop " + data.monitor[ m ].stop_id );
            stop_count = 0; stop_found = false;
            while( stop_count < trips.trips[ index ].stops.length && !stop_found ) {
                console.log ( "analyzing trip stop " + trips.trips[ index ].stops[ stop_count ].stop_id );
                if ( data.monitor[ m ].stop_id == trips.trips[ index ].stops[ stop_count ].stop_id ) {
                     bounceMarker( stop_count );
                     stop_found = true;
                }
                stop_count++;
            }
            var date = new Date( data.monitor[ m ].timestamp );
            var time = date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds() + " " + date.getMilliseconds();
            var delay = (data.monitor[ m ].delay/1000)/60;
            console.log( "delay " + delay );
            if ( data.monitor[ m ].stop_id != current_stop ) {
                current_stop = data.monitor[ m ].stop_id;
                $( "#chart" + current_stop ).append( "<canvas id='canvas" + current_stop + "'></canvas>" );

                var ctx = document.getElementById("canvas" + current_stop ).getContext("2d");
                config[ current_stop ] = {
                      type: 'line',
                      data: {
                          labels: [ time ],
                          datasets: [{
                              label: "Ritardo stimato",
                              data: [ delay ],
                              fill: true,
                              borderDash: [2, 2]
                          }]
                      },
                      options: {
                          responsive: true,
                          title:{
                              display:false
                          },
                          tooltips: {
                              mode: 'label',
                              callbacks: {
                              }
                          },
                        hover: {
                            mode: 'dataset'
                        },
                        scales: {
                            xAxes: [{
                                display: true,
                                scaleLabel: {
                                    display: true,
                                    labelString: 'Timestap'
                                }
                            }],
                            yAxes: [{
                                display: true,
                                scaleLabel: {
                                    display: true,
                                    labelString: 'Ritardo'
                                },
                                ticks: {
                                    suggestedMin: -2,
                                    suggestedMax: 10,
                                }
                            }]
                        }
                    }
                };
                chart[ current_stop ] = new Chart(ctx, config[ current_stop ]);
            } else {
                config[ current_stop ].data.labels.push( time );
                config[ current_stop ].data.datasets[ 0 ].data.push( delay );
                chart[ current_stop ].update();
            }

        }
        last_monitor_index = m;
        setTimeout( function () { monitor( token, index ) }, 15000 );
    }, onError );
}

function followTrip( registry_name, route_id, direction_id, index ) {
    config = [];
    chart = [];
    last_monitor_index = 0;
    current_stop = "";
    showStops( registry_name, route_id, direction_id, index, true );
    map.setZoom( 14 );
    request = { trip_id: trips.trips[ index ].id };
    JolieClient.tripMonitor( request, function( data ) {
        monitor( data.token, index );
        $( "#controlbar-title").after("<button class=\"btn btn-sm\" onclick='endMonitor(\"" + data.token + "\")'>Stop Bus Monitor</button>");
    }, onError );
}

function endMonitor( token ) {
  request = { "token": token }
  JolieClient.endMonitor( request, function( data ) { location.reload() }, onError );
}

function initMap( cityName ) {
    map = new google.maps.Map(document.getElementById('map'), {
      zoom: 15,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    });
    var geocoder = new google.maps.Geocoder();
    geocoder.geocode( { 'address': cityName }, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
            map.setCenter(results[0].geometry.location);
        } else {
            alert("Could not find location: " + cityName);
        }
    });
}

// Adds a marker to the map.
function addMarker(location, map, label, title ) {
 // Add the marker at the clicked location, and add the next-available label
 // from the array of alphabetical characters.
 var marker = new google.maps.Marker({
   position: location,
   title: title,
   label: label,
   map: map
 });
 markers.push(marker);
}

function stopBouncingMarkers() {
 for( var i = 0; i < markers.length; i++ ) {
    markers[i].setAnimation( null );
 }
}

function bounceMarker( index ) {
   markers[index].setAnimation( google.maps.Animation.BOUNCE );
}

// Sets the map on all markers in the array.
function setMapOnAll(map) {
  for (var i = 0; i < markers.length; i++) {
    markers[i].setMap(map);
  }
}

// Removes the markers from the map, but keeps them in the array.
function clearMarkers() {
  setMapOnAll(null);
}

// Shows any markers currently in the array.
function showMarkers() {
  setMapOnAll(map);
}

// Deletes all markers in the array by removing references to them.
function deleteMarkers() {
  clearMarkers();
  markers = [];
}

function getTrips( registry_name, route_id, direction_id ) {
    var currentTime = new Date()
    var month = currentTime.getMonth() + 1
    var day = currentTime.getDate()
    var year = currentTime.getFullYear()
    var request = { registry_name: registry_name, route_id: route_id, direction_id: direction_id, date: { year:year, month:month, day:day  } };
    JolieClient.getTrips( request, function( data ) {
        trips = data;
        data.trips.sort( function( a, b ) {
            var keyA = a.stops[ 0 ].departure_time;
            var keyB = b.stops[ 0 ].departure_time;
            if ( keyA < keyB ) return -1;
            if ( keyA > keyB ) return 1;
            return 0;
        } );
        clearPanelContent();
        $("#controlbar-title").html("Trips route " + route_id );
        $("#controlbar-content").append("<table class=\"table table-striped small\" id=\"trips_table\"></table>");
        $( "#trips_table").append("<tr><th></th><th>Start</th><th></th><th>End</th><th></th><th></th></tr>");
        for( var i = 0; i < data.trips.length; i++ ) {
          var stop_max = data.trips[ i ].stops.length - 1;
          $( "#trips_table").append("<tr><td><button class=\"btn btn-warning btn-sm\" onclick='followTrip(\"" + registry_name
          + "\",\"" + route_id + "\",\"" + direction_id + "\",\"" + i + "\")'>Follow</td></td><td>" + data.trips[ i ].stops[ 0 ].stop_name + "</td><td class='trip-departure-time'>"
          + data.trips[ i ].stops[ 0 ].departure_time + "</td><td>"
          + data.trips[ i ].stops[ stop_max ].stop_name + "</td><td class='trip-departure-time'>"
          + data.trips[ i ].stops[ stop_max ].departure_time + "</td><td>"
          + "<td><button class=\"btn btn-sm btn-info\" onclick='showStops(\"" + registry_name + "\",\""
          + route_id + "\",\"" + direction_id + "\"," + i + ",false)'>View</button></td>");
        }
    }, onError );
}

function getStopTimes( registry_name, route_id, direction_id, stop_id, stop_name ) {
  var currentTime = new Date()
  var month = currentTime.getMonth() + 1
  var day = currentTime.getDate()
  var year = currentTime.getFullYear()
  var request = { registry_name: registry_name, route_id: route_id, direction_id: direction_id, stop_id: stop_id, date: { year:year, month:month, day:day  } }
  JolieClient.getStopTimes( request, function( data ) {
      $("#myModal").modal("show");
      $(".modal-title").html( "timetable of Stop " + stop_name );
      $(".modal-body").empty().append("<table class=\"table\"></table>");
      for( i = 0; i < data.departure_time.length; i++ ) {
          $(".modal-body table").append("<tr><td>" + data.departure_time[ i ] + "</td></tr>" );
      }
  }, onError );
}

function showStops( registry_name, route_id, direction_id, index, busFollow ) {
    deleteMarkers();
    clearPanelContent();
    var stop_max = trips.trips[ index ].stops.length - 1;
    var trip_description = "Trips route" + route_id + "<br><span class=\"small\">" + trips.trips[ index ].stops[ 0 ].stop_name
    + " (" + trips.trips[ index ].stops[ 0 ].departure_time + ")"
    + "<br>" + trips.trips[ index ].stops[ stop_max ].stop_name
    + " (" + trips.trips[ index ].stops[ stop_max ].departure_time + ")</span>";
    var trip_id = trips.trips[ index ].id;
    var stops = trips.trips[ index ].stops;
    $("#controlbar-title").html( trip_description );
    var middlestop = parseInt( stops.length / 2, 10 );
    map = new google.maps.Map(document.getElementById('map'), {
        zoom: 14,
        center: {lat: parseFloat( stops[ middlestop ].stop_lat ),
                lng:  parseFloat( stops[ middlestop ].stop_lon ) },
        mapTypeId: google.maps.MapTypeId.ROADMAP });
    $("#controlbar-content").append("<table class=\"table small\" id=\"stops_table\"></table>");
    for( var i = 0; i < stops.length; i++ ) {
        var stop_id = stops[ i ].stop_id;
        var stop_name = stops[ i ].stop_name;
        var stop_lat = stops[ i ].stop_lat;
        var stop_lon = stops[ i ].stop_lon;
        var departure_time = stops[ i ].departure_time;
        if ( !busFollow ) {
            $("#stops_table").append("<tr><td>"
            + departure_time + "</td><td class='stop-item-label'>" + labels.charAt( i )
            + "</td><td class='stop-item' onclick='getStopTimes(\""
            + registry_name + "\",\"" + route_id + "\",\"" + direction_id + "\",\""
            + stop_id + "\",\"" + stop_name + "\")' onmouseout='stopBouncingMarkers()' onmouseover='bounceMarker(" + i + ")'>"
            + stop_name + "</td></tr>");
        } else {
            $("#stops_table").append("<tr><table id='stop" + stop_id + "'><tr><td>"
            + departure_time + "</td><td class='stop-item-label'>"
            + labels.charAt( i )
            + "</td><td class='stop-item'>" + stop_name + "</td></tr><tr><td id='chart"
            + stop_id + "' class='chart' colspan='3'></td></tr></table></tr>");
        }
        addMarker( { lat: parseFloat( stop_lat ), lng: parseFloat( stop_lon )  },
          map, labels.charAt( i ),
          stops[ i ].stop_name
         );
    }
    $("#stops").show();
    var request = { registry_name: registry_name, trip_id: trip_id };
    JolieClient.getAllShapesInATrip( request, function( data ) {
      var travelPlanCoordinates = [];
      for( var i = 0; i < data.shapes.length; i++ ) {
        travelPlanCoordinates.push({ lat: parseFloat( data.shapes[i].shape_pt_lat ),
          lng: parseFloat( data.shapes[i].shape_pt_lon )} );
      }

      var busPath = new google.maps.Polyline({
        path: travelPlanCoordinates,
        geodesic: true,
        strokeColor: '#0000FF',
        strokeOpacity: 0.8,
        strokeWeight: 6
      });

      busPath.setMap(map);
    }, onError );
}

function onError( data ) {
  alert( data.error.message );
}

/*JolieClient.getRoutes( {}, function( data ) {
  $("#content-title").html("Routes");
  for( var i = 0; i < data.routes.length; i++ ) {
      $( "#routes_table").append("<tr><td class='stop_id'>" + data.routes[ i ].route_id + "</td><td class='route-name' onclick='getTrips(\"" + data.routes[ i ].route_id + "\",\"0\")'>" + data.routes[ i ].route_long_name + "</td></tr>");
      $( "#routes_table").append("<tr><td class='stop_id_opposite'>" + data.routes[ i ].route_id + "</td><td class='route-name' onclick='getTrips(\"" + data.routes[ i ].route_id + "\",\"1\")'>" + data.routes[ i ].route_long_name + " (Return)</td></tr>");
  }
}, onError )
$("#routes").show();*/
