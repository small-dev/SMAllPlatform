include "../locations.iol"
include "../public/interfaces/GTFSCoreInterface.iol"

outputPort GTFSManager {
	Location: GTFS_CORE
	//Location: "socket://130.136.2.89:9000"
	Protocol: sodep
	Interfaces: GTFSCoreInterface
}

outputPort GTFSAdmin {
	Location: GTFS_CORE_ADMIN
	//Location: "socket://130.136.2.89:9000"
	Protocol: sodep
	Interfaces: GTFSCoreAdminInterface
}
