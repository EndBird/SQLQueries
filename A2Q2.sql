SET search_path TO bnb, public;

CREATE VIEW numBookingsRequest AS 
select count(requestId) as numRequest
from BookingRequest;

CREATE VIEW numTravelers AS 
select count(travelerId) as numTraveler
from Traveler;

CREATE VIEW avgrequest AS 
select numRequest/numTraveler as avg
from numBookingsRequest, numTravelers;

CREATE VIEW noBookingPeople AS
select travelerId
from (select travelerId from Traveler) c EXCEPT (select travelerId from Booking);

CREATE VIEW potentialScrapers AS 
select distinct travelerId
from BookingRequest 
group by travelerId
having count(travelerId) > 10*(select avg from avgrequest);

CREATE VIEW scrapers AS 
select travelerId
from (select * from noBookingPeople) g INTERSECT (select * from potentialScrapers);

CREATE VIEW scraperPI AS
select travelerId, firstname||' '||surname as name, email
from Traveler NATURAL JOIN scrapers;

CREATE VIEW replacenullEmails AS
select travelerId, name, 'unknown' as email
from (select * from scraperPI where email IS NULL) g;

CREATE VIEW notnullEmails AS
select travelerId, name, email
from (select * from scraperPI where email IS NOT NULL) g;

CREATE VIEW infowithunknownemails AS
select travelerId, name, email
from (select * from notnullEmails) g UNION (select * from replacenullEmails);

CREATE VIEW BookingRequestwithListing AS
select * 
from BookingRequest NATURAL JOIN Listing;

CREATE VIEW possiblemostRCity AS
select travelerId, name, email, count(city) as numRequestedCity, city as cityname
from infowithunknownemails NATURAL JOIN BookingRequestwithListing
group by travelerId, name, email, city;

CREATE VIEW notmostRCity AS 
select distinct possiblemostRCity.travelerId, possiblemostRCity.name, possiblemostRCity.email, possiblemostRCity.numRequestedCity, possiblemostRCity.cityname
from possiblemostRCity join possiblemostRCity g on possiblemostRCity.travelerId = g.travelerId 
where possiblemostRCity.numRequestedCity < g.numRequestedCity;

CREATE VIEW nummostRCity AS
select distinct travelerId, name, email, numRequestedCity, cityname
from (select * from possiblemostRCity) g EXCEPT (select * from notmostRCity);

CREATE VIEW citylist AS 
select distinct travelerId, name, email, cityname as mostRequestedCity
from nummostRCity g
where cityname = (select cityname from nummostRCity where g.travelerId = nummostRCity.travelerId order by cityname LIMIT 1);

select travelerId, name, email, mostRequestedCity, count(travelerId) as numRequests
from citylist NATURAL JOIN BookingRequestwithListing 
group by travelerId, name, email,mostRequestedCity;









