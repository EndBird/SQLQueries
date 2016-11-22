SET search_path TO bnb, public;

CREATE VIEW travelersbookings AS
select travelerID, count(distinct listingId) as bookings
from Traveler join Booking a on Traveler.travelerID = Booking.travelerID
group by travelerID;

CREATE VIEW travelersbookingsrequest AS
select travelerID, count(distinct listingId) as bookrequests
from Traveler join BookingRequest a on Traveler.travelerID = BookingRequest.travelerID
group by travelerID;

select travelerID, travelersbookings.surname, bookings as numListings
from travelersbookings NATURAL JOIN travelersbookingsrequest
where bookings = bookrequests
order by travelerID;


