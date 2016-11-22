SET search_path TO bnb, public;

CREATE VIEW jointravelerrateswlisting AS
select *, extract(year from startdate)::int as year
from TravelerRating NATURAL JOIN Listing
order by owner;

CREATE VIEW activeowners AS
select owner as homeownerId
from jointravelerrateswlisting;

CREATE VIEW noratedowners1 AS
select homeownerId as owner
from (select homeownerId from Homeowner) g EXCEPT (select homeownerId from activeowners);

CREATE VIEW noratedowners AS
select owner, null as r5, null as r4, null as r3, null as r2, null as r1
from noratedowners1;

CREATE VIEW fivestarcount AS
select owner, count(rating) as r5
from jointravelerrateswlisting
where rating = 5
group by owner;

CREATE VIEW fourstarcount AS
select owner, count(rating) as r4
from jointravelerrateswlisting
where rating = 4
group by owner;

CREATE VIEW threestarcount AS
select owner, count(rating) as r3
from jointravelerrateswlisting
where rating = 3
group by owner;

CREATE VIEW twostarcount AS
select owner, count(rating) as r2
from jointravelerrateswlisting
where rating = 2
group by owner;

CREATE VIEW onestarcount AS
select owner, count(rating) as r1
from jointravelerrateswlisting
where rating = 1
group by owner;

select owner as homeownerId, r5, r4,  r3, r2, r1
from (select * from fivestarcount NATURAL left join fourstarcount NATURAL left join threestarcount NATURAL left join twostarcount NATURAL left join onestarcount) g UNION
(select *  from noratedowners)
order by r5 DESC, r4 DESC, r3 DESC, r2 DESC, r1 DESC, owner ASC;
