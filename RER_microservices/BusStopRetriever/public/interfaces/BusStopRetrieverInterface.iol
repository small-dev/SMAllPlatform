include "../types/stops.iol"

type GetStopsByAddressRequest: void {
  .address: string
  .radius: double
}

type GetStopsByAddressResponse: void {
  .stops*: void {
    .info: GTFS_Stops
    .distance: double
  }
}

type GetStopsByCoordsRequest: void {
  .radius: double
  .stop_lat: double
  .stop_lon: double
}

type GetStopsByCoordsResponse: void {
  .stops*: void {
    .info: GTFS_Stops
    .distance: double
  }
}


interface BusStopRetrieverInterface {
  RequestResponse:
    getStopsByAddress( GetStopsByAddressRequest )( GetStopsByAddressResponse ),
    getStopsByCoords( GetStopsByCoordsRequest )( GetStopsByCoordsResponse )
}
