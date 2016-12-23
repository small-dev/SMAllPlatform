include "console.iol"
include "runtime.iol"
include "time.iol"
include "string_utils.iol"
include "public/interfaces/BusCheckInterface.iol"
include "public/interfaces/GTFSCoreInterface.iol"


include "dependencies.iol"
include "locations.iol"

execution{ concurrent }

outputPort HelloBus {
	Location: "socket://hellobuswsweb.tper.it:443/web-services/hello-bus.asmx/"
	Protocol: https {
		.format = "x-www-form-urlencoded";
		.method = "GET";
		/*.debug = true;
		.debug.showContent = true;*/
		.addHeader.header = "Accept";
		.addHeader.header.value = "application/json"
	}
	RequestResponse: QueryHellobus
}

constants {
    polling_interval = 15000
}

outputPort GTFSCore {
    Location: JDEP_GTFS_CORE
    Protocol: sodep
    Interfaces: GTFSCoreInterface
}

outputPort MySelf {
    Interfaces: BusCheckLocalInterface, BusCheckInterface
}

inputPort BusCheckLocal {
    Location: "local"
    Interfaces: BusCheckLocalInterface, BusCheckInterface
}

inputPort BusCheck {
  Location: BUS_CHECK
  Protocol: sodep
  Interfaces: BusCheckInterface
}

cset {
		token: GetMonitorInfoRequest.token EndMonitorRequest.token
}

init {
  getLocalLocation@Runtime()( MySelf.location )
}

define __check_timestamp {
    // __time_to_check
    getCurrentDateValues@Time( )( date );
    tm = date.day + "/" + date.month + "/" + date.year + " "
        + __time_to_check.hour + ":" + __time_to_check.minute + ":00";
    tm.format = "dd/MM/yyyy hh:mm:ss";
    getTimestampFromString@Time( tm )( tm_to_check );
    __diff = tm_to_check - now
}


define __get_delay {
    // __departure_time
    // __estimated_time
    getCurrentDateValues@Time( )( date );
    sp = __estimated_time;
    sp.regex = ":";
    split@StringUtils( sp )( sp_result );
    tm = date.day + "/" + date.month + "/" + date.year + " "
        + sp_result.result[ 0 ] + ":" + sp_result.result[ 1 ] + ":00";
    tm.format = "dd/MM/yyyy hh:mm:ss";
    getTimestampFromString@Time( tm )( tm_estimated );

    sp = __departure_time;
    sp.regex = ":";
    split@StringUtils( sp )( sp_result );
    tm = date.day + "/" + date.month + "/" + date.year + " "
        + sp_result.result[ 0 ] + ":" + sp_result.result[ 1 ] + ":00";
    tm.format = "dd/MM/yyyy hh:mm:ss";
    getTimestampFromString@Time( tm )( tm_departure_time );

    __delay = tm_estimated - tm_departure_time
}

define __hello_bus_analysis {
  undef( current_hbus );
  rep = hello_bus;
  rep.replacement = "";
  rep.regex = "TperHellobus: ";
  replaceAll@StringUtils( rep )( ref1 );
  spl = ref1;
  spl.regex = ",";
  split@StringUtils( spl )( ref2 );
  for( rf = 0, rf < #ref2.result, rf++ ) {
    trim@StringUtils( ref2.result[ rf ] )( ref3 );
    spl = ref3;
    spl.regex = " ";
    split@StringUtils( spl )( ref4 );

    if ( ref4.result[ 1 ] == "DaSatellite" ) {
			if( #ref4.result >= 4 ) {
		      time_index = #current_hbus.( ref4.result[ 0 ] ).estimated.time;
		      current_hbus.( ref4.result[ 0 ] ).estimated.time[ time_index ] = ref4.result[ 2 ];
		      trim@StringUtils( ref4.result[ 3 ] )( current_hbus.( ref4.result[ 0 ] ).estimated.time[ time_index ].bus_name )
			}
    } else {
      time_index = #current_hbus.( ref4.result[ 0 ] ).scheduled.time;
      current_hbus.( ref4.result[ 0 ] ).scheduled.time[ time_index ] = ref4.result[ 2 ]
    }
  }
}

