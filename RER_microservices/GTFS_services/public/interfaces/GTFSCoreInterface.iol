include "../types/stops.iol"
include "../types/routes.iol"
include "../types/shapes.iol"
include "../types/agency.iol"

type GetAgenciesRequest: void

type GetAgenciesResponse: void {
    .agency*: GTFS_Agency
}

type GetAllShapesInATripRequest: void {
    .trip_id: string
}

type GetAllShapesInATripResponse: void {
    .shapes*: GTFS_Shapes
}

type GetAllStopsInARouteRequest: void {
    .route_id: string
    .direction_id: int
}

type GetAllStopsInARouteResponse: void {
    .service*: void {
      .id: string
      .stops*: GTFS_Stops
    }
}

type GetNextTripsRequest: void {
    .route_id: string
    .direction_id: int
    .start_stop_id: string
    .end_stop_id: string
    .max_trips: int
    .date: void {
      .year: int
      .month: int
      .day: int
    }
    .time: void {
      .hour: int
      .minute: int
      .second: int
    }
}

type GetNextTripsResponse: void {
    .trips*: void {
        .trip_id: string
        .service_id: string
        .stops*: void {
            .stop_id: string
            .stop_name: string
            .stop_lon: double
            .stop_lat: double
            .departure_time: string
        }
    }
}

type GetRoutesRequest: void

type GetRoutesByAgencyRequest: void {
  .agency_id: string
}

type GetRoutesResponse: void {
  .routes*: GTFS_Routes
}

type GetStopsRequest: void

type GetStopsByAgencyRequest: void {
  .agency_id: string
}

type GetStopsResponse: void {
  .stops*: GTFS_Stops
}

type GetStopsInAreaRequest: void {
  .radius: double
  .stop_lat: double
  .stop_lon: double
}

type GetStopsInAreaResponse: void {
  .stops*: void {
    .info: GTFS_Stops
    .distance: double
  }
}

type GetRoutesFromStopsRequest: void {
  .stop_id: string
}

type GetRoutesFromStopsResponse: void {
  .routes*: void {
    .info: GTFS_Routes
    .direction_id: int
  }
}

type GetStopTimesRequest: void {
  .route_id: string
  .stop_id: string
  .direction_id: int
  .date: void {
      .year: int
      .month: int
      .day: int
  }
}

type GetStopTimesResponse: void {
  .departure_time*: string
}

type GetTripRequest: void {
  .trip_id: string
}

type GetTripResponse: void {
    .id: string
    .direction_id: int
    .route_id: string
    .service_id: string
    .stops*: void {
        .stop_id: string
        .stop_name: string
        .departure_time: string
        .stop_lat: double
        .stop_lon: double
        .stop_sequence: int
    }
}

type GetTripsRequest: void {
  .route_id: string
  .direction_id: int
  .date: void {
    .year: int
    .month: int
    .day: int
  }
}

type GetTripsResponse: void {
  .trips*: void {
      .id: string
      .stops*: void {
          .stop_id: string
          .stop_name: string
          .departure_time: string
          .stop_lat: double
          .stop_lon: double
          .stop_sequence: int
      }
  }
}

/* admin */

type GetGTFSFileInfoRequest: void

type GetGTFSFileInfoResponse: void {
  .file*:string {
    .info?: void {
      .lastModified: long
      .size: long
      .absolutePath: string
      .isHidden: bool
      .isDirectory: bool
    }
  }
}

type RefreshAgenciesRequest: void

type RefreshAgenciesResponse: void

type RefreshCalendarRequest: void

type RefreshCalendarResponse: void

type RefreshCalendarDateRequest: void

type RefreshCalendarDateResponse: void

type RefreshRoutesRequest: void

type RefreshRoutesResponse: void

type RefreshShapesRequest: void

type RefreshShapesResponse: void

type RefreshStopsRequest: void

type RefreshStopsResponse: void

type RefreshStopTimesRequest: void

type RefreshStopTimesResponse: void

type RefreshTripsRequest: void

type RefreshTripsResponse: void

type UploadGTFSFileRequest: void {
    .filename: string
    .content: raw
}

type UpoladGTFSFileResponse: void

/**!
  List of all the API for managing GTFS data
*/
interface GTFSCoreInterface {
  RequestResponse:
    /**! @Rest: method=get, template=/all_agencies/; */
    getAgencies( GetAgenciesRequest )( GetAgenciesResponse ),
    /**! @Rest: method=get, template=/all_shapes/{trip_id}; */
    getAllShapesInATrip( GetAllShapesInATripRequest )( GetAllShapesInATripResponse ),
    /**! @Rest: method=get, template=/all_stops/{route_id}/{direction_id}; */
    getAllStopsInARoute( GetAllStopsInARouteRequest )( GetAllStopsInARouteResponse ),
    /**! @Rest: method=post; */
    getNextTrips( GetNextTripsRequest )( GetNextTripsResponse ),
    /**! @Rest: method=get, template=/all_routes/; */
    getRoutes( GetRoutesRequest )( GetRoutesResponse ),
    /**! @Rest: method=get, template=/all_routes/{agency_id}; */
    getRoutesByAgency( GetRoutesByAgencyRequest )( GetRoutesResponse ),
    /**! @Rest: method=get; */
    getRoutesFromStop( GetRoutesFromStopsRequest )( GetRoutesFromStopsResponse ),
    /**! @Rest: method=get, template=/all_stops/;*/
    getStops( GetStopsRequest )( GetStopsResponse ),
    /**! @Rest: method=get, template=/all_stops/{agency_id};*/
    getStopsByAgency( GetStopsByAgencyRequest )( GetStopsResponse ),
    /**! @Rest: method=post; */
    getStopTimes( GetStopTimesRequest )( GetStopTimesResponse ),
    /**! @Rest: method=get; */
    getStopsInArea( GetStopsInAreaRequest )( GetStopsInAreaResponse ),

    /**! @Rest: method=get, template=/trips/{trip_id};*/
    getTrip( GetTripRequest )( GetTripResponse ),

    /**! @Rest: method=post; */
    getTrips( GetTripsRequest )( GetTripsResponse )
      throws TripNotFound
}

interface GTFSCoreAdminInterface {
  RequestResponse:
    getGTFSFileInfo( GetGTFSFileInfoRequest )( GetGTFSFileInfoResponse ),
    refreshAgencies( RefreshAgenciesRequest )( RefreshAgenciesResponse ),
    refreshCalendar( RefreshCalendarRequest )( RefreshCalendarResponse ),
    refreshCalendarDate( RefreshCalendarDateRequest )( RefreshCalendarDateResponse ),
    refreshShapes( RefreshShapesRequest )( RefreshShapesResponse ),
    refreshRoutes( RefreshRoutesRequest )( RefreshRoutesResponse ),
    refreshStopTimes( RefreshStopTimesRequest )( RefreshStopTimesResponse ),
    refreshStops( RefreshStopsRequest )( RefreshStopsResponse ),
    refreshTrips( RefreshTripsRequest )( RefreshTripsResponse ),
    uploadGTFSFile( UploadGTFSFileRequest )( UpoladGTFSFileResponse ) throws FileNotPermitted
}
