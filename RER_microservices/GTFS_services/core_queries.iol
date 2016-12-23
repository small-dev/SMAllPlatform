define init_queries {
  with( queries ) {
    .create_agency_table = "create table agency (
      agency_id varchar(128),
      agency_name varchar(128) not null,
      agency_url varchar(128) not null,
      agency_timezone varchar(128) not null,
      agency_lang varchar(128),
      agency_phone varchar(128),
      agency_fare_url varchar(128),
      agency_email varchar(128)
    )";

    .create_stops_table = "create table stops (
      stop_id varchar(128) not null,
      stop_code varchar(128) not null,
      stop_name varchar(128) not null,
      stop_desc varchar(128),
      stop_lat real,
      stop_lon real,
      zone_id varchar(128),
      stop_url varchar(128),
      location_type integer,
      parent_station integer,
      stop_timezone varchar(128),
      wheelchair_boarding integer
    )";

    .create_stops_time_table = "create table stop_times (
      trip_id varchar(128) not null,
      arrival_time time,
      arrival_day integer,
      departure_time time,
      departure_day integer,
      stop_id varchar(128),
      stop_sequence integer,
      stop_headsign varchar(128),
      pickup_type integer,
      drop_off_type integer,
      shape_dist_traveled varchar(128),
      timepoint varchar(128)
    )";

    .create_trips_table = "create table trips (
      route_id varchar(128) not null,
      service_id varchar(128) not null,
      trip_id varchar(128) not null,
      trip_headsign varchar(128),
      trip_short_name varchar(128),
      direction_id integer,
      block_id varchar(128),
      shape_id varchar(128),
      wheelchair_accessible integer,
      bikes_allowed integer
    )";

    .create_shapes_table = "create table shapes (
      shape_id varchar(128) not null,
      shape_pt_lat real not null,
      shape_pt_lon real not null,
      shape_pt_sequence integer not null,
      shape_dist_traveled real
    )";


    .create_routes_table = "create table routes (
      route_id varchar(128) not null,
      agency_id varchar(128),
      route_short_name varchar(128) not null,
      route_long_name varchar(255) not null,
      route_desc varchar(255),
      route_type integer,
      route_url varchar(128),
      route_color varchar(128),
      route_text_color varchar(128)
    )";

    .create_calendar_date_table = "create table calendar_date (
      service_id varchar(128) not null,
      date date not null,
      exception_type integer
    )";

    .create_calendar_table = "create table calendar (
      service_id varchar(128) not null,
      days varchar(7),
      start_date date not null,
      end_date date not null
    )";

    .drop_agency_table = "DROP TABLE agency";
    .drop_shapes_table = "DROP TABLE shapes";
    .drop_stops_table = "DROP TABLE stops";
    .drop_stop_times_table = "DROP TABLE stop_times";
    .drop_trips_table = "DROP TABLE trips";
    .drop_calendar_date_table = "DROP TABLE calendar_date";
    .drop_calendar_table = "DROP TABLE calendar";
    .drop_routes_table = "DROP TABLE routes";

    .insert_agency = "INSERT INTO agency (agency_id,agency_name,agency_url,agency_timezone,agency_lang,agency_phone,agency_fare_url,agency_email) VALUES (:agency_id,:agency_name,:agency_url,:agency_timezone,:agency_lang,:agency_phone,:agency_fare_url,:agency_email)";
    .insert_calendar_date = "INSERT INTO calendar_date (service_id,date,exception_type) VALUES  ( :service_id, :date, :exception_type)";
    .insert_calendar = "INSERT INTO calendar ( service_id, days, start_date, end_date )
                        VALUES  ( :service_id, :days, :start_date, :end_date )";
    .insert_stops = "INSERT INTO stops (stop_id,stop_code,stop_name,stop_desc,stop_lat,stop_lon,zone_id,stop_url,location_type,parent_station,stop_timezone,wheelchair_boarding) VALUES (:stop_id,:stop_code,:stop_name,:stop_desc,:stop_lat,:stop_lon,:zone_id,:stop_url,:location_type,:parent_station,:stop_timezone,:wheelchair_boarding)";
    .insert_stop_times = "INSERT INTO stop_times (trip_id,arrival_time,arrival_day,departure_time,departure_day,stop_id,stop_sequence,stop_headsign,pickup_type,drop_off_type,shape_dist_traveled,timepoint) VALUES (:trip_id,:arrival_time,:arrival_day,:departure_time,:departure_day,:stop_id,:stop_sequence,:stop_headsign,:pickup_type,:drop_off_type,:shape_dist_traveled,:timepoint)";
    .insert_trips = "INSERT INTO trips (route_id,service_id,trip_id,trip_headsign,trip_short_name,direction_id,block_id,shape_id,wheelchair_accessible,bikes_allowed) VALUES (:route_id,:service_id,:trip_id,:trip_headsign,:trip_short_name,:direction_id,:block_id,:shape_id,:wheelchair_accessible,:bikes_allowed)";
    .insert_routes = "INSERT INTO routes (route_id,agency_id,route_short_name,route_long_name,route_desc,route_type,route_url,route_color,route_text_color) VALUES (:route_id,:agency_id,:route_short_name,:route_long_name,:route_desc,:route_type,:route_url,:route_color,:route_text_color)";
    .insert_shape = "INSERT INTO shapes (shape_id, shape_pt_lat, shape_pt_lon, shape_pt_sequence, shape_dist_traveled ) VALUES (:shape_id, :shape_pt_lat, :shape_pt_lon, :shape_pt_sequence, :shape_dist_traveled )";

    .select_agency = "SELECT agency_id,agency_name,agency_url,agency_timezone,agency_lang,agency_phone,agency_fare_url,agency_email FROM agency";
    .select_next_trips = "SELECT ST.trip_id, ST.stop_id, T.service_id, cast( (cast( CAL.days as bit(7) ) & cast( :days as bit(7) ) ) as varchar ) AS days, CD.exception_type, ST.departure_time from stop_times AS ST
                              	INNER JOIN trips AS T ON T.trip_id = ST.trip_id
                                LEFT JOIN calendar AS CAL ON CAL.service_id=T.service_id AND CAL.start_date <= :date AND CAL.end_date >= :date
                              	LEFT JOIN calendar_date AS CD ON CD.service_id=T.service_id AND CD.date=:date
                              	WHERE T.route_id=:route_id AND T.direction_id=:direction_id AND ST.stop_id=:start_stop_id AND ST.departure_time >= :departure_time
                              	ORDER BY departure_time";
    .select_stops = "SELECT stop_id,stop_code,stop_name,stop_desc,stop_lat,stop_lon,zone_id,stop_url,location_type,parent_station,stop_timezone,wheelchair_boarding FROM stops";
    .select_stops_by_agency = "SELECT DISTINCT R.agency_id, ST.stop_id, ST.stop_code, ST.stop_name, ST.stop_desc, ST.stop_lat, ST.stop_lon, ST.zone_id, ST.stop_url, ST.location_type, ST.parent_station, ST.stop_timezone, ST.wheelchair_boarding FROM stops AS ST
                     INNER JOIN stop_times AS S ON ST.stop_id = S.stop_id
                     INNER JOIN trips AS TR ON TR.trip_id = S.trip_id
                     INNER JOIN routes AS R ON R.route_id = TR.route_id
                     WHERE R.agency_id=:agency_id";
    .select_stops_in_area = "SELECT stop_id,stop_code,stop_name,stop_desc,stop_lat,stop_lon,zone_id,stop_url,location_type,parent_station,stop_timezone,wheelchair_boarding,SQRT( ABS((stop_lon - :stop_lon)*(stop_lon - :stop_lon)) + ABS((stop_lat - :stop_lat)*(stop_lat - :stop_lat))) AS dist FROM stops WHERE SQRT( ABS((stop_lon - :stop_lon)*(stop_lon - :stop_lon)) + ABS((stop_lat - :stop_lat)*(stop_lat - :stop_lat))) < :radius ORDER BY dist";
    .select_stops_in_a_trip = "SELECT S.stop_id, S.stop_code, S.stop_name, S.stop_desc, S.stop_lat, S.stop_lon, S.zone_id, S.stop_url, S.location_type, S.parent_station, S.stop_timezone, S.wheelchair_boarding, CAST( T.stop_sequence AS SMALLINT ) AS sequence  FROM stop_times AS T
                               INNER JOIN stops AS S ON S.stop_id=T.stop_id
                               WHERE T.trip_id=:trip_id ORDER BY sequence";
    .select_routes = "SELECT route_id, agency_id, route_short_name, route_long_name, route_desc, route_type, route_url, route_color, route_text_color FROM routes";
    .select_routes_by_agency = "SELECT route_id, agency_id, route_short_name, route_long_name, route_desc, route_type, route_url, route_color, route_text_color FROM routes WHERE agency_id=:agency_id";
    .select_route_trips = "SELECT DISTINCT trip_id, service_id FROM trips WHERE route_id=:route_id AND direction_id=:direction_id ORDER BY service_id, trip_id";
    .select_route_service_trips = "SELECT DISTINCT trip_id FROM trips WHERE route_id=:route_id AND direction_id=:direction_id AND service_id=:service_id ORDER BY trip_id";
    .select_routes_from_stop = "SELECT DISTINCT R.route_id,R.agency_id,R.route_short_name,R.route_long_name,R.route_desc,R.route_type,R.route_url,R.route_color,R.route_text_color,T.direction_id FROM routes AS R
                               INNER JOIN trips AS T ON R.route_id = T.route_id
                               INNER JOIN stop_times AS S ON T.trip_id = S.trip_id
                               WHERE S.stop_id = :stop_id";
    .select_trip_if_stop_exists = "SELECT trip_id FROM stop_times WHERE stop_id=:stop_id AND trip_id=:trip_id";
    .select_trip_stops = "SELECT S.stop_id, S.stop_name, S.stop_lon, S.stop_lat, ST.stop_sequence, ST.departure_time FROM stop_times AS ST
                          INNER JOIN stops AS S ON S.stop_id=ST.stop_id
                          WHERE ST.trip_id=:trip_id ORDER BY ST.stop_sequence;";
    .select_shapes_by_trip = "SELECT S.shape_id, S.shape_dist_traveled, S.shape_pt_lat, S.shape_pt_lon, S.shape_pt_sequence, T.shape_id FROM trips as T
                              INNER JOIN shapes AS S ON T.shape_id=S.shape_id
                              WHERE T.trip_id=:trip_id ORDER BY S.shape_pt_sequence";
    .select_stop_times_by_stop_and_route = "SELECT ST.departure_time FROM stop_times AS ST
                              INNER JOIN trips AS T ON ST.trip_id=T.trip_id
                              LEFT JOIN calendar_date AS C ON T.service_id=C.service_id
                              LEFT JOIN calendar AS CAL ON CAL.service_id=T.service_id
                              WHERE ST.stop_id=:stop_id
                                 AND t.direction_id=:direction_id
                                 AND T.route_id=:route_id
                                 AND (( C.date=:date AND C.exception_type=1 )
                                     OR ( CAL.start_date <= :date
                                          AND CAL.end_date >= :date
                                          AND (cast( CAL.days as bit(7)) & cast( :days as bit(7) ) ) = cast( :days as bit(7) )
                                ))
                                ORDER BY ST.departure_time";
    .select_trips_by_route = "SELECT DISTINCT T.trip_id, S.stop_id, S.stop_name, S.stop_lat, S.stop_lon, ST.departure_time, ST.stop_sequence FROM trips AS T
                              INNER JOIN stop_times AS ST ON T.trip_id=ST.trip_id
                              INNER JOIN stops AS S ON ST.stop_id=S.stop_id
                              LEFT JOIN calendar_date AS C ON T.service_id=C.service_id
                              LEFT JOIN calendar AS CAL ON CAL.service_id=T.service_id
                              WHERE T.route_id=:route_id
                                AND T.direction_id=:direction_id
                                AND (( C.date=:date AND C.exception_type=1 )
                                    OR ( CAL.start_date <= :date
                                         AND CAL.end_date >= :date
                                         AND (cast( CAL.days as bit(7)) & cast( :days as bit(7) ) ) = cast( :days as bit(7) )
                                ))
                                ORDER BY trip_id, departure_time";
    .select_trips_by_id = "SELECT DISTINCT T.trip_id, T.route_id, T.direction_id, T.service_id, S.stop_id, S.stop_name, S.stop_lat, S.stop_lon, ST.departure_time, ST.stop_sequence FROM trips AS T
                              INNER JOIN stop_times AS ST ON T.trip_id=ST.trip_id
                              INNER JOIN stops AS S ON ST.stop_id=S.stop_id
                              WHERE T.trip_id=:trip_id ORDER BY departure_time"

  }
}
