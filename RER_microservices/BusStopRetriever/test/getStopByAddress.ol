include "console.iol"
include "string_utils.iol"
include "head.iol"

main {
  with( request ) {
    .address="via Irnerio 38";
    .radius=0.05
  };
  getStopsByAddress@BusStopRetriever( request )( result );
  valueToPrettyString@StringUtils( result )( s );
  println@Console( s )()
}
