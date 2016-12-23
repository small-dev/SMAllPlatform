type ETARequest: void {
  .stop: string
  .route: string
}

type ETAResponse: void {
  .result?: void {
      .route: string
      .eta: string
      .serial: string
  }
  .missingRealtimeData?: bool
}

type ETAResponseType: ETAResponse

interface BusETAInterface {
  RequestResponse:
  /**!
    @Rest: method=get, template=/buseta?stop={stop}&route={route};
  */
  getBusEta( ETARequest )( ETAResponseType ) throws MissingRealtimeData
}
