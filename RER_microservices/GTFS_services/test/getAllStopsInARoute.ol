include "console.iol"
include "string_utils.iol"
include "head_core.iol"

main {
  with( request ) {
      .route_id = "19";
      .direction_id = 0
  };
  getAllStopsInARoute@GTFSManager( request )( result );
  valueToPrettyString@StringUtils( result )( s );
  println@Console( s )()
}
