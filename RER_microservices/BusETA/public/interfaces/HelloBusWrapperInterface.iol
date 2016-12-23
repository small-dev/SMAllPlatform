type QueryHelloBusRequest: void {
  .stop: string
  .route: string
  .time: string
}

type QueryHelloBusResponse: void {
  .result?: void {
      .route: string
      .eta: string
      .serial: string
  }
}

interface HelloBusWrapperInterface {
  RequestResponse:
    queryHelloBus( QueryHelloBusRequest )( QueryHelloBusResponse ) throws MissingRealtimeData
}
