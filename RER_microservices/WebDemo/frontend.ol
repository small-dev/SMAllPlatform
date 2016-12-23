include "file.iol"
include "console.iol"
include "string_utils.iol"

include "public/interfaces/GTFSCoreInterface.iol"
include "public/interfaces/BusCheckInterface.iol"
include "public/interfaces/FrontendInterface.iol"

include "locations.iol"
include "dependencies.iol"


execution{ concurrent }

type CityNameType: void {
    .registry_name:string
}

interface extender CityNameInterfaceExtender {
	RequestResponse:
	    *(CityNameType)( void )
}

outputPort BusCheck {
  Location: JDEP_BUS_CHECK
  Protocol: sodep
  Interfaces: BusCheckInterface
}

outputPort GTFS {
  Protocol: sodep
  Interfaces: GTFSCoreInterface
}

inputPort Frontend {
  Location: "local"
  Protocol: sodep
  Interfaces: FrontendInterface
  Aggregates: GTFS with CityNameInterfaceExtender, BusCheck
}

inputPort FrontendTest {
  Location: WEBDEMO_ADMIN
  Protocol: sodep
  Interfaces: FrontendInterface
}

courier Frontend {
	[ interface GTFSCoreInterface( request )( response ) ] {
        GTFS.location = global.registry.( request.registry_name ).location;
        forward( request )( response )
  }
}

constants {
  REGISTRY_FILE = "registry.xml"
}

define __write_file_registry {
  file.filename = REGISTRY_FILE;
  file.format = "xml_store";
  foreach( item : global.registry ) {
      index = #file.content.registry.item;
      with( file.content.registry.item[ index ] ) {
        .name = item;
        .city = global.registry.( item ).city;
        .location = global.registry.( item ).location
      }
  };
  writeFile@File( file )()
}

init {
  exists@File( REGISTRY_FILE )( exists_registry );
  file.filename = REGISTRY_FILE;
  file.format = "xml_store";
  if ( !exists_registry ) {
      file.content.registry = "";
      writeFile@File( file )();
      println@Console( "Registry file does not exist, created." )()
  } else {
      readFile@File( file )( registry_read );
      for ( i = 0, i < #registry_read.registry.item, i++ ) {
          with ( global.registry.( registry_read.registry.item[ i ].name ) ) {
              .city = registry_read.registry.item[ i ].city;
              .location = registry_read.registry.item[ i ].location
          }
      }
  }
}

main {

    [ addRegistryItem( request )( response ) {
        if ( is_defined( global.registry.( request.name ))) {
          throw( NameAlreadyExists )
        } else {
          synchronized( write_registry ) {
              with( global.registry.( request.name ) ) {
                .city = request.city;
                .location = request.location
              }
              ;
              __write_file_registry
          }
        }
    }]

    [ removeRegistryItem( request )( response ) {
        synchronized( write_registry ) {
          undef( global.registry.( request.name ) );
          __write_file_registry
        }
    }]

    [ getRegistryItems( request )( response ) {
        foreach( item : global.registry ) {
            index = #response.item;
            with( response.item[ index ] ) {
              .name = item;
              .city = global.registry.( item ).city;
              .location = global.registry.( item ).location
            }
        }
    }]
}
