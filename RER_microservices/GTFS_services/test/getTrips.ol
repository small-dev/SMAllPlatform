include "console.iol"
include "string_utils.iol"
include "head_core.iol"

main {
  with( request ) {
      .route_id = "19";
      .direction_id = 0;
      with( .date ) {
        .year = 2016;
        .month = 6;
        .day = 20
      }
  };
  getTrips@GTFSManager( request )( result );

  valueToPrettyString@StringUtils( result )( s );
  println@Console( s )()
}
