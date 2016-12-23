include "../public/interfaces/BlindUniboInterface.iol"
include "../../locations.iol"

outputPort BlindUnibo {
	Location: BLIND_UNIBO
	Protocol: sodep
	Interfaces: BlindUniboInterface
}
