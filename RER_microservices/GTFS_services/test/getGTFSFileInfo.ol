include "console.iol"
include "string_utils.iol"
include "head_core.iol"

main {
  getGTFSFileInfo@GTFSAdmin( request )( result );
  valueToPrettyString@StringUtils( result )( s );
  println@Console( s )()
}
