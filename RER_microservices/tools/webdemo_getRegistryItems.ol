include "console.iol"
include "string_utils.iol"
include "./public/interfaces/FrontendInterface.iol"

outputPort Frontend {
	Protocol: sodep
	Interfaces: FrontendInterface
}

main {
  if ( args[0] == "--help" || args[0] == "--h" || #args != 2 ) {
      println@Console( "Usage:" )();
      println@Console( "jolie uploadGTFSFile.ol TARGET_HOST TARGET_PORT" )();
      println@Console( "This tool allows for the upload of a GTFS file set to a gtfs_core based microservice")();
      println@Console( "TARGET_HOST is the host where the microservice is running")();
      println@Console( "TARGET_PORT is the port where the microservice admin inputPort is listening")()
		} else {
	    TARGET_HOST = args[ 0 ];
	    TARGET_PORT = args[ 1 ];
			Frontend.location = "socket://" + TARGET_HOST + ":" + TARGET_PORT;
      getRegistryItems@Frontend( rq )( items );
      valueToPrettyString@StringUtils( items )( s );
      println@Console( s )()
    }
}
