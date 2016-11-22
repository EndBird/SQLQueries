SET search_path TO bnb, public;



CREATE VIEW requestbyyear AS
select travelerId, CAST(extract(YEAR from startdate) AS integer) as yyyy
from BookingRequest;

CREATE VIEW requestbyyear1 AS 
select travelerId, yyyy
from requestbyyear
where 2006 <= yyyy  AND yyyy <= 2015;

CREATE VIEW bookingbyyear AS
select travelerId, CAST(extract(YEAR from startdate) AS integer) as yyyy
from Booking;

CREATE VIEW bookingbyyear1 AS 
select travelerId, yyyy
from bookingbyyear
where 2006 <= yyyy  AND yyyy <= 2015;


CREATE VIEW bookingbyyearsorted AS
select travelerId, yyyy
from bookingbyyear1
order by travelerId, yyyy;




CREATE VIEW requestbyyearsorted AS
select travelerId, yyyy
from requestbyyear1
order by travelerId, yyyy;

CREATE VIEW yearsofeachtraveller0 AS
select travelerId, yyyy
from (select * from requestbyyearsorted) c UNION (select * from bookingbyyearsorted)
order by travelerId, yyyy;

CREATE VIEW yearsofnontraveller AS
select travelerId, CAST(null as integer) as yyyy
from (select travelerId, null as yyyy from Traveler) c EXCEPT (select travelerId, null as yyyy from yearsofeachtraveller0);

CREATE VIEW yearsofeachtraveller AS
select distinct travelerId, yyyy
from (select * from yearsofnontraveller) c UNION (select * FROM yearsofeachtraveller0);




CREATE VIEW joinOfTravelersandYears AS
select Traveler.travelerId, email, yyyy as year, 0 AS numRequests, 0 AS numBooking
from Traveler NATURAL JOIN yearsofeachtraveller;

CREATE VIEW findingnumRequests AS
select joinOfTravelersandYears.travelerId, joinOfTravelersandYears.email, joinOfTravelersandYears.year, joinOfTravelersandYears.numRequests + count(requestbyyearsorted.yyyy) as numRequests, joinOfTravelersandYears.numBooking
from (joinOfTravelersandYears left join requestbyyearsorted on (joinOfTravelersandYears.travelerId = requestbyyearsorted.travelerId and
        joinOfTravelersandYears.year = yyyy)) 
group by joinOfTravelersandYears.travelerId, joinOfTravelersandYears.email, joinOfTravelersandYears.year, joinOfTravelersandYears.numRequests, joinOfTravelersandYears.numBooking;

CREATE VIEW findingnumBookings AS
select findingnumRequests.travelerId, findingnumRequests.email, findingnumRequests.year, findingnumRequests.numRequests, findingnumRequests.numBooking + count(bookingbyyearsorted.yyyy) as numBooking
from (findingnumRequests left join bookingbyyearsorted on (findingnumRequests.travelerId = bookingbyyearsorted.travelerId and
        findingnumRequests.year = yyyy))
group by findingnumRequests.travelerId, findingnumRequests.email, findingnumRequests.year, findingnumRequests.numRequests, findingnumRequests.numBooking;

select *
from findingnumBookings
order by year desc, travelerId asc;

