SET search_path TO bnb, public;

CREATE VIEW jointravelerrateswlisting AS
select *, extract(year from startdate)::int as year
from TravelerRating NATURAL JOIN Listing
order by owner;

CREATE VIEW ownerinlastTen AS
select distinct owner
from jointravelerrateswlisting
where 2015 >= extract(year from startdate)::int AND extract(year from startdate)::int >= 2006;

CREATE VIEW relevantownerdata AS
select owner, year, avg(rating) as yearavg
from jointravelerrateswlisting NATURAL JOIN ownerinlastTen
group by owner, year;


CREATE VIEW decliningowners
select distinct relevantownerdata.owner
from relevantownerdata JOIN relevantownerdata g ON relevantownerdata.owner = g.owner and relevantownerdata.year < g.year
where relevantownerdata.yearavg > g.yearavg;

CREATE VIEW nondecowners AS 
select owner
from (select distinct owner from relevantownerdata) g EXCEPT (select owner from decliningowners);

select (count(distinct nondecowners.owner)/(count(distinct nondecowners.owner) + count(distinct decliningowners.owner)))::int
from nondecowners JOIN decliningowners;




