
include "../locations.iol"
include "../public/interfaces/BusStopRetrieverInterface.iol"

outputPort BusStopRetriever {
	Location: BUS_STOP_RETRIEVER
	Protocol: sodep
	Interfaces: BusStopRetrieverInterface
}
