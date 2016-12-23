include "console.iol"
include "./public/interfaces/FrontendInterface.iol"

outputPort Frontend {
	Protocol: sodep
	Interfaces: FrontendInterface
}


main {
	if ( args[0] == "--help" || args[0] == "--h" || #args != 5 ) {
      println@Console( "Usage:" )();
      println@Console( "jolie uploadGTFSFile.ol TARGET_HOST TARGET_PORT NAME CITY LOCATION" )();
      println@Console( "This tool allows for the upload of a GTFS file set to a gtfs_core based microservice")();
      println@Console( "TARGET_HOST is the host where the microservice is running")();
      println@Console( "TARGET_PORT is the port where the microservice admin inputPort is listening")();
			println@Console( "NAME name of the item in the registry")();
			println@Console( "CITY reference city")();
			println@Console( "LOCATION is the location of the target GTFS service")()
		} else {
	    TARGET_HOST = args[ 0 ];
	    TARGET_PORT = args[ 1 ];
			NAME = args[ 2 ];
			CITY = args[ 3 ];
			LOCATION = args[ 4 ];
			Frontend.location = "socket://" + TARGET_HOST + ":" + TARGET_PORT;
		  with( rq ) {
		    .name = NAME;
		    .city = CITY;
		    .location = LOCATION
		  };
		  addRegistryItem@Frontend( rq )()
		}
}
