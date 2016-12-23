
include "database.iol"
include "console.iol"
include "file.iol"
include "string_utils.iol"
include "time.iol"

include "locations.iol"
include "dependencies.iol"

include "public/interfaces/CSVImportSurface.iol"
include "public/interfaces/GTFSCoreInterface.iol"

include "core_queries.iol"

execution{ concurrent }

constants {
	TIMESTAMP_BASE = "1/1/1970 ",
	BUNCH_SIZE = 1000,
	FILE_FOLDER = "./files/"
}

type GetDayMaskRequest: void {
		.day: int
		.month: int
		.year: int
}

type GetDayMaskResponse: void {
		.mask: string
}

outputPort DayMaskGenerator {
	RequestResponse:
		getDayMask( GetDayMaskRequest )( GetDayMaskResponse )
}

embedded {
	Java:
		"small.utilities.DayMaskGenerator" in DayMaskGenerator
}

inputPort GTFSCore {
	Location: GTFS_CORE
	Protocol: sodep
	Interfaces: GTFSCoreInterface
}

inputPort GTFSCoreAdmin {
	Location: GTFS_CORE_ADMIN
	Protocol: sodep
	Interfaces: GTFSCoreAdminInterface
}

define initDatabase
{
	scope( init_db ) {
	      install( SQLException => println@Console( init_db.SQLException.stackTrace )() );

				undef( q );
				q = "CREATE DATABASE " + DATABASE + " OWNER " + USERNAME;
				update@Database( q )();
				connectionInfo.database = DATABASE;

				connect@Database( connectionInfo )();

				undef( q );
	      i = 0;
	      q.statement[i++] = queries.create_agency_table;
	      q.statement[i++] = queries.create_stops_table;
        q.statement[i++] = queries.create_stops_time_table;
        q.statement[i++] = queries.create_trips_table;
        q.statement[i++] = queries.create_routes_table;
				q.statement[i++] = queries.create_calendar_date_table;
				q.statement[i++] = queries.create_calendar_table;
				q.statement[i++] = queries.create_shapes_table;

	      // portnumber is the actual number of the port used also as primary key
	      executeTransaction@Database( q )()
	}
}

define check_hour {
	// __time
	__day = 0;
	sbstr_r = __time;
	sbstr_r.begin = 0;
	sbstr_r.end = 2;
	substring@StringUtils( sbstr_r )( sbstr_rs );
	__hour = int( sbstr_rs );
	__day = __hour / 24;
	__hour = __hour % 24;
	if ( __day >= 1 ) {
		__day = 1;
		rep = __time;
		rep.regex = sbstr_rs;
		rep.replacement = string( __hour );
		replaceAll@StringUtils( rep )( __time )
	}
}

define refresh_agencies {
  import.filename = FILE_FOLDER + "agency.txt";
	importFile@CSVImport( import )( agency );
	scope( importing_agencies ) {
		  install( FileNotFound => nullProcess );
			for ( i = 0, i < #agency.line, i++ ) {
					undef( q );
					q = queries.insert_agency;
					q.agency_id = agency.line[i].agency_id;
					q.agency_name = agency.line[i].agency_name;
					q.agency_url = agency.line[i].agency_url;
					q.agency_timezone = agency.line[i].agency_timezone;
					q.agency_lang = agency.line[i].agency_lang;
					q.agency_phone = agency.line[i].agency_phone;
					q.agency_fare_url = agency.line[i].agency_fare_url;
					q.agency_email = agency.line[i].agency_email;
					update@Database( q )( result );
					println@Console( "inserted agency " + q.agency_name )()
			}
		}
}

define refresh_calendar_date{
	filename = FILE_FOLDER + "calendar_dates.txt";
	rq_line_number.filename = filename;
	scope( importing_calendar_date ) {
		  install( FileNotFound => nullProcess );
			getLines@CSVImport( rq_line_number )( rs_line_number );
			lines = rs_line_number.lines - 1; // skip the first lines with column labels

			for( i = 0, (i*BUNCH_SIZE) < lines, i++ ) {
				 println@Console( "inserting calendar date pckg " + i )();
				 import.fromLine = ( i * BUNCH_SIZE );
				 import.toLine = import.fromLine + BUNCH_SIZE - 1;
				 import.filename = filename;
				 importFileBunch@CSVImport( import )( calendar );
				 undef( q );
				 for( p_count = 0, p_count < #calendar.line, p_count++ ) {
						 q.statement[ p_count ] = queries.insert_calendar_date;
						 q.statement[ p_count ].service_id = calendar.line[ p_count ].service_id;
						 st = calendar.line[ p_count ].date;
						 st.length = 2;
						 splitByLength@StringUtils( st )( date_res );
						 q.statement[ p_count ].date.Date.year = date_res.result[ 0 ] + date_res.result[ 1 ];
						 q.statement[ p_count ].date.Date.month = date_res.result[ 2 ];
						 q.statement[ p_count ].date.Date.day = date_res.result[ 3 ];
						 q.statement[ p_count ].exception_type = int( calendar.line[ p_count ].exception_type )
				 }
				 ;
				 executeTransaction@Database( q )( result );
				 println@Console( "inserted calendar date pckg " + i )()
			 }
		}
}

