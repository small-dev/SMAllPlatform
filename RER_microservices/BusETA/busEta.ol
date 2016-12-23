include "console.iol"
include "time.iol"
include "string_utils.iol"
include "semaphore_utils.iol"

include "public/interfaces/BusETAInterface.iol"
include "public/interfaces/HelloBusWrapperInterface.iol"

include "dependencies.iol"
include "locations.iol"

execution{ concurrent }

outputPort HelloBus {
  Interfaces: HelloBusWrapperInterface
}

embedded {
  Jolie:
    "helloBusWrapper.ol" in HelloBus
}

inputPort BusEta {
  Location: BUS_ETA
  Protocol: sodep
  Interfaces: BusETAInterface
}

init
{
  cached_eta -> global.cache.( request.stop ).( request.route ).eta
}

define queryHelloBus
{
  // println@Console( "Querying HelloBus" )();
    scope( scopeName )
    {
      install( MissingRealtimeData =>
        response.missingRealtimeData = cached_eta.missingRealtimeData = true;
        getCurrentTimeMillis@Time()( cached_eta.time )
      );
      queryHelloBus@HelloBus(
        { .stop = request.stop, .route = request.route, .time = "" }
      )( response );
      cached_eta << response;
      getCurrentTimeMillis@Time()( cached_eta.time )
    }
}

define checkSemaphores
{
  synchronized( cache ){
    if ( !is_defined( global.cache.( request.stop ).( request.route ).semaphore ) ){
      release@SemaphoreUtils( { .name = request.stop + request.route } )();
      global.cache.( request.stop ).( request.route ).semaphore = true
    }
  }
}

main
{
  [ getBusEta( request )( response ) {
    checkSemaphores;
    scope( s )
    {
        install( MissingRealtimeData =>
          release@SemaphoreUtils( { .name = request.stop + request.route } )()
        );
        acquire@SemaphoreUtils( { .name = request.stop + request.route } )();

        response << cached_eta;
        if ( is_defined( response ) ){
          getCurrentTimeMillis@Time()( now );
          if( ( now - cached_eta.time ) < JDEP_CACHE_TIMEOUT ) {
              undef( response.time )
              // println@Console( "Cache" )()
          } else {
              // println@Console( "Invalidating cache" )();
              undef( global.cache.( request.stop ).( request.route ).eta );
              queryHelloBus
          }
        } else {
              // println@Console( "Retrieving a new" )();
              queryHelloBus
        };
        release@SemaphoreUtils( { .name = request.stop + request.route } )()
    }
  } ] { nullProcess }
}
