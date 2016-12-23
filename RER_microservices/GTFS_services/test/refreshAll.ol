include "console.iol"
include "string_utils.iol"
include "head_core.iol"

main {
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
