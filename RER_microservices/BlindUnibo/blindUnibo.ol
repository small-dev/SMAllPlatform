include "string_utils.iol"
include "console.iol"

include "public/interfaces/BlindUniboInterface.iol"
include "public/interfaces/BusStopRetrieverInterface.iol"
include "public/interfaces/BusETAInterface.iol"
include "public/interfaces/GTFSCoreInterface.iol"

include "locations.iol"
include "dependencies.iol"

execution{ concurrent }

outputPort BusETA {
    Location: JDEP_BUS_ETA
    Protocol: sodep
    Interfaces: BusETAInterface
}

outputPort BusStopRetriever {
  	Location: JDEP_BUS_STOP_RETRIEVER
  	Protocol: sodep
  	Interfaces: BusStopRetrieverInterface
}

outputPort GTFSCore {
  Location: JDEP_GTFS_CORE
  Protocol: sodep
  Interfaces: GTFSCoreInterface
}

inputPort BlindUnibo {
  Location: BLIND_UNIBO
  Protocol: sodep
  Interfaces: BlindUniboInterface
  Aggregates: BusETA
}



define __getBusStopsInRadius {
  if ( max_items > #stops.stops ) {
    max_items = #stops.stops
  };
  if ( #stops.stops > 0 ) {
      for( i = 0, i < max_items, i++ ) {
            get_routes_req.stop_id = stops.stops[i].info.stop_id;
            getRoutesFromStop@GTFSCore( get_routes_req )( get_routes_res );
            with( response.stops[i] ) {
                  .info << stops.stops[i].info;
                  for ( r = 0, r < #get_routes_res.routes, r++ ) {
                      with( .routes[ r ] ) {
                        .id = get_routes_res.routes[ r ].info.route_id;
                        .direction_id = get_routes_res.routes[ r ].direction_id
                      }
                  }
            }
      }
  }
}

main {
  [ getBusStopsInRadiusByAddress( request )( response ) {
      max_items = request.max_items;
      undef( request.max_items );
      getStopsByAddress@BusStopRetriever( request )( stops );
      __getBusStopsInRadius
  }]

  [ getBusStopsInRadiusByCoordinates( request )( response ) {
    max_items = request.max_items;
    undef( request.max_items );
    getStopsByCoords@BusStopRetriever( request )( stops );
      __getBusStopsInRadius
  }]

  [ getNextTripStops( request )( response ) {
        request.max_trips = 1;
        getNextTrips@GTFSCore( request )( trip );
        response.stops << trip.trips[ 0 ].stops
  }]
}
