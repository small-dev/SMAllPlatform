include "console.iol"
include "string_utils.iol"
include "head.ol"

main {
  getRegistryItems@Frontend( rq )( items );
  valueToPrettyString@StringUtils( items )( s );
  println@Console( s )()
}
