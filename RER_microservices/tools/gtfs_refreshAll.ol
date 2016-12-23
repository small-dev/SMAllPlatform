include "console.iol"
include "string_utils.iol"
include "public/interfaces/GtfsCoreSurface.iol"

main {
  if ( args[0] == "--help" || args[0] == "--h" || #args != 2 ) {
      println@Console( "Usage:" )();
      println@Console( "jolie gtfs_refreshAll.ol TARGET_HOST TARGET_PORT" )();
      println@Console( "This tool allows for the refreshing of all the gtfs data on a gtfs_core based microservice.")();
      println@Console( "Refreshing will delete the existing data replacing them with those previously uploaded.")();
      println@Console( "TARGET_HOST is the host where the microservice is running")();
      println@Console( "TARGET_PORT is the port where the microservice admin inputPort is listening")()
  } else {
      TARGET_HOST = args[ 0 ];
      TARGET_PORT = args[ 1 ];

      GTFSAdmin.location = "socket://" + TARGET_HOST + ":" + TARGET_PORT;

      println@Console("Refreshing agencies...")();
      refreshAgencies@GTFSAdmin()();

      println@Console("Refreshing CalendarDate...")();
      refreshCalendarDate@GTFSAdmin()();

      println@Console("Refreshing Shapes...")();
      refreshShapes@GTFSAdmin()();

      println@Console("Refreshing Routes...")();
      refreshRoutes@GTFSAdmin()();

      println@Console("Refreshing Stops...")();
      refreshStops@GTFSAdmin()();

      println@Console("Refreshing Trips...")();
      refreshTrips@GTFSAdmin()();

      println@Console("Refreshing StopTimes...")();
      refreshStopTimes@GTFSAdmin()();

      println@Console("Done.")()
  }
}