define refresh_calendar {
	filename = FILE_FOLDER + "calendar.txt";
	rq_line_number.filename = filename;
	scope( importing_calendar ) {
		  install( FileNotFound => nullProcess );
			getLines@CSVImport( rq_line_number )( rs_line_number );
			lines = rs_line_number.lines - 1; // skip the first lines with column labels

			for( i = 0, (i*BUNCH_SIZE) < lines, i++ ) {
				 println@Console( "inserting calendar pckg " + i )();
				 import.fromLine = ( i * BUNCH_SIZE );
				 import.toLine = import.fromLine + BUNCH_SIZE - 1;
				 import.filename = filename;
				 importFileBunch@CSVImport( import )( calendar );
				 undef( q );
				 for( p_count = 0, p_count < #calendar.line, p_count++ ) {
						 q.statement[ p_count ] = queries.insert_calendar;
						 q.statement[ p_count ].service_id = calendar.line[ p_count ].service_id;
						 q.statement[ p_count ].days = string( calendar.line[ p_count ].monday )
																				 + string( calendar.line[ p_count ].tuesday )
						  												 	 + string( calendar.line[ p_count ].wednesday )
						 													 	 + string( calendar.line[ p_count ].thursday )
						  												 	 + string( calendar.line[ p_count ].friday )
						  												 	 + string( calendar.line[ p_count ].saturday )
						 													 	 + string( calendar.line[ p_count ].sunday );
						 st = calendar.line[ p_count ].start_date;
						 st.length = 2;
						 splitByLength@StringUtils( st )( date_res );
						 q.statement[ p_count ].start_date.Date.year = date_res.result[ 0 ] + date_res.result[ 1 ];
						 q.statement[ p_count ].start_date.Date.month = date_res.result[ 2 ];
						 q.statement[ p_count ].start_date.Date.day = date_res.result[ 3 ];
						 st = calendar.line[ p_count ].end_date;
						 st.length = 2;
						 splitByLength@StringUtils( st )( date_res );
						 q.statement[ p_count ].end_date.Date.year = date_res.result[ 0 ] + date_res.result[ 1 ];
						 q.statement[ p_count ].end_date.Date.month = date_res.result[ 2 ];
						 q.statement[ p_count ].end_date.Date.day = date_res.result[ 3 ]
				 }
				 ;
				 executeTransaction@Database( q )( result );
				 println@Console( "inserted calendar date pckg " + i )()
			 }
		}
}

define refresh_shapes {
	filename = FILE_FOLDER + "shapes.txt";
	rq_line_number.filename = filename;
	scope( importing_shapes ) {
		  install( FileNotFound => nullProcess );
			getLines@CSVImport( rq_line_number )( rs_line_number );
			lines = rs_line_number.lines - 1; // skip the first lines with column labels

			for( i = 0, (i*BUNCH_SIZE) < lines, i++ ) {
				 println@Console( "inserting shapes pckg " + i )();
				 import.fromLine = ( i * BUNCH_SIZE );
				 import.toLine = import.fromLine + BUNCH_SIZE - 1;
				 import.filename = filename;
				 importFileBunch@CSVImport( import )( shapes );
				 undef( q );
				 for( p_count = 0, p_count < #shapes.line, p_count++ ) {
						 q.statement[ p_count ] = queries.insert_shape;
						 q.statement[ p_count ].shape_id = shapes.line[ p_count ].shape_id;
						 q.statement[ p_count ].shape_pt_lat = double( shapes.line[ p_count ].shape_pt_lat );
						 q.statement[ p_count ].shape_pt_lon = double( shapes.line[ p_count ].shape_pt_lon );
						 q.statement[ p_count ].shape_pt_sequence = int( shapes.line[ p_count ].shape_pt_sequence );
						 if ( is_defined( shapes.line[ p_count ].shape_dist_traveled ) ) {
								 q.statement[ p_count ].shape_dist_traveled = double( shapes.line[ p_count ].shape_dist_traveled )
						 } else {
								 q.statement[ p_count ].shape_dist_traveled = 0.0
						 }
				 }
				 ;
				 executeTransaction@Database( q )( result );
				 println@Console( "inserted shapes pckg " + i )()
			 }
		}
}

