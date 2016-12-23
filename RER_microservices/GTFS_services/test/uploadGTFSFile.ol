include "console.iol"
include "string_utils.iol"
include "file.iol"
include "head_core.iol"
include "zip_utils.iol"

main {
  exists@File( "./tmp" )( tmp_dir_exists );
  if ( !tmp_dir_exists ) {
    println@Console( "tmp file does not exist")();
    exit
  }
  ;
  rq.directory = "./tmp";
  rq.regex = ".*\\.txt";
  list@File( rq )( rs );
  for( i = 0, i < #rs.result, i++ ) {
      undef( file );
      file.filename = "./tmp/" + rs.result[ i ];
      file.format = "binary";
      readFile@File( file )( file.content );
      undef( file.format );
      file.filename = rs.result[ i ];
      println@Console( "Uploading file " + file.filename )();
      uploadGTFSFile@GTFSAdmin( file )();
      println@Console( "Uploaded file " + file.filename )()
  };
  println@Console("---------------------------------------")();
  println@Console("Files on server")();
  println@Console("")();
  getGTFSFileInfo@GTFSAdmin( request )( result );
  valueToPrettyString@StringUtils( result )( s );
  println@Console( s )()

}
