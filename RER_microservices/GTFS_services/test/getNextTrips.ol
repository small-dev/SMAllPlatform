include "console.iol"
include "string_utils.iol"
include "head_core.iol"

main {

  with( rq ) {
    .route_id = "19";
    .direction_id = 0;
    .start_stop_id = "1043";
    .end_stop_id = "1043";
    .max_trips = 3;
    with( .time ) {
      .hour = 14;
      .minute = 24;
      .second = 0
    };
    with( .date ) {
      .year = 2016;
      .month = 6;
      .day = 15
    }
  };
  getNextTrips@GTFSManager( rq )( result );
  valueToPrettyString@StringUtils( result )( s );
  println@Console( s )()
}
