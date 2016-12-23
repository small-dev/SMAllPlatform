include "console.iol"
include "string_utils.iol"
include "time.iol"

interface UtilsInterface {
  RequestResponse: prettyPrint, printTimeTable, 
    getNextTripID throws CouldNotFindTrip,
    update101( void )( void )
}

outputPort SmartPlanner {
  Location: "socket://travelplanner.lepida.it:80/smart-planner/bologna/rest/"
  Protocol: http {
    .format = "json";
    .contentType = "application/json";
    .osc.getroutes.alias = "getroutes/%!{agency}";
    .osc.getstops.alias = "getstops/%!{agency}/%{route}";
    .osc.gettimetable.alias = "gettimetable/%!{agency}/%{route}/%{stop}";
    .osc.updateAD.method = "POST";
    .method = "GET"
    // ;.debug << true { .showContent = true }
  }
  RequestResponse: agencies, getroutes, 
                   getstops, gettimetable,
                   updateAD
}

outputPort JSUtils {
  RequestResponse: millsToDate( long )( string ), 
                   timeToMills( string )( long ),
                   getMillsToTime( long )( string ),
                   getRandomMillsToTime( long )( string ),
                   getStartDayMills( void )( long ),
                   getEndDayMills( void )( long )
}

embedded {
  JavaScript: "jsutils.js" in JSUtils
}

outputPort BusEtaUtils {
  RequestResponse: getTimedoutBusEta
}

embedded {
  Jolie: "reportDelayUtils.ol" in BusEtaUtils
}

constants {
  GET_ETA_TIMEOUT = 15000
}

main
{
  update101@Utils()()
}

service Utils 
{
  Interfaces: UtilsInterface
  main
  {
    [ prettyPrint( r )(){
      valueToPrettyString@StringUtils( r )( t );
      println@Console( t )()
    }]
    [ getNextTripID( req )( trip ){
      gettimetable@SmartPlanner( req )( timetable );
      getCurrentTimeMillis@Time()( now );
      if( #timetable._ > 0 ) {
        trip -> timetable._[ i ];
        // finds the trip whose time is greater than "now"
        for ( i=0, i<#timetable._ && now > trip.time , ++i ) { nullProcess }
      };
      if( !is_defined( trip.trip.id ) ){
        throw( CouldNotFindTrip )
      }
    }]
    [ printTimeTable()(){
      agencies@SmartPlanner()( agencies );
      // prettyPrint@Utils( r );
      agency -> agencies._[ 7 ]; // TPERBO_EXTRA
      println@Console( "Selected agency: " + agency.name + ", id: " + agency.id )();
      request.agency = agency.id;
      getroutes@SmartPlanner( request )( routes );
      route -> routes._[ 0 ];
      request.route = route.id.id;
      println@Console( "Selected route: " + route.routeLongName + ", id: " + route.id.id )();
      getstops@SmartPlanner( request )( stops );
      // prettyPrint@Utils( stops )();
      stop -> stops._[ 1 ];
      println@Console( "Selected stop: " + stop.name + ", id: " + stop.id )();
      request.stop = stop.id;
      gettimetable@SmartPlanner( request )( timetable );
      // translate timetable in human format
      // prettyPrint@Utils( timetable._ )();
      if( #timetable._ > 0 ) {
        for ( trip in timetable._ ) {
          // prettyPrint@Utils( trip )();
          millsToDate@JSUtils( trip.time )( date );
          println@Console( date + ", id:" + trip.trip.id )()
        }
      } else {
        println@Console( "This Line does not serve this stop." )()
      }
    } ]
    [ update101()(){
      agency = "TPERBO_EXTRA";
      route = "101_TPERBO_EXTRA_0";
      routeShortName = "101";
      with ( stops ){
        .first << "305_TPERBO_EXTRA" {
          .name = "305"
        };
        .first_middle << "1503_TPERBO_EXTRA" {
          .name = "1503"
        };
        .middle << "10041_TPERBO_EXTRA" {
          .name = "10041"
        };
        .second_middle << "10083_TPERBO_EXTRA" {
          .name = "10083"
        };
        .last << "114101_TPERBO_EXTRA" {
          .name = "114101"
        }
      };

      foreach ( stop : stops ) {
        stop << stops.( stop );
        println@Console( "Checking stop: " + stop )();
        // delay_TTL = 1 * 60 * 1000; // 1 minute of TimeToLive for delays
        getCurrentTimeMillis@Time()( now );
        // printTimeTable@Utils()();
        getNextTripID@Utils( { .agency = agency, 
                               .route = route, 
                               .stop = stop } )( trip );
        // prettyPrint@Utils( trip )();
        
        etaReq.scheduled = trip.time;
        etaReq.req << { .stop = stop.name, .route = routeShortName };
        getTimedoutBusEta@BusEtaUtils( etaReq )( eta );
        
        if( is_defined( eta ) ){
          timeToMills@JSUtils( eta )( etaMills );
          getMillsToTime@JSUtils( trip.time )( sTime );
          println@Console( "Scheduled: " + trip.time + " | " + sTime )();
          println@Console( "ETA: " + etaMills + " | " + eta )()
        };
        
        if( etaMills > trip.time ){
          delay = etaMills - trip.time;
          getMillsToTime@JSUtils( delay )( sDelay );
          println@Console( "delay: " + delay + " | " + sDelay )();
          with ( request ){
            .creatorId = "SMAll";
            .creatorType = "SERVICE";
            .delay = delay;
            .description = routeShortName + 
              " in ritardo di " + sDelay + " minuti";
            getStartDayMills@JSUtils()( .from );
            getEndDayMills@JSUtils()( .to );
            // .from = now;
            // .to = now + delay_TTL;
            with ( .transport ) {
              .type = "BUS";
              .agencyId = agency;
              .routeId = route;
              // .routeShortName = routeShortName;
              .tripId = trip.trip.id
            }
          };
          updateAD@SmartPlanner( request )( response );
          prettyPrint@Utils( response )()
        } else {
          println@Console( "Empty or misaligned ETA.\n" )()
        }
      }
    }]
  }
}