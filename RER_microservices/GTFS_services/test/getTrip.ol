include "console.iol"
include "string_utils.iol"
include "head_core.iol"

main {
  with( request ) {
      .trip_id = "598_2919638"
  };
  getTrip@GTFSManager( request )( result );

  valueToPrettyString@StringUtils( result )( s );
  println@Console( "trip number " + t + "\n" + s )()
}
