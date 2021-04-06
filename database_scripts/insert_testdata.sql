--
-- Insert test data into FestivalsAPI database
--

USE festivals_api_database;

-- Insert link
INSERT INTO `links`(`link_url`, `link_service`)
        VALUES ('https://www.google.com', 1);
INSERT INTO `links`(`link_url`, `link_service`) VALUES ('https://www.golem.de/', 2);

-- Insert place
INSERT INTO `places`(`place_street`, `place_zip`, `place_town`, `place_street_addition`, `place_country`, `place_lat`, `place_lon`, `place_description`)
        VALUES ('Ackerstraße 169', '10115', 'Berlin', '-', 'DE', 52.529751, 13.396985, 'Left than right.');
INSERT INTO `places`(`place_street`, `place_zip`, `place_town`, `place_street_addition`, `place_country`, `place_lat`, `place_lon`, `place_description`)
        VALUES ('Laskerstraße 5', '10245', 'Berlin', '-', 'DE', 52.501654, 13.465578, 'Right than left.');

-- Insert tag
INSERT INTO `tags`(`tag_name`)
        VALUES ('Indie');
INSERT INTO `tags`(`tag_name`)
        VALUES ('Rock');
INSERT INTO `tags`(`tag_name`)
        VALUES ('Pop');

-- Insert image
INSERT INTO `images`(`image_hash`, `image_comment`, `image_ref`)
        VALUES ('12345678910', 'What a nice picture!', 'https://www.example.com/image-1');
INSERT INTO `images`(`image_hash`, `image_comment`, `image_ref`)
        VALUES ('1112131411516', 'Another nice picture!', 'https://www.example.com/image-2');

-- Inser festival
INSERT INTO  `festivals`(`festival_is_valid`, `festival_name`,  `festival_start`, `festival_end`,  `festival_description`,  `festival_price`)
        VALUES (false, 'Stemmwede (2020)', '100', '200', 'Das Stemweder Open Air Festival ist eines der ältesten Umsonst-und-Draußen-Festivals in Deutschland, das seit 1976 jährlich in der ostwestfälischen Gemeinde Stemwede im Kreis Minden-Lübbecke stattfindet.', 'Umsonst-und-Draußen');
INSERT INTO  `festivals`(`festival_is_valid`, `festival_name`,  `festival_start`, `festival_end`,  `festival_description`,  `festival_price`)
VALUES (false, 'Krach am Bach (2020)', '300', '400', 'Krach am Bach ist ein deutsches jährliches Benefiz-Musikfestival in Beelen im Kreis Warendorf in Nordrhein-Westfalen. Es wird von einem 1994 gegründeten Verein organisiert. Ursprünglich zugunsten einer Freundin organisiert, gehen die Spendengelder inzwischen an verschiedene gemeinnützige Organisationen.', 'VVK 45 €');

-- Insert artist
INSERT INTO `artists`(`artist_name`, `artist_description`)
	    VALUES ('Menomena', 'Menomena ist eine Band aus Portland, USA. Ende 2000 wurde die Band von Danny Seim, Brent Knopf und Justin Harris gegründet. Sie spielen einen eher sperrigen Indiepop und werden mit Bands wie The Flaming Lips, Mercury Rev oder Sonic Youth verglichen.');
INSERT INTO `artists`(`artist_name`, `artist_description`)
        VALUES ('Sufjan Stevens', 'Sufjan Stevens ist ein US-amerikanischer Singer-Songwriter und Multiinstrumentalist. Unter anderem spielt er Gitarre, Banjo, Klavier, Orgel, Bass, Oboe, Saxophon, Querflöte, Akkordeon und Schlagzeug.');

-- Insert location
INSERT INTO `locations`(`location_name`, `location_description`, `location_accessible`, `location_openair`)
        VALUES ('Schokoladen', 'Das alternative Kulturprojekt bietet Indierock-Konzerte, Theater und Lesungen in ehemaliger Schokoladenfabrik.', 1, 0);
INSERT INTO `locations`(`location_name`, `location_description`, `location_accessible`, `location_openair`)
        VALUES ('Zukunft am Ostkreuz', 'Indie-Filme, alternative Kultur und hausgebrautes Bier im kreativ umgestalteten DDR-Lagerhaus mit Garten.', 1, 1);

   -- Insert event
INSERT INTO `events`(`event_name`, `event_description`, `event_type`, `event_start`, `event_end`)
	    VALUES ('Weihnachtsoratorium', 'Oratorium von Johann Sebastian Bach', '0', '110', '190');
INSERT INTO `events`(`event_name`, `event_description`, `event_type`, `event_start`, `event_end`)
        VALUES ('', '', '0', '310', '390');


-- Insert mapping tables
INSERT INTO `map_artist_image`(`associated_artist`, `associated_image`) VALUES (1,1);
INSERT INTO `map_artist_link`(`associated_artist`, `associated_link`)   VALUES (1,1);
INSERT INTO `map_artist_tag`(`associated_artist`, `associated_tag`)     VALUES (1,1);

INSERT INTO `map_festival_image`(`associated_festival`, `associated_image`) VALUES (1,1);
INSERT INTO `map_festival_link`(`associated_festival`, `associated_link`)   VALUES (1,1);
INSERT INTO `map_festival_place`(`associated_festival`, `associated_place`) VALUES (1,1);
INSERT INTO `map_festival_tag`(`associated_festival`, `associated_tag`)     VALUES (1,1);

INSERT INTO `map_location_image`(`associated_location`, `associated_image`) VALUES (1,1);
INSERT INTO `map_location_link`(`associated_location`, `associated_link`)   VALUES (1,1);
INSERT INTO `map_location_place`(`associated_location`, `associated_place`) VALUES (1,1);

INSERT INTO `map_festival_event`(`associated_festival`, `associated_event`) VALUES (1,1);
INSERT INTO `map_event_artist`(`associated_event`, `associated_artist`)     VALUES (1,1);
INSERT INTO `map_event_location`(`associated_event`, `associated_location`) VALUES (1,1);
