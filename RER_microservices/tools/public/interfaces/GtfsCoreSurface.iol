
include "GTFSCoreInterface.iol"

outputPort GTFSManager {
	Protocol: sodep
	Interfaces: GTFSCoreInterface
}

outputPort GTFSAdmin {
	Protocol: sodep
	Interfaces: GTFSCoreAdminInterface
}
