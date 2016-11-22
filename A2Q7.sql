SET search_path TO bnb, public;

CREATE VIEW joinlistwbr AS
select listingId, Price as broffer
from listing NATURAL JOIN Booking;

CREATE VIEW sumtototal AS
select listingId,sum(broffer) as totalbroffer
from joinlistwbr
group by listingId;

CREATE VIEW listNights AS
select listingId, sum(numNights) as totalNumNights
from listing NATURAL JOIN Booking
group by listingId;

CREATE VIEW avgpriceperlisting AS
select listingId, totalbroffer*(1.0)/totalNumNights as avglistingprice
from sumtototal NATURAL JOIN listNights;

CREATE VIEW jointravelerwbookings AS
select travelerID
from Traveler NATURAL JOIN Booking NATURAL JOIN avgpriceperlisting
where  (avglistingprice-Booking.price)*100.0/avglistingprice >=25
group by travelerID
having count(distinct listingId) >=3;

CREATE VIEW travelersbargain AS
select travelerID, Booking.listingId, (avglistingprice-Booking.price)*100.0/avglistingprice as bargain
 from jointravelerwbookings NATURAL JOIN Booking NATURAL JOIN avgpriceperlisting;




CREATE VIEW findlargstbargain AS
select travelerID, max(bargain) as largestBargainPercentage
from jointravelerwbookings NATURAL JOIN travelersbargain
group by travelerID;

select distinct travelersbargain.travelerID,  ceil(bargain)::int as largestBargainPercentage, listingId
from travelersbargain JOIN findlargstbargain on travelersbargain.travelerID = findlargstbargain.travelerID and bargain = largestBargainPercentage
order by ceil(bargain)::int DESC, travelersbargain.travelerID ASC, listingId ASC;  











