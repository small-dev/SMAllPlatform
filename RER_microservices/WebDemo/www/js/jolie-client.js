var JolieClient = JolieClient || (function() {
    var API = {};
    var isError = function( data ) {
        if ( data != null && typeof data.error != "undefined" ) {
            return true;
        }
        return false;
    }

    var jolieCall = function( operation, request, callback, errorHandler ) {

        $.ajax({
            url: '/' + operation,
            dataType: 'json',
            data: JSON.stringify( request ),
            type: 'POST',
            contentType: 'application/json;charset=UTF-8',
            success: function( data ){
               if ( isError( data ) ) {
                    if ( data.error.message == "SessionExpired") {
                        showSessionExpiredDialog();
                    } else {
                        errorHandler( data );
                    }
               } else {
                    callback( data );
               }
            },
            error: function(errorType, textStatus, errorThrown) {
              errorHandler( textStatus );
            }
        });
    }

    API.endMonitor = function( request, callback, errorHandler ) {
        jolieCall( "endMonitor", request, callback, errorHandler );
    }

    API.getAllShapesInATrip = function( request, callback, errorHandler ) {
        jolieCall( "getAllShapesInATrip", request, callback, errorHandler );
    }

    API.getMonitorInfo = function( request, callback, errorHandler ) {
        jolieCall( "getMonitorInfo", request, callback, errorHandler );
    }

    API.getRegistryItems = function( request, callback, errorHandler ) {
        jolieCall( "getRegistryItems", request, callback, errorHandler );
    }

    API.getRoutes = function( request, callback, errorHandler ) {
        jolieCall( "getRoutes", request, callback, errorHandler );
    }

    API.getStopTimes = function( request, callback, errorHandler ) {
        jolieCall( "getStopTimes", request, callback, errorHandler );
    }

    API.getTrips = function( request, callback, errorHandler ) {
        jolieCall( "getTrips", request, callback, errorHandler );
    }

    API.tripMonitor = function( request, callback, errorHandler ) {
        jolieCall( "tripMonitor", request, callback, errorHandler );
    }

    return API;
})();
