include "console.iol"
include "string_utils.iol"

include "head.iol"


main {
  r.stop_lon = 11.342823;
  r.stop_lat = 44.493577;
  r.radius = 0.05;
  r.max_items = 15;
  getBusStopsInRadiusByCoordinates@BlindUnibo( r )( rs );
  valueToPrettyString@StringUtils( rs )( s );
  println@Console( s )()
  ;
  undef( r );
  r.address = "via Fondazza, Bologna";
  r.radius = 0.05;
  r.max_items = 15;
  getBusStopsInRadiusByAddress@BlindUnibo( r )( rs );
  valueToPrettyString@StringUtils( rs )( s );
  println@Console( s )()


}
