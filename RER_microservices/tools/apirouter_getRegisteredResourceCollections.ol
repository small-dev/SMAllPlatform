
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
  if ( args[0] == "--help" || args[0] == "--h" || #args != 2 ) {
      println@Console( "Usage:" )();
      println@Console( "jolie apirouter_getRegisteredResourceCollection.ol TARGET_HOST TARGET_PORT" )();
      println@Console( "This tool allows for the upload of a GTFS file set to a gtfs_core based microservice")();
      println@Console( "TARGET_HOST is the host where the microservice is running")();
      println@Console( "TARGET_PORT is the port where the microservice admin inputPort is listening")()
  } else {
      TARGET_HOST = args[ 0 ];
      TARGET_PORT = args[ 1 ];
      RouterAdmin.location = "socket://" + TARGET_HOST + ":" + TARGET_PORT;
      getRegisteredResourceCollections@RouterAdmin(  )( res );
      valueToPrettyString@StringUtils( res )( s );
      println@Console( s )()
  }
}
