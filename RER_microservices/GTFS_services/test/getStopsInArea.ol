include "console.iol"
include "string_utils.iol"
include "head_core.iol"

main {
  with( request ) {
      .radius = 0.1;
      .stop_lat = 44.4545922836761;
      .stop_lon = 11.4507040154304
  };
  getStopsInArea@GTFSManager( request )( result );
	valueToPrettyString@StringUtils( result )( s );
	println@Console( s )()
}