main {
    [ tripMonitor( request )( response ) {
        r_trip.trip_id = request.trip_id;
        getTrip@GTFSCore( r_trip )( trip );
        start.trip -> trip;
        startMonitor@MySelf( start )( response )
    }]

    [ startMonitor( request )( response ) {
			  println@Console( "starting monitor for trip " + request.trip.id )();
				csets.token = new;
				response.token = token = csets.token;
				monitor_index = 0;
        /* finding bus */
        __departure_time = request.trip.stops[ 0 ].departure_time;
        sp = __departure_time;
        sp.regex = ":";
        split@StringUtils( sp )( sp_result );
        __time_to_check.hour = sp_result.result[ 0 ];
        __time_to_check.minute = sp_result.result[ 1 ];
        getCurrentTimeMillis@Time()( now );
        __check_timestamp;
        found = false;
        while( __diff > 0 && !found ) {
	            QueryHellobus@HelloBus( { .fermata = request.trip.stops[ stop ].stop_id, .linea = request.trip.route_id, .oraHHMM = "" } )( hello_bus );
	            __hello_bus_analysis;
	            if ( is_defined( current_hbus.( request.trip.route_id ).estimated ) ) {
	                  found = true;
	                  bus_to_follow = current_hbus.( request.trip.route_id ).estimated.time.bus_name
	            };
	            if ( !found ) {
	              sleep@Time( polling_interval )();
	              getCurrentTimeMillis@Time()( now );
	              __check_timestamp
	            }
        };
				if ( !found ) {
						throw( BusNotFound )
				} else {
						response.bus = bus_to_follow
				}
				;
				end_monitor = false
		}] {
				undef( response );
				{
						stop = 0;
					  while ( (stop < #request.trip.stops) && !end_monitor ) {
		              this_stop = request.trip.stops[ stop ].stop_id;
		              __departure_time = request.trip.stops[ stop ].departure_time;
		              sp = __departure_time;
		              sp.regex = ":";
		              split@StringUtils( sp )( sp_result );
		              __time_to_check.hour = sp_result.result[ 0 ];
		              __time_to_check.minute = sp_result.result[ 1 ];
		              found = true;
		              while( found && !end_monitor ) {
		                  getCurrentTimeMillis@Time()( now );
		                  monitor[ monitor_index ].timestamp = now;
		                  monitor[ monitor_index ].departure_time = __departure_time;
		                  monitor[ monitor_index ].route_id = request.trip.route_id;
		                  monitor[ monitor_index ].stop_id = this_stop;
		                  found = false;
		                  /* if the scheduled time is greater than now, we continue to analyze the current stop */
		                  QueryHellobus@HelloBus( { .fermata = request.trip.stops[ stop ].stop_id, .linea = request.trip.route_id, .oraHHMM = "" } )( hello_bus );
		                  //println@Console( hello_bus )();
		                  __hello_bus_analysis;
		                  monitor[ monitor_index ].hbus << current_hbus;
		                  if ( is_defined( current_hbus.( request.trip.route_id ).estimated ) ) {
		                      for( i = 0, i < #current_hbus.( request.trip.route_id ).estimated.time, i++ ) {
		                          if ( current_hbus.( request.trip.route_id ).estimated.time[ i ].bus_name == bus_to_follow ) {
		                              found = true;
		                              __estimated_time = current_hbus.( request.trip.route_id ).estimated.time[ i ];
		                              __get_delay;
		                              monitor[ monitor_index ].delay = __delay
		                          }
		                      }
		                  } else {
		                      /* no estimated data are available, check nowtime w.r.t. the scheduled one */
		                      __check_timestamp;
		                      if ( __diff > 0 ) { found = true }
		                  }
											;
		                  /*valueToPrettyString@StringUtils( monitor[ monitor_index ] )( s );
		                  println@Console( s )();*/
		                  monitor_index++
		                  ;
		                  sleep@Time( polling_interval )()
		              }
									;
									stop++
						}
						;
						end.token = csets.token;
						endMonitor@MySelf( end )()
				}
				|
				{
					provide
							[ getMonitorInfo( request_get )( response ) {
									response.monitor -> monitor
							}]
					until
							[ endMonitor( request_end )( response_end ) {
								  end_monitor = true
							}]
				}
				;
				println@Console( "ending monitor for trip " + request.trip.id )()
			}
}
