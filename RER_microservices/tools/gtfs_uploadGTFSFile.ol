include "console.iol"
include "string_utils.iol"
include "file.iol"

include "public/interfaces/GtfsCoreSurface.iol"

main {
  if ( args[0] == "--help" || args[0] == "--h" || #args != 3 ) {
      println@Console( "Usage:" )();
      println@Console( "jolie gtfs_uploadGTFSFile.ol TARGET_HOST TARGET_PORT SOURCEFOLDER" )();
      println@Console( "This tool allows for the upload of a GTFS file set to a gtfs_core based microservice")();
      println@Console( "TARGET_HOST is the host where the microservice is running")();
      println@Console( "TARGET_PORT is the port where the microservice admin inputPort is listening")();
      println@Console( "SOURCE_FOLDER is the folder where the file are stored. They must be in txt format")()
  } else {
    TARGET_HOST = args[ 0 ];
    TARGET_PORT = args[ 1 ];
    SOURCE_FOLDER = args[ 2 ];

    exists@File( SOURCE_FOLDER )( dir_exists );
    if ( !dir_exists ) {
      println@Console( SOURCE_FOLDER + " does not exist, exiting...")();
      exit
    }
    ;
    GTFSAdmin.location = "socket://" + TARGET_HOST + ":" + TARGET_PORT;
    rq.directory = SOURCE_FOLDER;
    rq.regex = ".*\\.txt";
    list@File( rq )( rs );
    for( i = 0, i < #rs.result, i++ ) {
        undef( file );
        file.filename = SOURCE_FOLDER + rs.result[ i ];
        file.format = "binary";
        readFile@File( file )( file.content );
        undef( file.format );
        file.filename = rs.result[ i ];
        println@Console( "Uploading file " + file.filename )();
        uploadGTFSFile@GTFSAdmin( file )();
        println@Console( "Uploaded file " + file.filename )()
    };
    println@Console("done.")();
    println@Console("Files on server")()
  }
}
