include "../locations.iol"
include "../public/interfaces/FrontendInterface.iol"

outputPort Frontend {
	Location: WEBDEMO_ADMIN
	Protocol: sodep
	Interfaces: FrontendInterface
}
