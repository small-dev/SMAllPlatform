include "console.iol"
include "string_utils.iol"
include "head_core.iol"

main {
  with( request ) {
      .trip_id = "598_2269108"
      };
  getAllShapesInATrip@GTFSManager( request )( result );
  valueToPrettyString@StringUtils( result )( s );
  println@Console( s )()
}
