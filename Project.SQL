<!DOCTYPE SQL>


/* Create tables */
create table traveler (passportNum number primary key, fname varchar(10) NOT NULL, lname varchar(20) NOT NULL, DOB date NOT NULL, age number NOT NULL);

create table destination (airportCode varchar(10) primary key, dname varchar(15), country varchar(20) NOT NULL, currency varchar(8) NOT NULL);

create table trip (tripID number primary key, airportCode varchar(10) references destination(airportCode) NOT NULL, passportNum number references traveler(passportNum) NOT NULL, reservationID number references transportation(reservationID) NOT NULL, traveldate date NOT NULL, traveltime timestamp, tripduration number, allocatedCost number NOT NULL, groupID number);

create table going (passportNum number references traveler(passportNum) NOT NULL, tripID number references trip(tripID) NOT NULL);

create table doing (tripID number references trip(tripID) NOT NULL, itineraryNum number references itinerary(itineraryNum) NOT NULL);

create table itinerary (itineraryNum number primary key, place varchar(10), destination varchar(10) references destination(airportCode) NOT NULL, type varchar(10) NOT NULL, onday date NOT NULL, time timestamp, price number);

create table transportation (reservationID number primary key, type varchar(10) NOT NULL, price number, travelto varchar(20) NOT NULL, travelfrom varchar(20));

create table travelingWith (passportNum1 number references traveler(passportNum) NOT NULL, passportNum2 number references traveler(passportNum) NOT NULL, groupID number);

create table accommodations (name varchar(10) primary key, type varchar(10), price number, numPeople number NOT NULL);

create table accommodate (passportNum number references traveler(passportNum) NOT NULL, name varchar(20) references accommodations(name) NOT NULL, day date NOT NULL, time timestamp, durationStay number NOT NULL);





