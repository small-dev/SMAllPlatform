include "console.iol"
include "string_utils.iol"
include "head_core.iol"

main {
  with( request ) {
      .stop_id = "25"
  };
  getRoutesFromStop@GTFSManager( request )( result );
  valueToPrettyString@StringUtils( result )( s );
  println@Console( s )()
}
