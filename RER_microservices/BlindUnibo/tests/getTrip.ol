include "console.iol"
include "string_utils.iol"

include "head.iol"


main {
  with( rq ) {
    .route_id = "19";
    .direction_id = 0;
    .start_stop_id = "6228";
    .end_stop_id = "6238";
    with( .time ) {
      .hour = 15;
      .minute = 0;
      .second = 0
    };
    with( .date ) {
      .year = 2016;
      .month = 4;
      .day = 29
    }
  };
  getTrip@BlindUnibo( rq )( rs );
  valueToPrettyString@StringUtils( rs )( s );
  println@Console( s )()


}
