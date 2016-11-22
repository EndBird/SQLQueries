SET search_path TO bnb, public;

CREATE VIEW reciprocals AS 
select TravelerRating.*, HomeownerRating.rating as ownerrating
from TravelerRating JOIN HomeownerRating ON TravelerRating.listingID = HomeownerRating.listingID and TravelerRating.startdate = HomeownerRating.startdate;

CREATE VIEW numrecipricals AS
select travelerID,count(ownerrating) as reciprocals
from reciprocals NATURAL JOIN Booking
group by travelerID;


CREATE VIEW diffbyone AS
select travelerID, count(rating) as backScratches 
from reciprocals NATURAL JOIN Booking
where @(rating - ownerrating) <=1
group by travelerID;


CREATE VIEW haveboth AS
select *
from numrecipricals NATURAL JOIN diffbyone;

CREATE VIEW nodiffby AS
select *
from (select travelerID from numrecipricals) g EXCEPT (select travelerID from diffbyone);

CREATE VIEW nodiffbywback AS
select travelerID, reciprocals, 0 as backScratches
from numrecipricals NATURAL JOIN nodiffby;

CREATE VIEW travelerwnone AS
select travelerID, 0 as reciprocals, 0 as backScratches
from (select travelerId as travelerID from Traveler) g EXCEPT (select travelerID from numrecipricals);

select *
from ((select * from haveboth) g UNION (select * from nodiffbywback)) h UNION (select * from travelerwnone);