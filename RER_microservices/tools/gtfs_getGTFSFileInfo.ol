include "console.iol"
include "string_utils.iol"
include "public/interfaces/GtfsCoreSurface.iol"


main {
  if ( args[0] == "--help" || args[0] == "--h" || #args != 3 ) {
      println@Console( "Usage:" )();
      println@Console( "jolie gtfs_getGTFSFileInfo.ol TARGET_HOST TARGET_PORT" )();
      println@Console( "This tool allows for the upload of a GTFS file set to a gtfs_core based microservice")();
      println@Console( "TARGET_HOST is the host where the microservice is running")();
      println@Console( "TARGET_PORT is the port where the microservice admin inputPort is listening")()
    } else {
    TARGET_HOST = args[ 0 ];
    TARGET_PORT = args[ 1 ];
    GTFSAdmin.location = "socket://" + TARGET_HOST + ":" + TARGET_PORT;

    getGTFSFileInfo@GTFSAdmin( request )( result );
    valueToPrettyString@StringUtils( result )( s );
    println@Console( s )()
  }
}