/* Triggers */
	
	/* Trip */
	
	- allocatedCost > transportation.price + itinerary.price + accommodations.price (group by location)
	
	- create or replace trigger cost_amount
	
	after insert or update of allocatedCost
	
	on trip
	
	declare 
		amount number;
	
	begin
		
		select T.price into amount, I.price into amount, AS.price into amount
		
		from transportation T, itinerary I, accommodations AS
		
		group by tripID;
		
	if (amount > allocatedCost)
			
	then raise_application_error (-20502, 'IC violation: don't have enough money to pay');
		
	end if;
		
	exception 
			
		when NO_DATA_FOUND THEN RETURN;
	
	end;
	
	/



	/* doing */
	- if type = bar and country != 'USA' then check if age >= 18, else if type = bar and country = 'USA' then check if age >= 21
	- 
	create or replace trigger of_age	
	after insert or update of itineraryNum
	on doing
	declare 
 		num number;
	begin
  		select count(*) into num	
  		from traveler TR, itinerary I, trip T, doing D, destination DS
  		where T.PASSPORTNUM = TR.PASSPORTNUM and DS.AIRPORTCODE = I.DESTINATION and D.TRIPID = T.TRIPID and D.ITINERARYNUM = I.ITINERARYNUM and 		I.type = 'Bar' AND ((TR.age < 18 AND DS.COUNTRY != 'USA') OR (TR.age < 21 AND DS.COUNTRY = 'USA'));
	if (num > 0)		
	then raise_application_error (-20502, 'IC violation: under age');	
	end if;	
	exception	
 		when NO_DATA_FOUND THEN RETURN;
	end;
	/




/* Checkers */
	
	/* ANY PRICE */
	
	- alter table accommodations add constraint as_negP_check check (price >= 0);
	
	- alter table transportation add constraint trans_negP_check check (price >= 0);
	
	- alter table itinerary add constraint it_negP_check check (price >= 0);
	
	- alter table trip add constraint t_negP_check check (allocatedCost >= 0);
	
	/* trip */
	
	- alter table trip add constraint durationLength_check check (tripduration > 0);



/* Views */
	/* Transportation */
	- create view transport as select type, travelTo from transportation;

	/* Accommodations */
	- create view peopleInRoom as select numPeople from accommodations;

	/* travelingWith */
	- create view travelingCompanions as select unique T.fname, T.lname from traveler T, travelingWith TW where T.passportNum = TW.passportNum1 or T.passportNum = TW.passportNum2;

	/* travelers */
	- create view under21 as select age from traveler where age < 21;
	- create view under18 as select age from traveler where age < 18;


/* Indicies */
	/* trip */
	- CREATE INDEX tripDestinations ON trip(airportCode);
	/* travelers */
	- CREATE INDEX travelersAge ON traveler(age);


/* Insert data into traveler table */
insert into traveler values(12345678, 'Sara', 'Lopez', '30-AUG-96', 22);
insert into traveler values(87654321, 'Carlotta', 'Jackson-Clark', '04-MAR-95', 24);
insert into traveler values(12344321, 'Emmy', 'Lopez', '24-FEB-95', 24);
insert into traveler values(66666666, 'Julia', 'Jackson-Clark', '10-SEP-97', 21);
insert into traveler values(37373737, 'Kennedy', 'Joseph', '25-MAR-00', 19);
insert into traveler values(73737373, 'Daniella', 'Fuertes', '01-JUL-02', 17);


/* Insert data into destination table */
insert into destination values('BRN', 'Bern', 'Switzerland', 'SwissFranc');
insert into destination values('BCN', 'Barcelona', 'Spain', 'Euro');
insert into destination values('LIS', 'Lisbon', 'Portugal', 'Euro');
insert into destination values('DFW', 'Dallas', 'USA', 'USD');
insert into destination values('SEA', 'Tacoma', 'USA', 'USD');

insert into destination values('PMI', 'Banyalbufar', 'Spain', 'Euro');

insert into destination values('CDT', 'Peniscola', 'Spain', 'Euro');

insert into destination values('OPO', 'Porto', 'Portugal', 'Euro');
insert into destination values('SBP', 'San Luis Obispo', 'USA', 'USD');
insert into destination values('GVA', 'Geneva', 'Switzerland', 'SwissFranc');
insert into destination values('ZRH', 'Zürich', 'Switzerland', 'SwissFranc');
insert into destination values('PUJ', 'Punta_Cana', 'DominicanRepublic', 'Peso');
insert into destination values('LAX', 'Los_Angeles', 'USA', 'USD');


/* Insert data into transportation table */
insert into transportation values(334422, 'Plane', 849, 'Bern', 'Dallas');
insert into transportation values(334433, 'Plane', 849, 'Bern', 'Dallas');

insert into transportation values(373737, 'Car', 140, 'Geneva', 'Bern');

insert into transportation values(373738, 'Car', 140, 'Bern', 'Geneva');

insert into transportation values(373739, 'Car', 140, 'Zürich', 'Bern');

insert into transportation values(373730, 'Car', 140, 'Bern', 'Zürich');


insert into transportation values(246135, 'Train', 54, 'Barcelona', 'Bern');
insert into transportation values(246137, 'Train', 54, 'Barcelona', 'Bern');

insert into transportation values(987654, 'Plane', 799, 'Barcelona', 'Tacoma');

insert into transportation values(111111, 'Car', 140, 'Peniscola', 'Barcelona');

insert into transportation values(223344, 'Boat', 140, 'Banyalbufar', 'Peniscola');

insert into transportation values(223345, 'Boat', 140, 'Peniscola', 'Banyalbufar');

insert into transportation values(111112, 'Car', 140, 'Barcelona', 'Peniscola');

insert into transportation values(222223, 'Plane', 82, 'Lisbon', 'Barcelona');
insert into transportation values(222225, 'Plane', 82, 'Lisbon', 'Barcelona');
insert into transportation values(222227, 'Plane', 82, 'Lisbon', 'Barcelona');

insert into transportation values(908070, 'Car', 80, 'Porto', 'Lisbon');

insert into transportation values(908071, 'Car', 80, 'Lisbon', 'Porto');

insert into transportation values(123098, 'Plane', 762, 'Dallas', 'Lisbon');
insert into transportation values(123987, 'Plane', 762, 'Dallas', 'Lisbon');
insert into transportation values(123876, 'Plane', 762, 'Dallas', 'Lisbon');
insert into transportation values(191910, 'Plane', 204, 'Tacoma', 'Dallas');

insert into transportation values(135246, 'Plane', 700, 'Punta_Cana', 'Dallas');
insert into transportation values(135247, 'Plane', 700, 'Dallas', 'Punta_Cana');
insert into transportation values(135278, 'Plane', 700, 'Punta_Cana', 'Dallas');
insert into transportation values(135279, 'Plane', 700, 'Dallas', 'Punta_Cana');

insert into transportation values(135000, 'Plane', 200, 'Tacoma', 'Dallas');
insert into transportation values(135999, 'Plane', 200, 'Dallas', 'Tacoma');
insert into transportation values(135888, 'Plane', 200, 'Tacoma', 'Dallas');
insert into transportation values(135777, 'Plane', 200, 'Dallas', 'Tacoma');

insert into transportation values(136600, 'Plane', 700, 'Punta_Cana', 'Los_Angeles');
insert into transportation values(137799, 'Plane', 700, 'Los_Angeles', 'Punta_Cana');
insert into transportation values(138888, 'Plane', 700, 'Punta_Cana', 'Los_Angeles');
insert into transportation values(139977, 'Plane', 700, 'Los_Angeles', 'Punta_Cana');

/* Insert data into trip table */
insert into trip values(00213, 'BRN', 12345678, 334422, '11-JUN-19', '07:00:00', 15, 1000);
insert into trip values(00344, 'BRN', 87654321, 334433, '11-JUN-19', '07:00:00', 15, 1000);

insert into trip values(00654, 'BCN', 12345678, 246135, '22-JUN-19', '08:15:00', 14, 100);
insert into trip values(00345, 'BCN', 87654321, 246137, '22-JUN-19', '08:15:00', 14, 100);
insert into trip values(00653, 'BCN', 12344321, 987654, '22-JUN-19', '05:43:00', 16, 900);

insert into trip values(00254, 'LIS', 12345678, 222223, '30-JUN-19', '15:15:00', 2, 100);
insert into trip values(00999, 'LIS', 87654321, 222225, '30-JUN-19', '15:15:00', 2, 100);
insert into trip values(00553, 'LIS', 12344321, 222227, '30-JUN-19', '15:15:00', 2, 100);

insert into trip values(00887, 'DFW', 12345678, 123098, '07-JUL-19', '10:30:00', 13, 800);
insert into trip values(00778, 'DFW', 87654321, 123987, '07-JUL-19', '10:30:00', 13, 800);
insert into trip values(00444, 'DFW', 12344321, 123876, '07-JUL-19', '10:30:00', 13, 800);

insert into trip values(00100, 'SEA', 12344321, 191910, '10-JUL-19', '09:30:00', 4.5, 250);

insert into trip values(00219, 'GVA', 12345678, 373737, '19-JUN-19', 'AM', 2, 50, 1111);
insert into trip values(00347, 'BRN', 12345678, 373738, '19-JUN-19', 'PM', 2, 50, 1111);
insert into trip values(00267, 'ZRH', 12345678, 373739, '20-JUN-19', 'AM', 1.5, 50, 1111);
insert into trip values(00309, 'BRN', 12345678, 373730, '20-JUN-19', 'PM', 1.5, 50, 1111);

insert into trip values(00111, 'CDT', 12345678, 111111, '25-JUN-19', '08:00:00', 3, 140, 1112);
insert into trip values(00222, 'PMI', 12345678, 111112, '25-JUN-19', '11:30:00', 7, 140, 1112);
insert into trip values(00333, 'CDT', 12345678, 223344, '26-JUN-19', '08:00:00', 7, 140, 1112);

insert into trip values(00334, 'BCN', 12345678, 223345, '26-JUN-19', 'PM', 3, 140, 1112);

insert into trip values(00777, 'OPO', 12345678, 908070, '02-JUL-19', '15:15:00', 3, 80, 1112);
insert into trip values(00666, 'LIS', 12345678, 908071, '02-JUL-19', '15:15:00', 3, 80, 1112);


/* Kennedy of age */
insert into trip values(00788, 'PUJ', 12345678, 135246, '27-AUG-19', '15:15:00', 5, 750, NULL);
insert into trip values(00667, 'DFW', 12345678, 135247, '01-SEP-19', '15:15:00', 5, 750, NULL);
insert into trip values(00949, 'PUJ', 37373737, 135278, '27-AUG-19', '15:15:00', 5, 750, NULL);
insert into trip values(00959, 'DFW', 37373737, 135279, '01-SEP-19', '15:15:00', 5, 750, NULL);

/* Kennedy not of age */
insert into trip values(00881, 'SEA', 12345678, 135000, '02-SEP-19', '10:30:00', 5, 200, NULL);
insert into trip values(00992, 'DFW', 12345678, 135999, '05-SEP-19', '14:00:00', 5, 200, NULL);
insert into trip values(00995, 'SEA', 37373737, 135888, '02-SEP-19', '10:30:00', 5, 200, NULL);
insert into trip values(00690, 'DFW', 37373737, 135777, '05-SEP-19', '14:00:00', 5, 200, NULL);

/* Dani not of age */											**
insert into trip values(00771, 'PUJ', 12345678, 136600, '17-SEP-19', '12:30:00', 5, 750, NULL);
insert into trip values(00802, 'LAX', 12345678, 137799, '19-SEP-19', '16:00:00', 5, 750, NULL);
insert into trip values(00905, 'PUJ', 73737373, 138888, '17-SEP-19', '12:30:00', 5, 750, NULL);
insert into trip values(00300, 'LAX', 73737373, 139977, '19-SEP-19', '16:00:00', 5, 750, NULL);


/* Insert data into itinerary table */
insert into itinerary values(01, 'Gurten', 'BRN', 'Town', '12-JUN-19', '11:00:00', 20);
insert into itinerary values(02, 'Turnhalle', 'BRN', 'Bar', '13-JUN-19', '19:00:00', 40);
insert into itinerary values(03, 'Barbière', 'BRN', 'Bar', '14-JUN-19', '18:30:00', 44);

insert into itinerary values(04, 'Zytglogge', 'BRN', 'Tower', '15-JUN-19', '10:00:00', 12);
insert into itinerary values(05, 'Old_Town', 'BRN', 'Town', '16-JUN-19', '9:30:00', 30);
insert into itinerary values(06, 'Rosengarten', 'BRN', 'Restaurant', '18-JUN-19', '10:00:00', 25);
insert into itinerary values(08, 'Aare', 'BRN', 'River', '21-JUN-19', NULL, 0);

insert into itinerary values(09, 'Park_ Güell', 'BCN', 'Park', '23-JUN-19', NULL, NULL);
insert into itinerary values(10, 'Sagrada_Família', 'BCN', 'Church', '23-JUN-19', NULL, NULL);
insert into itinerary values(11, 'La_Rambla', 'BCN', 'Shops', '24-JUN-19', NULL, NULL);
insert into itinerary values(22, 'Rubí_Bar', 'BCN', 'Bar', '24-JUN-19', '19:00:00', NULL);
insert into itinerary values(12, 'ParcDeLaCiutadella', 'BCN', 'Park', '27-JUN-19', NULL);
insert into itinerary values(13, 'Barcelona_Cathedral', 'BCN', 'Church', '28-JUN-19', '11:00:00', NULL);
insert into itinerary values(14, 'Plaça_Reial', 'BCN', 'Plaza', '28-JUN-19', 'PM', NULL);
insert into itinerary values(15, 'Santa_Maria_del_Mar', 'BCN', 'Church', '29-JUN-19', '12:00:00', NULL);
insert into itinerary values(16, 'Montserrat', 'BCN', 'Peak', '30-JUN-19', '09:00:00', NULL);

insert into itinerary values(17, 'Alfama', 'LIS', 'District', '01-JUL-19', NULL, NULL);
insert into itinerary values(18, 'Paródia', 'LIS', 'Bar', '01-JUL-19', '21:00:00', 30);
insert into itinerary values(19, 'Bairro_Alto', 'LIS', 'District', '03-JUL-19', NULL, NULL);
insert into itinerary values(20, 'Rossio_Square', 'LIS', 'Square', '04-JUL-19', NULL, NULL);
insert into itinerary values(21, 'Lisbon_Cathedral', 'LIS', 'Church', '05-JUL-19', NULL, NULL);
insert into itinerary values(23, 'CINCO_lounge', 'LIS', 'Bar', '05-JUL-19', '21:00:00', 30);
insert into itinerary values(24, 'Cabo_da_Roca ', 'LIS', 'Lighthouse', '06-JUL-19', NULL, NULL);


insert into itinerary values(33, 'Bávaro', 'PUJ', 'Beach', '28-AUG-19', NULL, NULL);
insert into itinerary values(25, 'Coco_Bongo', 'PUJ', 'Bar', '28-AUG-19', '21:00:00', 30);
insert into itinerary values(26, 'Cortecito_Beach', 'PUJ', 'Beach', '29-AUG-19', NULL, NULL);
insert into itinerary values(27, 'ORO_Nightclub', 'PUJ', 'Club', '29-AUG-19', '21:00:00', NULL);
insert into itinerary values(28, 'Bávaro', 'PUJ', 'Beach', '30-AUG-19', 'AM', NULL);
insert into itinerary values(29, 'Hoyo_azul', 'PUJ', 'ZipLine', '30-AUG-19', '13:00:00', 30);
insert into itinerary values(30, 'El_Kan', 'PUJ', 'Bar', '30-AUG-19', '21:00:00', 30);
insert into itinerary values(31, 'Cortecito_Beach', 'PUJ', 'Beach', '31-AUG-19', NULL, NULL);
insert into itinerary values(32, 'Bávaro', 'PUJ', 'Beach', '1-SEP-19', NULL, NULL);

insert into itinerary values(34, 'Mount_Rainier', 'SEA', 'Mountain', '02-SEP-19', NULL, 30);
insert into itinerary values(35, 'Top_of_Tacoma', 'SEA', 'Bar', '02-SEP-19', '20:00:00', NULL);
insert into itinerary values(36, 'Wapato Park', 'SEA', 'Park', '03-SEP-19', NULL, NULL);
insert into itinerary values(37, 'American_Lake', 'SEA', 'Lake', '04-SEP-19', NULL, NULL);
insert into itinerary values(38, 'Surprise_Lake', 'SEA', 'Lake', '05-SEP-19', NULL, NULL);

insert into itinerary values(39, 'Bávaro', 'PUJ', 'Beach', '18-SEP-19', NULL, NULL);
insert into itinerary values(40, 'Coco_Bongo', 'PUJ', 'Bar', '18-SEP-19', '20:00:00', 40);
insert into itinerary values(41, 'Cortecito_Beach', 'PUJ', 'Beach', '19-SEP-19', 'AM', NULL);


/* Insert data into travelingWith table */
insert into travelingWith values(12345678, 87654321, 1111);
insert into travelingWith values(12345678, 12344321, 1112);
insert into travelingWith values(87654321, 12344321, 1112);

insert into travelingWith values(37373737, 12345678, 2222);
insert into travelingWith values(73737373, 12345678, 3333);


/* Insert data into accommodations table */
insert into accommodations values('Schweizerhof', 'Hotel', 300, 2);
insert into accommodations values('Primavera-Hostel', 'Hostel', 23, 3);
insert into accommodations values('Olarias_26_Lisboa', 'Airbnb', 80, 3);
insert into accommodations values('Emmys_Apartment', 'Apartment', 0, 2);
insert into accommodations values('PRESIDENCIAL_SUITES', 'Airbnb', 79, 2);


/* Insert data into accommodate table */
insert into accommodate values(12345678, 'Schweizerhof', '11-JUN-19', '23:00:00', 11);
insert into accommodate values(12345678, 'Primavera-Hostel', '22-JUN-19', '23:00:00', 8);
insert into accommodate values(12345678, 'Olarias_26_Lisboa', '30-JUN-19', '19:00:00', 7);
insert into accommodate values(87654321, 'Schweizerhof', '11-JUN-19', '23:00:00', 11);
insert into accommodate values(87654321, 'Primavera-Hostel', '22-JUN-19', '23:00:00', 8);
insert into accommodate values(87654321, 'Olarias_26_Lisboa', '30-JUN-19', '19:00:00', 7);

insert into accommodate values(12344321, 'Primavera-Hostel', '22-JUN-19', '23:00:00', 8);

insert into accommodate values(12344321, 'Olarias_26_Lisboa', '30-JUN-19', '19:00:00', 7);



insert into accommodate values(12345678, 'PRESIDENCIAL_SUITES', '27-AUG-19', '21:00:00', 5);

insert into accommodate values(37373737, 'PRESIDENCIAL_SUITES', '27-AUG-19', '21:00:00', 5);
insert into accommodate values(12345678, 'Emmys_Apartment', '02-SEP-19', NULL, 3);

insert into accommodate values(37373737, 'Emmys_Apartment', '02-SEP-19', NULL, 3);


insert into accommodate values(12345678, 'PRESIDENCIAL_SUITES', '17-SEP-19', '18:30:00', 2);
insert into accommodate values(73737373, 'PRESIDENCIAL_SUITES', '17-SEP-19', '18:30:00', 2);


/* Insert data into doing table */
insert into doing values( 00213, 01);
insert into doing values( 00213, 02);
insert into doing values( 00213, 03);
insert into doing values( 00213, 04);
insert into doing values( 00213, 05);
insert into doing values( 00213, 06);
insert into doing values( 00213, 08);
insert into doing values( 00344, 01);
insert into doing values( 00344, 02);
insert into doing values( 00344, 03);
insert into doing values( 00344, 04);
insert into doing values( 00344, 05);
insert into doing values( 00344, 06);
insert into doing values( 00344, 08);

insert into doing values(00654, 09);
insert into doing values(00654, 10);
insert into doing values(00654, 11);
insert into doing values(00654, 12);
insert into doing values(00654, 13);
insert into doing values(00654, 14);
insert into doing values(00654, 15);
insert into doing values(00654, 16);
insert into doing values(00654, 22);

insert into doing values(00345, 22);
insert into doing values(00345, 09);
insert into doing values(00345, 10);
insert into doing values(00345, 11);
insert into doing values(00345, 12);
insert into doing values(00345, 13);
insert into doing values(00345, 14);
insert into doing values(00345, 15);
insert into doing values(00345, 16);

insert into doing values(00653, 22);
insert into doing values(00653, 09);
insert into doing values(00653, 10);
insert into doing values(00653, 11);
insert into doing values(00653, 12);
insert into doing values(00653, 13);
insert into doing values(00653, 14);
insert into doing values(00653, 15);
insert into doing values(00653, 16);

insert into doing values(00254, 17);
insert into doing values(00254, 18);
insert into doing values(00254, 19);
insert into doing values(00254, 20);
insert into doing values(00254, 21);
insert into doing values(00254, 23);
insert into doing values(00254, 24);

insert into doing values(00999, 17);
insert into doing values(00999, 18);
insert into doing values(00999, 19);
insert into doing values(00999, 20);
insert into doing values(00999, 21);
insert into doing values(00999, 23);
insert into doing values(00999, 24);

insert into doing values(00553, 17);
insert into doing values(00553, 18);
insert into doing values(00553, 19);
insert into doing values(00553, 20);
insert into doing values(00553, 21);
insert into doing values(00553, 23);
insert into doing values(00553, 24);

insert into doing values(00788, 25);
insert into doing values(00788, 26);
insert into doing values(00788, 27);
insert into doing values(00788, 28);
insert into doing values(00788, 29);
insert into doing values(00788, 30);
insert into doing values(00788, 31);
insert into doing values(00788, 32);
insert into doing values(00788, 33);

insert into doing values(00949, 25);
insert into doing values(00949, 26);
insert into doing values(00949, 27);
insert into doing values(00949, 28);
insert into doing values(00949, 29);
insert into doing values(00949, 30);
insert into doing values(00949, 31);
insert into doing values(00949, 32);
insert into doing values(00949, 33);


insert into doing values(00788, 34);
insert into doing values(00788, 35);
insert into doing values(00788, 36);
insert into doing values(00788, 37);
insert into doing values(00788, 38);
insert into doing values(00949, 34);
**insert into doing values(00949, 35);
insert into doing values(00949, 36);
insert into doing values(00949, 37);
insert into doing values(00949, 38);

insert into doing values(00771, 39);
insert into doing values(00771, 40);
insert into doing values(00771, 41);
insert into doing values(00905, 39);
**insert into doing values(00905, 40);
insert into doing values(00905, 41);


/* Insert data into going table */
/* Sara Lopez */
insert into going values(12345678, 111);
insert into going values(12345678, 213);
insert into going values(12345678, 219);
insert into going values(12345678, 222);
insert into going values(12345678, 254);
insert into going values(12345678, 267);
insert into going values(12345678, 309);
insert into going values(12345678, 333);
insert into going values(12345678, 334);
insert into going values(12345678, 347);
insert into going values(12345678, 654);
insert into going values(12345678, 666);
insert into going values(12345678, 667);
insert into going values(12345678, 771);
insert into going values(12345678, 777);
insert into going values(12345678, 788);
insert into going values(12345678, 802);
insert into going values(12345678, 881);
insert into going values(12345678, 887);
insert into going values(12345678, 992);

/* Carly Jackson Clark */
insert into going values(87654321, 344);
insert into going values(87654321, 345);
insert into going values(87654321, 999);
insert into going values(87654321, 778);
insert into going values(87654321, 347);
insert into going values(87654321, 267);
insert into going values(87654321, 309);
insert into going values(87654321, 111);
insert into going values(87654321, 219);
insert into going values(87654321, 222);
insert into going values(87654321, 333);
insert into going values(87654321, 334);
insert into going values(87654321, 777);
insert into going values(87654321, 666);

/* Emmy Lopez */
insert into going values(12344321, 653);
insert into going values(12344321, 553);
insert into going values(12344321, 444);
insert into going values(12344321, 100);
insert into going values(12344321, 111);
insert into going values(12344321, 222);
insert into going values(12344321, 333);
insert into going values(12344321, 334);
insert into going values(12344321, 777);
insert into going values(12344321, 666);

/* Kennedy Joseph */
insert into going values(37373737, 949);
insert into going values(37373737, 959);
insert into going values(37373737, 995);
insert into going values(37373737, 690);

/* Dani Fuertes */
insert into going values(73737373, 905);
insert into going values(73737373, 300);
