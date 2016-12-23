include "../types/stops.iol"
include "../types/routes.iol"

type GetBusStopsInRadiusByAddressRequest: void {
   .address: string
   .radius: double
   .max_items: int
}

type getBusStopsInRadiusByCoordinatesRequest: void {
   .stop_lon: double
   .stop_lat: double
   .radius: double
   .max_items: int
}

type GetBusStopsInRadiusResponse: void {
  .stops*: void {
    .info: GTFS_Stops
    .routes*: void {
      .id: string
      .direction_id: int
    }
  }
}

type GetNextTripStopsRequest: void {
    .route_id: string
    .direction_id: int
    .start_stop_id: string
    .end_stop_id: string
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

type GetNextTripStopsResponse: void {
    .stops*: void {
        .stop_id: string
        .stop_name: string
        .stop_lon: double
        .stop_lat: double
        .departure_time: string
    }
}

interface BlindUniboInterface {
  RequestResponse:
    /**!
      @Rest: method=get, template=/stops?address={address}&radius={radius}&max_items={max_items};
      It returns all the bus stops within a circle whose center is identified by .coord. .radius defines the radius of the circle
    */
    getBusStopsInRadiusByAddress( GetBusStopsInRadiusByAddressRequest )( GetBusStopsInRadiusResponse ),

    /**!
      @Rest: method=get, template=/stops?stop_lat={stop_lat}&stop_lon={stop_lon}&radius={radius}&max_items={max_items};
      It returns all the bus stops within a circle whose center is identified by .coord. .radius defines the radius of the circle
    */
    getBusStopsInRadiusByCoordinates( getBusStopsInRadiusByCoordinatesRequest )( GetBusStopsInRadiusResponse ),

    /**! @Rest:  method=post; */
    getNextTripStops( GetNextTripStopsRequest )( GetNextTripStopsResponse )
}
