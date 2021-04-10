--
-- Create the Festivals API database
--

-- First create the database
CREATE DATABASE IF NOT EXISTS `festivals_api_database`;

-- Create the tables in the newly created database
USE festivals_api_database;

/**

Create the basic entities

*/

-- Create the festival table
CREATE TABLE IF NOT EXISTS `festivals` (

	`festival_id` 			    int unsigned 	 	NOT NULL AUTO_INCREMENT 											COMMENT 'The id of the festival.',
	`festival_version` 		  	timestamp 			NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() 	COMMENT 'The version of the festival.',
	`festival_is_valid` 	  	tinyint(1) 			NOT NULL DEFAULT 0 													COMMENT 'Boolean value indicating if the festival should be distributed to users.',
	`festival_name` 		    varchar(255)		NOT NULL DEFAULT ''													COMMENT 'The festival name. The name needs to be unique.',
	`festival_start` 		    int unsigned 	  	NOT NULL DEFAULT 0 													COMMENT 'The start date of the festival. Measured in seconds till UNIX Time.',
	`festival_end` 			    int unsigned 	  	NOT NULL DEFAULT 0 													COMMENT 'The end date of the festival. Measured in seconds till UNIX Time.',
	`festival_description` 		text 			    NOT NULL 						      								COMMENT 'The description of the festival.',
	`festival_price` 		    char(255) 			NOT NULL DEFAULT '' 												COMMENT 'The price description of the festival.',

PRIMARY 	KEY (`festival_id`),
UNIQUE 	  	KEY `name` (`festival_name`),
		 	KEY `start` (`festival_start`),
		    KEY `is_valid` (`festival_is_valid`)

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The festival table represents a festival and its core properties.';

-- Create the artist table
CREATE TABLE IF NOT EXISTS `artists` (

	`artist_id` 			    int unsigned 	  	NOT NULL AUTO_INCREMENT 											COMMENT 'The id of the artist.',
	`artist_version` 			timestamp 			NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() 	COMMENT 'The version of the artist.',
	`artist_name` 			    varchar(255) 		NOT NULL DEFAULT '' 												COMMENT 'The name of the artist. The name needs to be unique.',
	`artist_description` 	  	text 				NOT NULL 						      								COMMENT 'The description of the artist.',

PRIMARY 	KEY (`artist_id`),
          	KEY `name` (`artist_name`)

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The artist table represents an artist and its core properties.';

-- Create the location table
CREATE TABLE IF NOT EXISTS `locations` (

	`location_id` 			    int unsigned 			NOT NULL AUTO_INCREMENT 											COMMENT 'The id of the location.',
	`location_version` 		  	timestamp 				NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() 	COMMENT 'The version of the location.',
	`location_name`	 		    varchar(255) 			NOT NULL DEFAULT '' 												COMMENT 'The name of the location. The name does not need to be unique but it is highly recommended.',
	`location_description`  	text 				 	NOT NULL 						      								COMMENT 'The description of the location.',
	`location_accessible` 		tinyint(1) unsigned   	NOT NULL DEFAULT 0 													COMMENT 'Boolean value indicating if the location is accessible.',
	`location_openair` 		  	tinyint(1) unsigned   	NOT NULL DEFAULT 0 													COMMENT 'Boolean value indicating if the location is open-air.',

PRIMARY 	KEY (`location_id`),
			KEY `name` (`location_name`)

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The location table represents a location and its core properties.';

-- Create the event table
CREATE TABLE IF NOT EXISTS `events` (

	`event_id` 				    int unsigned 	  	NOT NULL AUTO_INCREMENT 											COMMENT 'The id of the event.',
	`event_version` 		  	timestamp 			NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() 	COMMENT 'The version of the event.',
	`event_name` 			    varchar(255) 		NOT NULL DEFAULT ''													COMMENT 'The name of the event.',
	`event_description`   		text 		 	   	NOT NULL															COMMENT 'The description of the event.',
	`event_type` 		  		tinyint	        	NOT NULL DEFAULT 0 			  										COMMENT 'The type of the event. Defaults to type music.',
	`event_start` 			  	int unsigned 	  	NOT NULL DEFAULT 0 													COMMENT 'The start date of the even. Measured in seconds till UNIX Time.',
	`event_end` 			    int unsigned 	  	NOT NULL DEFAULT 1 													COMMENT 'The end date of the even. Measured in seconds till UNIX Time.',

PRIMARY 	KEY (`event_id`)

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The event table represents an event and its core properties.';

-- Create the link table
CREATE TABLE IF NOT EXISTS `links` (

	 `link_id` 				    int unsigned	NOT NULL AUTO_INCREMENT 											COMMENT 'The id of the link.',
	 `link_version` 		 	timestamp 		NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() 	COMMENT 'The version of the link.',
	 `link_url` 			    varchar(2083) 	NOT NULL 															COMMENT 'The url of the link.',
     -- defaults to unknown service type
	 `link_service` 		 	tinyint			NOT NULL DEFAULT '-1' 												COMMENT 'The service type of the link.',

PRIMARY 	KEY (`link_id`)

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The link table represents a link and its core properties.';

-- Create the place table
CREATE TABLE IF NOT EXISTS `places` (

	 `place_id` 				int unsigned		NOT NULL AUTO_INCREMENT 											COMMENT 'The id of the place.',
	 `place_version` 	        timestamp 			NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() 	COMMENT 'The version of the place.',
	 `place_street` 	        varchar(500)		NOT NULL DEFAULT ''				  									COMMENT 'The street of the place.',
	 `place_zip` 				varchar(10) 		NOT NULL DEFAULT ''				  									COMMENT 'The zip code of the place.',
	 `place_town` 				varchar(65) 		NOT NULL DEFAULT ''				  									COMMENT 'The town of the place.',
	 `place_street_addition`  	varchar(500) 		NOT NULL DEFAULT ''			    									COMMENT 'The street addition of the place.',
	 `place_country` 			varchar(65) 		NOT NULL DEFAULT ''			    									COMMENT 'The country of the place.',
	 `place_lat` 				float(10,6) 		NOT NULL DEFAULT 0.000000											COMMENT 'The latitude of the place.',
	 `place_lon` 				float(10,6) 		NOT NULL DEFAULT 0.000000											COMMENT 'The longitude of the place.',
	 `place_description` 		text				NOT NULL					          								COMMENT 'The description of the place.',

PRIMARY 	KEY (`place_id`),
			KEY `latitude` (`place_lat`),
			KEY `longitude` (`place_lon`)

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The place table represents a place and its core properties.';

-- Create the tag table
CREATE TABLE IF NOT EXISTS `tags` (

	 `tag_id` 	    			int unsigned 		NOT NULL AUTO_INCREMENT   	COMMENT 'The id of the tag.',
	 `tag_name` 	 			varchar(255)    	NOT NULL					COMMENT 'The name of the tag.',

PRIMARY 	KEY (`tag_id`),
UNIQUE	  	KEY `name` (`tag_name`)

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The tag table represents a tag and its core properties.';

-- Create the image table
CREATE TABLE IF NOT EXISTS `images` (

	 `image_id` 		    	int unsigned    NOT NULL AUTO_INCREMENT 	COMMENT 'The id of the image.',
	 `image_hash` 		  		char(32) 		NOT NULL					COMMENT 'The hash of the image.',
	 `image_comment` 	  		char(255) 		NOT NULL DEFAULT ''			COMMENT 'The comment of the image.',
	 `image_ref` 		    	varchar(2083)   NOT NULL DEFAULT ''			COMMENT 'The referer link of the image.',

PRIMARY 	KEY (`image_id`)

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The image table represents an image and its core properties.';

/**

Create the mapping tables to associate entities

*/

-- Create the table to map events to festivals
CREATE TABLE IF NOT EXISTS `map_festival_event` (

    `map_id` 				 	int unsigned 		NOT NULL AUTO_INCREMENT		COMMENT 'The id of the map entry.',
    `associated_festival` 		int unsigned 		NOT NULL					        COMMENT 'The id of the mapped festival.',
    `associated_event` 	    	int unsigned 		NOT NULL					        COMMENT 'The id of the mapped event.',

PRIMARY 	KEY (`map_id`),
-- An event should only be mapped to one festival at a time.
UNIQUE    	KEY (`associated_event`),
FOREIGN 	KEY (`associated_event`) 	   	REFERENCES events (event_id) 		   ON DELETE CASCADE 	ON UPDATE CASCADE,
FOREIGN 	KEY (`associated_festival`)  	REFERENCES festivals (festival_id)  ON DELETE CASCADE 	ON UPDATE CASCADE

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The table maps festivals to events.';

-- Create the table to map images to festivals
CREATE TABLE IF NOT EXISTS `map_festival_image` (

	 `map_id` 					int unsigned 		NOT NULL AUTO_INCREMENT		COMMENT 'The id of the map entry.',
	 `associated_festival` 		int unsigned 		NOT NULL					        COMMENT 'The id of the mapped festival.',
	 `associated_image` 	  	int unsigned 		NOT NULL					        COMMENT 'The id of the mapped image.',

PRIMARY 	KEY (`map_id`),
FOREIGN 	KEY (`associated_festival`) 	REFERENCES festivals (festival_id)	ON DELETE CASCADE 	ON UPDATE CASCADE,
FOREIGN 	KEY (`associated_image`) 		REFERENCES images (image_id)		ON DELETE CASCADE 	ON UPDATE CASCADE

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The table maps images to festivals.';

-- Create the table to map links to festivals
CREATE TABLE IF NOT EXISTS `map_festival_link` (

	`map_id` 					int unsigned 		    NOT NULL AUTO_INCREMENT		COMMENT 'The id of the map entry.',
   	`associated_festival` 	  	int unsigned 		    NOT NULL					COMMENT 'The id of the mapped festival.',
	`associated_link` 		    int unsigned 		    NOT NULL					COMMENT 'The id of the mapped link.',

PRIMARY 	KEY (`map_id`),
FOREIGN 	KEY (`associated_festival`)		REFERENCES festivals (festival_id)		ON DELETE CASCADE 	ON UPDATE CASCADE,
FOREIGN 	KEY (`associated_link`)			REFERENCES links (link_id)				ON DELETE CASCADE 	ON UPDATE CASCADE

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The table maps links to festivals.';


-- Create the table to map places to festivals
CREATE TABLE IF NOT EXISTS `map_festival_place` (

	`map_id` 					int unsigned 		    NOT NULL AUTO_INCREMENT		COMMENT 'The id of the map entry.',
	`associated_festival` 	 	int unsigned 		    NOT NULL					COMMENT 'The id of the mapped festival.',
	`associated_place` 	   		int unsigned 		    NOT NULL					COMMENT 'The id of the mapped place.',

PRIMARY 	KEY (`map_id`),
FOREIGN 	KEY (`associated_festival`)		REFERENCES festivals (festival_id)	ON DELETE CASCADE 	ON UPDATE CASCADE,
FOREIGN 	KEY (`associated_place`) 		REFERENCES places (place_id) 		ON DELETE CASCADE 	ON UPDATE CASCADE

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The table maps places to festivals.';


-- Create the table to map tags to festivals
CREATE TABLE IF NOT EXISTS `map_festival_tag` (

	`map_id` 					int unsigned 		    NOT NULL AUTO_INCREMENT		COMMENT 'The id of the map entry.',
	`associated_festival` 		int unsigned 		    NOT NULL					        COMMENT 'The id of the mapped festival.',
	`associated_tag`	 	    int unsigned 		    NOT NULL					        COMMENT 'The id of the mapped tag.',

PRIMARY 	KEY (`map_id`),
FOREIGN 	KEY (`associated_festival`)		REFERENCES festivals (festival_id)	ON DELETE CASCADE 	ON UPDATE CASCADE,
FOREIGN 	KEY (`associated_tag`) 			  REFERENCES tags (tag_id) 			      ON DELETE CASCADE 	ON UPDATE CASCADE

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The table maps tags to festivals.';

-- Create the table to map images to artists
CREATE TABLE IF NOT EXISTS `map_artist_image` (

	`map_id` 					int unsigned 		NOT NULL AUTO_INCREMENT 	COMMENT 'The id of the map entry.',
	`associated_artist` 		int unsigned 		NOT NULL 					        COMMENT 'The id of the mapped artist.',
	`associated_image` 			int unsigned 		NOT NULL 					        COMMENT 'The id of the mapped image.',

PRIMARY 	KEY (`map_id`),
FOREIGN 	KEY (`associated_artist`) 	REFERENCES artists (artist_id) 	ON DELETE CASCADE 	ON UPDATE CASCADE,
FOREIGN 	KEY (`associated_image`) 	  REFERENCES images (image_id) 	  ON DELETE CASCADE 	ON UPDATE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='The table maps images to artists.';

-- Create the table to map links to artists
CREATE TABLE IF NOT EXISTS `map_artist_link` (

	`map_id` 				    int unsigned 		    NOT NULL AUTO_INCREMENT		COMMENT 'The id of the map entry.',
   	`associated_artist` 		int unsigned 		    NOT NULL					COMMENT 'The id of the mapped artist.',
	`associated_link` 			int unsigned 		    NOT NULL					COMMENT 'The id of the mapped link.',

PRIMARY 	KEY (`map_id`),
FOREIGN 	KEY (`associated_artist`) 		REFERENCES artists (artist_id) 	ON DELETE CASCADE 	ON UPDATE CASCADE,
FOREIGN 	KEY (`associated_link`) 		  REFERENCES links (link_id) 	 	  ON DELETE CASCADE 	ON UPDATE CASCADE

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The table maps links to artists.';


-- Create the table to map tags to artists
CREATE TABLE IF NOT EXISTS `map_artist_tag` (

	 `map_id` 					int unsigned		    NOT NULL AUTO_INCREMENT		COMMENT 'The id of the map entry.',
	 `associated_artist` 	 	int unsigned 		  NOT NULL					        COMMENT 'The id of the mapped artist.',
	 `associated_tag` 		 	int unsigned 		  NOT NULL					        COMMENT 'The id of the mapped tag.',

PRIMARY 	KEY (`map_id`),
FOREIGN 	KEY (`associated_artist`)		REFERENCES artists (artist_id)		ON DELETE CASCADE 	ON UPDATE CASCADE,
FOREIGN 	KEY (`associated_tag`) 			REFERENCES tags (tag_id) 			    ON DELETE CASCADE 	ON UPDATE CASCADE

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The table maps tags to artists.';

-- Create the table to map images to locations
CREATE TABLE IF NOT EXISTS `map_location_image` (

	 `map_id` 					int unsigned 		NOT NULL AUTO_INCREMENT		COMMENT 'The id of the map entry.',
	 `associated_location` 		int unsigned 		NOT NULL					        COMMENT 'The id of the mapped location.',
	 `associated_image` 	  	int unsigned 		NOT NULL					        COMMENT 'The id of the mapped image.',

PRIMARY 	KEY (`map_id`),
FOREIGN 	KEY (`associated_location`) 	REFERENCES locations (location_id) 	ON DELETE CASCADE 	ON UPDATE CASCADE,
FOREIGN 	KEY (`associated_image`) 		  REFERENCES images (image_id) 		    ON DELETE CASCADE 	ON UPDATE CASCADE

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The table maps images to locations.';

-- Create the table to map links to locations
CREATE TABLE IF NOT EXISTS `map_location_link` (

	 `map_id` 					int unsigned 		    NOT NULL AUTO_INCREMENT		COMMENT 'The id of the map entry.',
   `associated_location` 	  	int unsigned 		    NOT NULL					        COMMENT 'The id of the mapped location.',
	 `associated_link` 		    int unsigned 		    NOT NULL					        COMMENT 'The id of the mapped link.',

PRIMARY 	KEY (`map_id`),
FOREIGN 	KEY (`associated_location`)		REFERENCES locations (location_id)	ON DELETE CASCADE 	ON UPDATE CASCADE,
FOREIGN 	KEY (`associated_link`) 		  REFERENCES links (link_id) 			    ON DELETE CASCADE 	ON UPDATE CASCADE

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The table maps links to locations.';

-- Create the table to map places to locations
CREATE TABLE IF NOT EXISTS `map_location_place` (

	 `map_id` 					int unsigned 		    NOT NULL AUTO_INCREMENT		COMMENT 'The id of the map entry.',
	 `associated_location` 	  	int unsigned		    NOT NULL					        COMMENT 'The id of the mapped location.',
	 `associated_place` 	    int unsigned 		    NOT NULL					        COMMENT 'The id of the mapped link.',

PRIMARY 	KEY (`map_id`),
FOREIGN 	KEY (`associated_location`)		REFERENCES locations (location_id)	ON DELETE CASCADE 	ON UPDATE CASCADE,
FOREIGN 	KEY (`associated_place`) 		  REFERENCES places (place_id) 		    ON DELETE CASCADE 	ON UPDATE CASCADE

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The table maps places to locations.';

-- Create the table to map images to events
CREATE TABLE IF NOT EXISTS `map_event_image` (

	 `map_id` 					int unsigned 		NOT NULL AUTO_INCREMENT				COMMENT 'The id of the map entry.',
	 `associated_event` 		int unsigned 		NOT NULL					        COMMENT 'The id of the mapped event.',
	 `associated_image` 	  	int unsigned 		NOT NULL					        COMMENT 'The id of the mapped image.',

PRIMARY 	KEY (`map_id`),
FOREIGN 	KEY (`associated_event`) 		REFERENCES events (event_id) 			ON DELETE CASCADE 	ON UPDATE CASCADE,
FOREIGN 	KEY (`associated_image`) 	  	REFERENCES images (image_id) 		    ON DELETE CASCADE 	ON UPDATE CASCADE

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The table maps images to events.';

-- Create the table to map artists to events
CREATE TABLE IF NOT EXISTS `map_event_artist` (

    `map_id` 					int unsigned 		NOT NULL AUTO_INCREMENT				COMMENT 'The id of the map entry.',
    `associated_event` 	  		int unsigned 		NOT NULL					        COMMENT 'The id of the mapped event.',
    `associated_artist` 		int unsigned 		NOT NULL					        COMMENT 'The id of the mapped artist.',

PRIMARY 	KEY (`map_id`),
FOREIGN 	KEY (`associated_event`) 		REFERENCES events (event_id) 		    ON DELETE CASCADE 	ON UPDATE CASCADE,
FOREIGN 	KEY (`associated_artist`)   	REFERENCES artists (artist_id) 	    	ON DELETE CASCADE 	ON UPDATE CASCADE

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The table maps artists to events.';

-- Create the table to map locations to events
CREATE TABLE IF NOT EXISTS `map_event_location` (

    `map_id` 					int unsigned 		NOT NULL AUTO_INCREMENT		COMMENT 'The id of the map entry.',
    `associated_event` 	    	int unsigned 		NOT NULL					        COMMENT 'The id of the mapped event.',
    `associated_location` 		int unsigned 		NOT NULL					        COMMENT 'The id of the mapped location.',

PRIMARY 	KEY (`map_id`),
FOREIGN 	KEY (`associated_event`) 			REFERENCES events (event_id) 		    ON DELETE CASCADE 	ON UPDATE CASCADE,
FOREIGN 	KEY (`associated_location`) 		REFERENCES locations (location_id) 		ON DELETE CASCADE 	ON UPDATE CASCADE

) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='The table maps locations to events.';
