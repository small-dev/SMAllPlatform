include "string_utils.iol"
include "ini_utils.iol"

include "public/interfaces/BusStopRetrieverInterface.iol"
include "public/interfaces/GTFSCoreInterface.iol"

include "locations.iol"
include "dependencies.iol"

execution{ concurrent }

outputPort GTFSCore {
  Location: JDEP_GTFS_CORE
  Protocol: sodep
  Interfaces: GTFSCoreInterface
}

outputPort OSM {
  Location: "socket://open.mapquestapi.com:80/geocoding/v1/"
  Protocol: http {
    .method = "GET";
    .osc.address.alias = "address"
  }
  RequestResponse: address
}

inputPort BusStopRetriever {
  Location: BUS_STOP_RETRIEVER
  Protocol: sodep
  Interfaces: BusStopRetrieverInterface
}

init {
    parseIniFile@IniUtils( "config.ini" )( config );
    OSMKey = config.params.OSMKey
}

main {
  [ getStopsByAddress( request )( response ) {
        // retrieving coordinates from the address
        req.location = request.address;
        req.key = OSMKey;
        req.format = "json";
        address@OSM( req )( res );
        longitude = double( res.results.locations.displayLatLng.lng );
        latitude = double( res.results.locations.displayLatLng.lat );
        with( stops_in_area_req ) {
            .radius = request.radius;
            .stop_lat = latitude;
            .stop_lon = longitude
        };
        getStopsInArea@GTFSCore( stops_in_area_req )( response )
  }]

  [ getStopsByCoords( request )( response ) {
      getStopsInArea@GTFSCore( request )( response )
  }]
}