define refresh_stops {
	filename = FILE_FOLDER + "stops.txt";
	rq_line_number.filename = filename;
	scope( importing_stops ) {
		  install( FileNotFound => nullProcess );
			getLines@CSVImport( rq_line_number )( rs_line_number );
			lines = rs_line_number.lines - 1; // skip the first lines with column labels

			for( i = 0, (i*BUNCH_SIZE) < lines, i++ ) {
				 println@Console( "inserting stops pckg " + i )();
				 import.fromLine = ( i * BUNCH_SIZE );
				 import.toLine = import.fromLine + BUNCH_SIZE - 1;
				 import.filename = filename;
				 importFileBunch@CSVImport( import )( stops );
				 undef( q );
				 for( p_count = 0, p_count < #stops.line, p_count++ ) {
						 q.statement[ p_count ] = queries.insert_stops;
						 q.statement[ p_count ].stop_id = stops.line[ p_count ].stop_id;
						 q.statement[ p_count ].stop_code = stops.line[ p_count ].stop_code;
						 q.statement[ p_count ].stop_name = stops.line[ p_count ].stop_name;
						 q.statement[ p_count ].stop_desc = stops.line[ p_count ].stop_desc;
						 q.statement[ p_count ].stop_lat = double(stops.line[ p_count ].stop_lat);
						 q.statement[ p_count ].stop_lon = double(stops.line[ p_count ].stop_lon);
						 q.statement[ p_count ].zone_id = stops.line[ p_count ].zone_id;
						 q.statement[ p_count ].stop_url = stops.line[ p_count ].stop_url;
						 if ( !is_defined( stops.line[ p_count ].location_type ) || stops.line[ p_count ].location_type == ""  ) {
								 q.statement[ p_count ].location_type = 0
						 } else {
								 q.statement[ p_count ].location_type = int( stops.line[ p_count ].location_type )
						 };
						 if ( !is_defined( stops.line[ p_count ].parent_station ) || stops.line[ p_count ].parent_station == "" ) {
								 q.statement[ p_count ].parent_station = 0
						 } else {
								 q.statement[ p_count ].parent_station = int( stops.line[ p_count ].parent_station )
						 };
						 q.statement[ p_count ].stop_timezone = stops.line[ p_count ].stop_timezone;
						 if ( !is_defined( stops.line[ p_count ].wheelchair_boarding ) || stops.line[ p_count ].wheelchair_boarding == "" ) {
								 q.statement[ p_count ].wheelchair_boarding = 0
						 } else {
								 q.statement[ p_count ].wheelchair_boarding = int( stops.line[ p_count ].wheelchair_boarding )
						 }
				 }
				 ;
				 executeTransaction@Database( q )( result );
				 println@Console( "inserted stops pckg " + i )()
			 }
		}
}

define refresh_trips {
	filename = FILE_FOLDER + "trips.txt";
	rq_line_number.filename = filename;
	scope( importing_trips ) {
		  install( FileNotFound => nullProcess );
			getLines@CSVImport( rq_line_number )( rs_line_number );
			lines = rs_line_number.lines - 1; // skip the first lines with column labels

			for( i = 0, (i*BUNCH_SIZE) < lines, i++ ) {
				 println@Console( "inserting trips pckg " + i )();
				 import.fromLine = ( i * BUNCH_SIZE );
				 import.toLine = import.fromLine + BUNCH_SIZE - 1;
				 import.filename = filename;
				 importFileBunch@CSVImport( import )( trips );
				 undef( q );
				 for( p_count = 0, p_count < #trips.line, p_count++ ) {
						 q.statement[ p_count ] = queries.insert_trips;
						 q.statement[ p_count ].route_id = trips.line[ p_count ].route_id;
						 q.statement[ p_count ].service_id = trips.line[ p_count ].service_id;
						 q.statement[ p_count ].trip_id = trips.line[ p_count ].trip_id;
						 q.statement[ p_count ].trip_headsign = trips.line[ p_count ].trip_headsign;
						 q.statement[ p_count ].trip_short_name = trips.line[ p_count ].trip_short_name;
						 q.statement[ p_count ].direction_id = int( trips.line[ p_count ].direction_id );
						 q.statement[ p_count ].block_id = trips.line[ p_count ].block_id;
						 q.statement[ p_count ].shape_id = trips.line[ p_count ].shape_id;
						 if ( !is_defined( trips.line[i].wheelchair_accessible ) || trips.line[ p_count ].wheelchair_accessible == ""  ) {
								 q.statement[ p_count ].wheelchair_accessible = 0
						 } else {
								 q.statement[ p_count ].wheelchair_accessible = int( trips.line[ p_count ].wheelchair_accessible )
						 };
						 if ( !is_defined( trips.line[i].bikes_allowed ) || trips.line[ p_count ].bikes_allowed == ""  ) {
								 q.statement[ p_count ].bikes_allowed = 0
						 } else {
								 q.statement[ p_count ].bikes_allowed = int( trips.line[ p_count ].bikes_allowed )
						 }
				 }
				 ;
				 executeTransaction@Database( q )( result );
				 println@Console( "inserted trips pckg " + i )()
	 	 	}
	 }
}

