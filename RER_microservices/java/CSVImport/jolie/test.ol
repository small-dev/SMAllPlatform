include "CSVImportSurface.iol"
include "console.iol"
include "string_utils.iol"

main {
  rq.fromLine = 0;
  rq.toLine = 1000 ;
  rq.separator = ",";
  rq.filename = "trips.txt";
  rq.verbose = false;
  importFileBunch@CSVImport( rq )( rs );
  valueToPrettyString@StringUtils( rs )( s );
  println@Console( s )();
undef( rq );

   request.filename = "trips.txt";
   getLines@CSVImport( request )( response );
   println@Console( response.lines )();
   lines = response.lines - 1;

   rq.separator = ",";
   rq.filename = "trips.txt";
   rq.verbose = false;
   importFile@CSVImport( rq )( all );

   undef( rq );
   bunch = 1000;
   for( i = 0, (i*bunch) < lines, i++ ) {
      rq.fromLine = ( i * bunch );
      rq.toLine = rq.fromLine + bunch - 1;
      rq.separator = ",";
      rq.filename = "trips.txt";
      rq.verbose = false;
      importFileBunch@CSVImport( rq )( rs );
      for( x = 0, x < #rs.line, x++ ) {
          bunch.line[ #bunch.line ] << rs.line[ x ]
      }
   }
   ;
   rq.fromLine = ( i * bunch );
   rq.toLine = response.lines ;
   rq.separator = ",";
   rq.filename = "trips.txt";
   rq.verbose = false;
   importFileBunch@CSVImport( rq )( rs );
   for( x = 0, x < #rs.line, x++ ) {
       bunch.line[ #bunch.line ] << rs.line[ x ]
   }
   ;
   for( x = 0, x < #all.line, x++ ) {
      println@Console( "checking line " + x + "...")();
      foreach( f : all.line[ x ]) {
           println@Console( "checking field " + f )();
           if( all.line[ x ].( f ) != bunch.line[ x ].( f ) ) {
                 println@Console( "ERROR. field " + f + ", expected value " + all.line[ x ].( f ) + ", found " + bunch.line[ x ].( f ) )();
                 exit
           }
           ;
           println@Console( "OK" )()
      }
      ;
      println@Console("LINE OK")()
   }

}
