include "time.iol"
include "string_utils.iol"
include "console.iol"

include "public/interfaces/HelloBusWrapperInterface.iol"

include "dependencies.iol"

outputPort HelloBus {
        Location: "socket://hellobuswsweb.tper.it:443/web-services/hello-bus.asmx/"
        Protocol: https {
                .format = "x-www-form-urlencoded";
                .method = "GET"
                //.debug = true;
                //.debug.showContent = true
                // .addHeader.header = "Accept";
                // .addHeader.header.value = "application/xml"
        }
        RequestResponse: QueryHellobus4ivr
}

execution{ sequential }

inputPort HelloBusWrapper {
  Location: "local"
  Protocol: sodep
  Interfaces: HelloBusWrapperInterface
}

init {
  HELLO_BUS_TIMEOUT = int( JDEP_HELLO_BUS_TIMEOUT );
  install( MissingRealtimeData => nullProcess )
}

main {
    [ queryHelloBus( request )( response ) {
        // println@Console( "Querying HelloBus" )();
        QueryHellobus4ivr@HelloBus(
          { .fermata = request.stop, .linea = request.route, .oraHHMM = request.time }
        )( hb_resp );
        scope( scopeName )
        {
            split@StringUtils( hb_resp { .regex = "\\s|\\(|\\)|\\," } )( ss );
            // valueToPrettyString@StringUtils( ss )( t );
            // println@Console( t )();
            if( ss.result[3] == "DaSatellite" && !( ss.result[ 6 ] instanceof void ) ) {
              response.result << {
                .route = ss.result[2],
                .serial = ss.result[6],
                .eta = ss.result[4]
              }
            } else {
              throw( MissingRealtimeData )
            }
        }
    } ] {
      sleep@Time( HELLO_BUS_TIMEOUT )()
    }

}
