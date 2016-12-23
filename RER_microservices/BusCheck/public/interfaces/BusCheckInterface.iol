type EndMonitorRequest: void {
    .token:string
}

type GetMonitorInfoRequest: void {
    .token: string
}

type GetMonitorInfoResponse: void {
    .monitor*: undefined
}


type TripMonitorResponse: void {
    .token: string
    .bus: string
}

type TripMonitorRequest: void {
    .trip_id: string
}

interface BusCheckInterface {
  RequestResponse:
    endMonitor( EndMonitorRequest )( void ),
    getMonitorInfo( GetMonitorInfoRequest )( GetMonitorInfoResponse ),
    tripMonitor( TripMonitorRequest )( TripMonitorResponse ) throws BusNotFound
}

type StartMonitorRequest: void {
    .trip: void {
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

}

type StartMonitorResponse: void {
    .token: string
    .bus: string
}

interface BusCheckLocalInterface {
  RequestResponse:
    startMonitor( StartMonitorRequest )( StartMonitorResponse ) throws BusNotFound
}
