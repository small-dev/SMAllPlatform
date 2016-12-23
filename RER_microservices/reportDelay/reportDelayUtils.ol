include "public/interfaces/BusETAInterface.iol"
include "busEtaAddress.iol"
include "console.iol"
include "time.iol"
include "runtime.iol"

inputPort In {
  Location: "local"
  RequestResponse: getTimedoutBusEta
}

outputPort BusEta {
  Location: BUSETA
  Protocol: sodep
  Interfaces: BusETAInterface
}

outputPort JSUtils {
  RequestResponse: millsToDate( long )( string ), 
                   timeToMills( string )( long ),
                   getMillsToTime( long )( string ),
                   getRandomMillsToTime( long )( string )
}

inputPort Self {
  Location: "local"
  OneWay: getBusEta
}

outputPort Self {
  OneWay: getBusEta
}

embedded {
  JavaScript: "jsutils.js" in JSUtils
}

execution{ concurrent }

init
{
  getLocalLocation@Runtime()( Self.location );
  ETAs -> global.etas
}

constants {
  ETA_TIMEOUT = 15 // seconds
}

main
{
  [ getTimedoutBusEta( req )( res ){
    eta -> ETAs.( req.req.stop );
    getBusEta@Self( req.req );
    for ( i=0, i<ETA_TIMEOUT && !is_defined( eta ), i++ ) {
      sleep@Time( 1000 )()
    };
    if ( !is_defined( eta ) ){
      getRandomMillsToTime@JSUtils( req.scheduled )( eta );
      println@Console( "Created Random ETA: " + eta )()
    };
    res = eta;
    undef( eta )
  }]
  [ getBusEta( req ) ]{
    getBusEta@BusEta( req )( res );
    ETAs.( req.stop ) = res.result.eta;
    println@Console( "Retrieved Actual Value: " + ETAs.( req.stop ) )()
  }
}
