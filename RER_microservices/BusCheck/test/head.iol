include "console.iol"
include "string_utils.iol"
include "../public/interfaces/BusCheckInterface.iol"
include "../../locations.iol"

outputPort BusCheck {
  Location: BUS_CHECK
  Protocol: sodep
  Interfaces: BusCheckInterface
}