define refresh_stop_times {
	filename = FILE_FOLDER + "stop_times.txt";
	rq_line_number.filename = filename;
	scope( importing_stop_times ) {
		  install( FileNotFound => nullProcess );
			getLines@CSVImport( rq_line_number )( rs_line_number );
			lines = rs_line_number.lines - 1; // skip the first lines with column labels

			for( i = 0, (i*BUNCH_SIZE) < lines, i++ ) {
				 println@Console( "inserting stop_times pckg " + i )();
				 import.fromLine = ( i * BUNCH_SIZE );
				 import.toLine = import.fromLine + BUNCH_SIZE - 1;
				 import.filename = filename;
				 importFileBunch@CSVImport( import )( stops_times );
				 undef( q );
				 for( p_count = 0, p_count < #stops_times.line, p_count++ ) {
						 q.statement[ p_count ] = queries.insert_stop_times;
						 q.statement[ p_count ].trip_id = stops_times.line[ p_count ].trip_id;
						 __time = stops_times.line[ p_count ].arrival_time;
						 check_hour;

						 getTimestampFromString@Time( TIMESTAMP_BASE + stops_times.line[ p_count ].arrival_time )( __time );
						 q.statement[ p_count ].arrival_time.Timestamp.epoch = __time;
						 q.statement[ p_count ].arrival_day = __day;
						 __time = stops_times.line[ p_count ].departure_time;
						 check_hour;

						 getTimestampFromString@Time( TIMESTAMP_BASE + stops_times.line[ p_count ].departure_time )( __time );
						 q.statement[ p_count ].departure_time.Timestamp.epoch = __time;
						 q.statement[ p_count ].departure_day = __day;
						 q.statement[ p_count ].stop_id = stops_times.line[ p_count ].stop_id;
						 q.statement[ p_count ].stop_sequence = int( stops_times.line[ p_count ].stop_sequence );
						 q.statement[ p_count ].stop_headsign = stops_times.line[ p_count ].stop_headsign;
						 if ( !is_defined( stops.line[ p_count ].pickup_type ) || stops.line[ p_count ].pickup_type == ""  ) {
								 q.statement[ p_count ].pickup_type = 0
						 } else {
								 q.statement[ p_count ].pickup_type = int( stops.line[ p_count ].pickup_type )
						 };
						 if ( !is_defined( stops.line[i].drop_off_type ) || stops.line[ p_count ].drop_off_type == "" ) {
								 q.statement[ p_count ].drop_off_type = 0
						 } else {
								 q.statement[ p_count ].drop_off_type = int( stops.line[ p_count ].drop_off_type )
						 };
						 q.statement[ p_count ].shape_dist_traveled = stops.line[ p_count ].shape_dist_traveled;
						 q.statement[ p_count ].timepoint = stops.line[ p_count ].timepoint
				 }
				 ;
				 executeTransaction@Database( q )( result );
				 println@Console( "inserted stop_times pckg " + i )()
			 }
		}
}

define refresh_routes {
	import.filename = FILE_FOLDER + "routes.txt";
	scope( importing_routes ) {
		  install( FileNotFound => nullProcess );
			importFile@CSVImport( import )( routes );
			for ( i = 0, i < #routes.line, i++ ) {

					undef( q );
					q = queries.insert_routes;
					q.route_id = routes.line[i].route_id;
					q.agency_id = routes.line[i].agency_id;
					q.route_short_name = routes.line[i].route_short_name;
					q.route_long_name = routes.line[i].route_long_name;
					q.route_desc = routes.line[i].route_desc;
					q.route_type = int( routes.line[i].route_type );
					q.route_url = routes.line[i].route_url;
					q.route_color = routes.line[i].route_color;
					q.route_text_color = routes.line[i].route_text_color;

					update@Database( q )( result );
					println@Console( "inserted route " + q.route_short_name )()
			}
	 }
}

init {
  init_queries;
	HOST = JDEP_DB_HOST;
	DRIVER = "postgresql";
	PORT = int( JDEP_DB_PORT );
	DATABASE = JDEP_DB_DATABASE + "_gtfs";
	USERNAME = JDEP_DB_USERNAME;
	PASSWORD = JDEP_DB_PASSWORD;
  scope( ConnectionScope ) {
		    install( IOException => println@Console( ConnectionScope.IOException.stackTrace )() );
		    install( ConnectionError =>
                              			println@Console( "Database does not exist, creating a new database..." )();

																		connectionInfo.database = "postgres";
																		valueToPrettyString@StringUtils( connectionInfo )( s );
																		println@Console( s )();
                                    connect@Database( connectionInfo )();
                              			initDatabase;
                              			println@Console( "Database created" )()

		    );
    		with( connectionInfo ) {
        			.host = HOST;
        			.driver = DRIVER;
        			.port = PORT;
        			.database = DATABASE;
        			.username = USERNAME;
        			.password = PASSWORD;
							.toLowerCase = true
    		};
		    connect@Database( connectionInfo )()
  };
	println@Console("Database connected")();
	exists@File( "./files")( folder_file_exists );
	if ( !folder_file_exists ) {
		mkdir@File( "./files" )()
	}
}

