include "head.iol"

main {
    r.token = args[ 0 ];
    endMonitor@BusCheck( r )( s );
    valueToPrettyString@StringUtils( s )( s );
    println@Console( s )()
}
