SET search_path TO bnb, public;

CREATE VIEW listingswithcity AS 
select Listing.*, regulationType, days
from Listing JOIN CityRegulation on (Listing.city = CityRegulation.city and (Listing.propertyType = CityRegulation.propertyType OR CityRegulation.propertyType IS NULL));

CREATE VIEW listingwcitywbooking AS
select listingswithcity.*, startdate, numNights
from listingswithcity NATURAL JOIN Booking
order by listingID, startdate;

CREATE VIEW invalidlistingwcitywbooking AS 
select Distinct listingwcitywbooking.listingID
from listingwcitywbooking JOIN Booking on listingwcitywbooking.listingID = Booking.listingID AND listingwcitywbooking.startdate <> Booking.startdate 
where listingwcitywbooking.startdate + (listingwcitywbooking.numNights-1)*INTERVAL'1 day' >= Booking.startdate AND Booking.startdate > listingwcitywbooking.startdate;

CREATE VIEW validlistingwcitywbooking AS
select listingwcitywbooking.*
from listingwcitywbooking  JOIN (select * from (select listingID from listingwcitywbooking) g EXCEPT (select listingID from invalidlistingwcitywbooking)) h ON listingwcitywbooking.listingID = h.listingID;
order by listingID;



CREATE VIEW criminallistwmin AS
select distinct listingID, extract(year from startdate) as year
from validlistingwcitywbooking
where regulationType = 'min' and days > validlistingwcitywbooking.numNights;


CREATE VIEW remainders AS
select *
from (select * from validlistingwcitywbooking) g EXCEPT (select validlistingwcitywbooking.* from validlistingwcitywbooking JOIN criminallistwmin on validlistingwcitywbooking.listingID = criminallistwmin.listingID and extract(year from validlistingwcitywbooking.startdate) = criminallistwmin.year);

CREATE VIEW 2spanningBookingswithMax AS
select listingID, extract(year from startdate) as year1, DATE_PART('day', CAST(extract(year from (startdate + (numNights-1)*INTERVAL'1 day'))::text||'-01-01' as date) - startdate) as yr1days, extract(year from (startdate + (numNights-1)*INTERVAL'1 day')) as year2,
numNights - DATE_PART('day', CAST(extract(year from (startdate + (numNights-1)*INTERVAL'1 day'))::text||'-01-01' as date) - startdate) as yr2days
from remainders
where extract(year from (startdate + (numNights-1)*INTERVAL'1 day')) - extract(year from startdate) = 1 and regulationType = 'max';

CREATE VIEW 3spanningBookingswithMax AS
select listingID, extract(year from startdate) as year1, DATE_PART('day', CAST(extract(year from (startdate + (numNights-1-365)*INTERVAL'1 day'))::text||'-01-01' as date) - startdate) as yr1days, extract(year from (startdate + (numNights-1)*INTERVAL'1 day')) as year2,
365 as yr2days, numNights - 365 - DATE_PART('day', CAST(extract(year from (startdate + (numNights-1-365)*INTERVAL'1 day'))::text||'-01-01' as date) - startdate) as yr3days
from remainders
where extract(year from (startdate + (numNights-1)*INTERVAL'1 day')) - extract(year from startdate) = 2 and regulationType = 'max';