main {

	[ getAgencies( request )( response ) {
			scope( sql ) {
					install( SQLException => println@Console( sql.SQLException.stackTrace )() );

					q = queries.select_agency;
					query@Database( q )( result );
					for( i = 0, i < #result.row, i++ ) {
							with( response.agency[ i ] ) {
								 .agency_id = result.row[ i ].agency_id;
					       .agency_name = result.row[ i ].agency_name;
					       .agency_url = result.row[ i ].agency_url;
					       .agency_timezone = result.row[ i ].agency_timezone;
					       .agency_lang = result.row[ i ].agency_lang;
					       .agency_phone = result.row[ i ].agency_phone;
					       .agency_fare_url = result.row[ i ].agency_fare_url;
					       .agency_email = result.row[ i ].agency_email
							}
					}
			}
	}]

	[ getAllShapesInATrip( request )( response ) {
			scope( sql ) {
					install( SQLException => println@Console( sql.SQLException.stackTrace )() );

					q = queries.select_shapes_by_trip;
					q.trip_id = request.trip_id;

					query@Database( q )( shapes )
					;
					for( i = 0, i < #shapes.row, i++ ) {
							 with( response.shapes[ i ] ) {
								 .shape_id = shapes.row[ i ].shape_id;
								 .shape_pt_lat = shapes.row[ i ].shape_pt_lat;
								 .shape_pt_lon = shapes.row[ i ].shape_pt_lon;
								 .shape_pt_sequence = shapes.row[ i ].shape_pt_sequence;
								 .shape_dist_traveled = shapes.row[ i ].shape_dist_traveled
							 }
					}
			 }
	}]

	[ getAllStopsInARoute( request )( response ) {
			scope( sql ) {
					install( SQLException => println@Console( sql.SQLException.stackTrace )() );

					q = queries.select_route_trips;
					q.route_id = request.route_id;
					q.direction_id = request.direction_id;
					query@Database( q )( trips );
					undef( q );
					if ( #trips.row > 0 ) {
							current_service = "";
							q_index = 0;
							for( i = 0, i < #trips.row, i++ ) {
										if ( current_service != trips.row[ i ].service_id ) {
												current_service = trips.row[ i ].service_id;
												services[ q_index ] = current_service;
												q.statement[ q_index ] = queries.select_stops_in_a_trip;
												q.statement[ q_index ].trip_id = trips.row[ i ].trip_id;
												q_index++
										}
							};
							executeTransaction@Database( q )( stops )
							// select the result which contains more stops
							;
							for( i = 0, i < #stops.result, i++ ) {
								with( response.service[ i ] ) {
									 .id = services[ i ];
									 for( st = 0, st < #stops.result[ i ].row, st++ ) {
										 		with( .stops[ st ] ) {
														 .stop_timezone = stops.result[ i ].row[ st ].stop_timezone;
														 .stop_lon = stops.result[ i ].row[ st ].stop_lon;
														 .stop_id = stops.result[ i ].row[ st ].stop_id;
														 .zone_id = stops.result[ i ].row[ st ].zone_id;
														 .parent_station = stops.result[ i ].row[ st ].parent_station;
														 .wheelchair_boarding = stops.result[ i ].row[ st ].wheelchair_boarding;
														 .stop_name = stops.result[ i ].row[ st ].stop_name;
														 .stop_lat = stops.result[ i ].row[ st ].stop_lat;
														 .location_type = stops.result[ i ].row[ st ].location_type;
														 .stop_desc = stops.result[ i ].row[ st ].stop_desc;
														 .stop_code = stops.result[ i ].row[ st ].stop_code;
														 .stop_url = stops.result[ i ].row[ st ].stop_url
												}
									 }
								}
							}
					}
			}
	}]

	[ getNextTrips( request )( response ) {
			scope( sql ) {
					install( SQLException => println@Console( sql.SQLException.stackTrace )() );

					q = queries.select_next_trips;
					q.start_stop_id = request.start_stop_id;
					q.route_id = request.route_id;
					q.direction_id = request.direction_id;
					getTimestampFromString@Time( TIMESTAMP_BASE + request.time.hour + ":" + request.time.minute + ":" + request.time.second )( __time );
					q.departure_time.Timestamp.epoch = __time;
					q.date.Date.year = mask_request.year = request.date.year;
					q.date.Date.month = mask_request.month = request.date.month;
					q.date.Date.day = mask_request.day = request.date.day;
					getDayMask@DayMaskGenerator( mask_request )( mask_response );
					q.days = mask_response.mask;
					query@Database( q )( result );

					if ( #result.row > 0 ) {
							trip_count = 0;
							trip_index = 0;
							while( trip_count < request.max_trips && trip_index < #result.row ) {
									undef( q );
									continue = true;
									if ( result.row[ trip_index ].days == mask_response.mask ) {
										 /* in this case the service is available in the day of the week
										    we must verify if there is a negative exception (2) in the calendar_date */
												if ( result.row[ trip_index ].exception_type == 2 ) {
														continue = false
												}
									} else {
										/* in this case the service is not available but we need to verify if
										   there is a positive exception (1) on the calendar_date */
											 if ( result.row[ trip_index ].exception_type != 1 ) {
													 continue = false
											 }
									}
									;
									if ( continue ) {
											q = queries.select_trip_if_stop_exists;
											q.trip_id = result.row[ trip_index ].trip_id;
											q.stop_id = request.end_stop_id;
											query@Database( q )( r );
											if ( #r.row > 0 ) {
													// the trip is a good trip
													undef( q );
													q = queries.select_trip_stops;
													q.trip_id = result.row[ trip_index ].trip_id;
													query@Database( q )( result_stops );
													with( response.trips[ trip_count ] ) {
															.trip_id = result.row[ trip_index ].trip_id;
															.service_id = result.row[ trip_index ].service_id;
															for( st = 0, st < #result_stops.row, st++ ) {
																	with( .stops[ st ] ) {
																			.stop_id = result_stops.row[ st ].stop_id;
																			.stop_name = result_stops.row[ st ].stop_name;
																			.departure_time = result_stops.row[ st ].departure_time;
																			.stop_lon = result_stops.row[ st ].stop_lon;
																			.stop_lat = result_stops.row[ st ].stop_lat
																	}
															}
													};
													trip_count++
											}
									};
									trip_index++
							}
					}
			}
	}]

	[ getRoutes( request )( response ) {
			scope( sql ) {
						install( SQLException => println@Console( sql.SQLException.stackTrace )() );

						q = queries.select_routes;
						query@Database( q )( result );
						for( i = 0, i < #result.row, i++ ) {
								with( response.routes[ i ] ) {
									.route_id = result.row[ i ].route_id;
									.agency_id = result.row[ i ].agency_id;
									.route_short_name = result.row[ i ].route_short_name;
									.route_long_name = result.row[ i ].route_long_name;
									.route_desc = result.row[ i ].route_desc;
									.route_type = result.row[ i ].route_type;
									.route_url = result.row[ i ].route_url;
									.route_color = result.row[ i ].route_color;
									.route_text_color = result.row[ i ].route_text_color
								}
						}
			}
	}]

	[ getRoutesByAgency( request )( response ) {
			scope( sql ) {
						install( SQLException => println@Console( sql.SQLException.stackTrace )() );

						q = queries.select_routes_by_agency;
						q.agency_id = request.agency_id;
						query@Database( q )( result );
						for( i = 0, i < #result.row, i++ ) {
								with( response.routes[ i ] ) {
									.route_id = result.row[ i ].route_id;
									.agency_id = result.row[ i ].agency_id;
									.route_short_name = result.row[ i ].route_short_name;
									.route_long_name = result.row[ i ].route_long_name;
									.route_desc = result.row[ i ].route_desc;
									.route_type = result.row[ i ].route_type;
									.route_url = result.row[ i ].route_url;
									.route_color = result.row[ i ].route_color;
									.route_text_color = result.row[ i ].route_text_color
								}
						}
			}
	}]

	[ getRoutesFromStop( request )( response ) {
			scope( sql ) {
				install( SQLException => println@Console( sql.SQLException.stackTrace )() );
				q = queries.select_routes_from_stop;
				q.stop_id = request.stop_id;
				query@Database( q )( result );

				for( i = 0, i < #result.row, i++ ) {
					with( response.routes[ i ].info ) {
						.route_id = result.row[i].route_id;
						.agency_id = result.row[i].agency_id;
						.route_short_name = result.row[i].route_short_name;
						.route_long_name = result.row[i].route_long_name;
						.route_desc = result.row[i].route_desc;
						.route_type = result.row[i].route_type;
						.route_url = result.row[i].route_url;
						.route_color = result.row[i].route_color;
						.route_text_color = result.row[i].route_text_color
					};
					response.routes[ i ].direction_id = result.row[i].direction_id
				}
			}
	}]

	[ getStops( request )( response ) {
			scope( sql ) {
				install( SQLException => println@Console( sql.SQLException.stackTrace )() );
				q = queries.select_stops;
				query@Database( q )( result );
				for( i = 0, i < #result.row, i++ ) {
					with( response.stops[ i ] ) {
						 .stop_timezone = result.row[i].stop_timezone;
						 .stop_lon = result.row[i].stop_lon;
						 .stop_id = result.row[i].stop_id;
						 .zone_id = result.row[i].zone_id;
						 .parent_station = result.row[i].parent_station;
						 .wheelchair_boarding = result.row[i].wheelchair_boarding;
						 .stop_name = result.row[i].stop_name;
						 .stop_lat = result.row[i].stop_lat;
						 .location_type = result.row[i].location_type;
						 .stop_desc = result.row[i].stop_desc;
						 .stop_code = result.row[i].stop_code;
						 .stop_url = result.row[i].stop_url
					}
				}
			}
	}]

	[ getStopsByAgency( request )( response ) {
			scope( sql ) {
				install( SQLException => println@Console( sql.SQLException.stackTrace )() );
				q = queries.select_stops_by_agency;
				q.agency_id = request.agency_id;
				query@Database( q )( result );
				for( i = 0, i < #result.row, i++ ) {
					with( response.stops[ i ] ) {
						 .stop_timezone = result.row[i].stop_timezone;
						 .stop_lon = result.row[i].stop_lon;
						 .stop_id = result.row[i].stop_id;
						 .zone_id = result.row[i].zone_id;
						 .parent_station = result.row[i].parent_station;
						 .wheelchair_boarding = result.row[i].wheelchair_boarding;
						 .stop_name = result.row[i].stop_name;
						 .stop_lat = result.row[i].stop_lat;
						 .location_type = result.row[i].location_type;
						 .stop_desc = result.row[i].stop_desc;
						 .stop_code = result.row[i].stop_code;
						 .stop_url = result.row[i].stop_url
					}
				}
			}
	}]

  [ getStopsInArea ( request )( response ) {
			scope( sql ) {

				install( SQLException => println@Console( sql.SQLException.stackTrace )() );

				q = queries.select_stops_in_area;
				q.stop_lon = request.stop_lon;
				q.stop_lat = request.stop_lat;
				q.radius = request.radius;
				query@Database( q )( result );

				for( i = 0, i < #result.row, i++ ) {
					with( response.stops[ i ].info ) {
						 .stop_timezone = result.row[i].stop_timezone;
						 .stop_lon = result.row[i].stop_lon;
						 .stop_id = result.row[i].stop_id;
						 .zone_id = result.row[i].zone_id;
						 .parent_station = result.row[i].parent_station;
						 .wheelchair_boarding = result.row[i].wheelchair_boarding;
						 .stop_name = result.row[i].stop_name;
						 .stop_lat = result.row[i].stop_lat;
						 .location_type = result.row[i].location_type;
						 .stop_desc = result.row[i].stop_desc;
						 .stop_code = result.row[i].stop_code;
						 .stop_url = result.row[i].stop_url
					};
					response.stops[ i ].distance = result.row[i].dist
				}
			}
	}]

  [ getStopTimes( request )( response ) {
		scope( sql ) {
				install( SQLException => println@Console( sql.SQLException.stackTrace )() );

				q = queries.select_stop_times_by_stop_and_route;
				q.date.Date.year = mask_request.year = request.date.year;
				q.date.Date.month = mask_request.month = request.date.month;
				q.date.Date.day = mask_request.day = request.date.day;
				getDayMask@DayMaskGenerator( mask_request )( mask_response );
				q.days = mask_response.mask;
				q.stop_id = request.stop_id;
				q.route_id = request.route_id;
				q.direction_id = request.direction_id;
				query@Database( q )( result );

				for( i = 0, i < #result.row, i++ ) {
						response.departure_time[ i ] = result.row[ i ].departure_time
				}
		}
	}]

	[ getTrip( request )( response ){
			scope( sql ) {
					install( SQLException => println@Console( sql.SQLException.stackTrace )() );

					q = queries.select_trips_by_id;
					q.trip_id = request.trip_id;
					query@Database( q )( result );

					if( #result.row > 0 ) {
						response.id = result.row[ 0 ].trip_id;
						response.direction_id = result.row[ 0 ].direction_id;
						response.route_id = result.row[ 0 ].route_id;
						response.service_id = result.row[ 0 ].service_id;
						for( i = 0, i < #result.row, i++ ) {
								with( response.stops[ i ] ) {
										.stop_id = result.row[ i ].stop_id;
										.stop_name = result.row[ i ].stop_name;
										.stop_lon = result.row[ i ].stop_lon;
										.stop_lat = result.row[ i ].stop_lat;
										.stop_sequence = result.row[ i ].stop_sequence;
										.departure_time = result.row[ i ].departure_time
								}
						}
					} else {
							throw( TripNotFound )
					}
			}
	}]

	[ getTrips( request )( response ){
			scope( sql ) {
					install( SQLException => println@Console( sql.SQLException.stackTrace )() );

					q = queries.select_trips_by_route;
					q.route_id = request.route_id;
					q.direction_id = request.direction_id;
					q.date.Date.year = request.date.year;
					q.date.Date.month = request.date.month;
					q.date.Date.day = request.date.day;
					query@Database( q )( result );

					if( #result.row > 0 ) {
						current_trip = result.row[ 0 ].trip_id;
						trip_index = 0;
						stop_index = 0;
						response.trips[ trip_index ].id = current_trip;
						for( i = 0, i < #result.row, i++ ) {
								if ( current_trip != result.row[ i ].trip_id ) {
										current_trip = result.row[ i ].trip_id;
										trip_index++;
										stop_index = 0;
										response.trips[ trip_index ].id = current_trip
								};
								with( response.trips[ trip_index ].stops[ stop_index ] ) {
										.stop_id = result.row[ i ].stop_id;
										.stop_name = result.row[ i ].stop_name;
										.stop_lon = result.row[ i ].stop_lon;
										.stop_lat = result.row[ i ].stop_lat;
										.stop_sequence = result.row[ i ].stop_sequence;
										.departure_time = result.row[ i ].departure_time
								};
								stop_index++
						}
					}
			}
	}]

	/* admin */

	[ getGTFSFileInfo( request )( response ) {
		rq.directory = "./files";
		rq.regex = ".*\\.txt";
		rq.info = true;
		list@File( rq )( rs );
		response.file -> rs.result
	}]

	[ refreshAgencies( request )( response ) {
		scope( sql ) {
			install( SQLException => println@Console( sql.SQLException.stackTrace )() );

			q = queries.drop_agency_table;
			update@Database( q )( result );
			q = queries.create_agency_table;
			update@Database( q )( result );
			with( import ) {
				.separator = ",";
				.verbose = true
			};
			refresh_agencies

		}
	}]

	[ refreshCalendar( request )( response ) {
			scope( sql ) {
				install( SQLException => nullProcess );

				q = queries.drop_calendar_table;
				update@Database( q )( result )
			};
			scope( sql ) {
				install( SQLException => println@Console( sql.SQLException.stackTrace )() );
				q = queries.create_calendar_table;
				update@Database( q )( result )
			};
			with( import ) {
				.separator = ",";
				.verbose = true
			};
			refresh_calendar
	}]

	[ refreshCalendarDate( request )( response ) {
			scope( sql ) {
				install( SQLException => nullProcess );

				q = queries.drop_calendar_date_table;
				update@Database( q )( result )
			};
			scope( sql ) {
				install( SQLException => println@Console( sql.SQLException.stackTrace )() );
				q = queries.create_calendar_date_table;
				update@Database( q )( result )
			};
			with( import ) {
				.separator = ",";
				.verbose = true
			};
			refresh_calendar_date
	}]

	[ refreshShapes( request )( response ) {
			scope( sql ) {
				install( SQLException => println@Console( sql.SQLException.stackTrace )() );

				scope( sql ) {
					install( SQLException => nullProcess );

					q = queries.drop_shapes_table;
					update@Database( q )( result )
				};
				q = queries.create_shapes_table;
				update@Database( q )( result );
				with( import ) {
					.separator = ",";
					.verbose = true
				};
				refresh_shapes

			}
	}]

	[ refreshTrips( request )( response ) {
			scope( sql ) {
				install( SQLException => println@Console( sql.SQLException.stackTrace )() );

				q = queries.drop_trips_table;
				update@Database( q )( result );
				q = queries.create_trips_table;
				update@Database( q )( result );
				with( import ) {
					.separator = ",";
					.verbose = true
				};
				refresh_trips

			}
	}]

	[ refreshRoutes( request )( response ) {
		scope( sql ) {
			install( SQLException => println@Console( sql.SQLException.stackTrace )() );

			q = queries.drop_routes_table;
			update@Database( q )( result );
			q = queries.create_routes_table;
			update@Database( q )( result );
			with( import ) {
				.separator = ",";
				.verbose = true
			};
			refresh_routes

		}
	}]

	[ refreshStops( request )( response ) {
		scope( sql ) {
			install( SQLException => println@Console( sql.SQLException.stackTrace )() );

			q = queries.drop_stops_table;
			update@Database( q )( result );
			q = queries.create_stops_table;
			update@Database( q )( result );
			with( import ) {
				.separator = ",";
				.verbose = true
			};
			refresh_stops

		}
	}]

	[ refreshStopTimes( request )( response ) {
		scope( sql ) {
			install( SQLException => println@Console( sql.SQLException.stackTrace )() );

			q = queries.drop_stop_times_table;
			update@Database( q )( result );
			q = queries.create_stops_time_table;
			update@Database( q )( result );
			with( import ) {
				.separator = ",";
				.verbose = true
			};
			refresh_stop_times

		}
	}]

	[ uploadGTFSFile( request )( response ) {
			if (  (request.filename != "agency.txt")
					&&(request.filename != "calendar_dates.txt")
					&&(request.filename != "calendar.txt")
					&&(request.filename != "routes.txt")
					&&(request.filename != "shapes.txt")
					&&(request.filename != "stop_times.txt")
					&&(request.filename != "stops.txt")
					&&(request.filename != "trips.txt")
			) {
				throw( FileNotPermitted )
			} else {
					delete@File( FILE_FOLDER + request.filename )();
					f.filename = FILE_FOLDER + request.filename;
					f.content -> request.content;
					f.format = "binary";
					writeFile@File( f )()
			}
		}
	]



}
