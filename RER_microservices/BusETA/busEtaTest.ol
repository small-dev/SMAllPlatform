include "console.iol"
include "time.iol"

include "public/interfaces/BusETAInterface.iol"

include "locations.iol"

outputPort BusEta {
  Location: BUS_ETA
  Protocol: sodep
  Interfaces: BusETAInterface
}

main
{
  linee[ #linee ] = "11";
  linee[ #linee ] = "13";
  linee[ #linee ] = "14";
  linee[ #linee ] = "19";
  linee[ #linee ] = "20";
  linee[ #linee ] = "25";
  linee[ #linee ] = "27";
  linee[ #linee ] = "28";
  linee[ #linee ] = "36";
  linee[ #linee ] = "37";
  linee[ #linee ] = "62";
  linee[ #linee ] = "89";
  linee[ #linee ] = "93";
  linee[ #linee ] = "94";
  linee[ #linee ] = "99";
  linee[ #linee ] = "101";
  linee[ #linee ] = "106";
  linee[ #linee ] = "186";
  linee[ #linee ] = "187";
  linee[ #linee ] = "188";
  linee[ #linee ] = "205";
  linee[ #linee ] = "206";
  linee[ #linee ] = "211";
  linee[ #linee ] = "212";
  linee[ #linee ] = "213";
  linee[ #linee ] = "237";
  linee[ #linee ] = "242";
  linee[ #linee ] = "243";
  linee[ #linee ] = "257";
  linee[ #linee ] = "273";
  linee[ #linee ] = "301";
  linee[ #linee ] = "302";
  linee[ #linee ] = "900";
  linee[ #linee ] = "906";
  linee[ #linee ] = "916";
  linee[ #linee ] = "918";
  query.stop = "305"; // PORTA SAN DONATO, VIA IRNERIO 57
  for ( linea = 0, linea < #linee, linea++ ) {
    query.route -> linee[ linea ];
    tries[5] = 0;
    for ( try = 0, try < #tries, try++ ) {
      getBusEta@BusEta( query )( response )
    };
    if( !is_defined( response.missingRealtimeData ) ) {
      with( response.result ){
        println@Console(  "Linea: " + .route +
                          " Bus: " + .serial +
                          " ETA: " + .eta )()   }
    } else {
      println@Console( "Missing realtime data for stop: " + query.stop +
                       " route: " + query.route )()
    };
    sleep@Time( 1000 )()
  }
}
