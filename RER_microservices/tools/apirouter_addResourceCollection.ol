/*
The MIT License (MIT)
Copyright (c) 2016 Claudio Guidi <guidiclaudio@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
include "console.iol"
include "string_utils.iol"
include "file.iol"
include "./public/interfaces/RouterAdminInterface.iol"

outputPort RouterAdmin {
  Protocol: sodep
  Interfaces: RouterAdminInterface
}

main {
  if ( args[0] == "--help" || args[0] == "--h" || #args != 6 ) {
      println@Console( "Usage:" )();
      println@Console( "jolie apirouter_addResourceCollection.ol TARGET_HOST TARGET_PORT NAME LOCATION INTERFACE_NAME INTERFACE_FILE" )();
      println@Console( "This tool allows for the upload of a GTFS file set to a gtfs_core based microservice")();
      println@Console( "TARGET_HOST is the host where the microservice is running")();
      println@Console( "TARGET_PORT is the port where the microservice admin inputPort is listening")();
      println@Console( "NAME is the name of the collection")();
      println@Console( "LOCATION is the target location of the service" )();
      println@Console( "INTERFACE_NAME the name of the interface")();
      println@Console( "INTERFACE_FILE is the path where the interface of the microservice is retrieved")()
  } else {
      TARGET_HOST = args[ 0 ];
      TARGET_PORT = args[ 1 ];
      NAME = args[ 2 ];
      LOCATION = args[ 3 ];
      INTERFACE_NAME = args[ 4 ];
      INTERFACE_FILE = args[ 5 ];
      RouterAdmin.location = "socket://" + TARGET_HOST + ":" + TARGET_PORT;
      with( rq ) {
          .name = NAME;
          .location = LOCATION;
          .interface_name = INTERFACE_NAME
      };
      readFile@File( { .filename=INTERFACE_FILE })( rq.interface );
      install( DefinitionError => println@Console("ERROR:" + main.DefinitionError )());
      addResourceCollection@RouterAdmin( rq )()
  }
}
