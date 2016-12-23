include "head.iol"

main {
    r.trip_id = "663_2932914";
    tripMonitor@BusCheck( r )( s );
    valueToPrettyString@StringUtils( s )( s );
    println@Console( s )()
}
