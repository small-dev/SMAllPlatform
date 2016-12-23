include "console.iol"
include "string_utils.iol"
include "head_core.iol"

main {

  with( rq ) {
    .route_id = "19";
    .direction_id = 0;
    .stop_id = "1043";
    with( .date ) {
      .year = 2016;
      .month = 6;
      .day = 15
    }
  };
  getStopTimes@GTFSManager( rq )( result );
  valueToPrettyString@StringUtils( result )( s );
  println@Console( s )()
}
