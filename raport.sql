/*RAPORT*/

select * from rental order by inventory_id;
select * from rental order by rental_date desc;
select * from inventory;
select * from staff;
select a.*, b.store_id from rental as a left  join inventory as b on a.inventory_id=b.inventory_id;

/*1 new rentals by date from store 1*/

create view new_rentals as
select  DATE_TRUNC('day', rental_date) AS ddate, count (rental_id) as new_rentals 
from (select a.*, b.store_id from rental as a, staff as b where a.staff_id=b.staff_id and store_id = 1) as ren_staff 
GROUP BY ddate order by ddate ;

select * from new_rentals;

/*2 active rentals by date from store 1*/

create view active_rentals as
select ddate, count(ddate) as active_rentals from (select a.*,  b.store_id 
												   from (select *, DATE_TRUNC('day',rental_date) as rd 
														 from rental) as a, staff as b where a.staff_id=b.staff_id and store_id=1) as aa 
right join (select distinct DATE_TRUNC('day', rental_date) AS ddate from rental ) as b 
on ddate<(case when aa.return_date is null then ddate+ interval '1' day 
		  else aa.return_date end) and ddate>=aa.rd group by ddate order by ddate;

/* 3 rented titles from store 1*/

create view rented_titles as
select ddate, count(distinct film_id) as rented_titles  from ((select a.*,  b.store_id from 
 ((select *, DATE_TRUNC('day',rental_date) as rd from rental) as a join staff as b 
 on a.staff_id=b.staff_id and store_id=1)) as aa 
 right join (select distinct DATE_TRUNC('day', rental_date) AS ddate from rental ) as bb 
on ddate<(case when aa.return_date is null then ddate+ interval '1' day 
		  else aa.return_date end) and ddate>=aa.rd )  as aaa  join inventory as bbb on aaa.inventory_id=bbb.inventory_id group by ddate  order by ddate;

select * from rented_titles;

/*4 rental_customers from store 1*/
select * from rental order by rental_date;

create view  customer_with_rentals as
select ddate, count(distinct customer_id) as customer_with_rentals  from ((select a.*,  b.store_id from 
 ((select *, DATE_TRUNC('day',rental_date) as rd from rental) as a join staff as b 
 on a.staff_id=b.staff_id and store_id=1)) as aa 
right join (select distinct DATE_TRUNC('day', rental_date) AS ddate from rental ) as bb 
on ddate<(case when aa.return_date is null then ddate+ interval '1' day 
		  else aa.return_date end) and ddate>=aa.rd) group by ddate order by ddate;

/*5 rentals>10days from store 1*/
select (return_date-rental_date) as rental_length  from rental  where (return_date-rental_date)>'9 day' ;

create view  rentals_over_10days as
select ddate, count(return_date-ddate) as rentals_over_10days  
from ((select a.*,  b.store_id from 
 ((select *, DATE_TRUNC('day',rental_date) as rd from rental) as a join staff as b 
on a.staff_id=b.staff_id and store_id=1)) as aa 
left join (select distinct DATE_TRUNC('day', rental_date) AS ddate from rental ) as bb 
on ddate<(case when aa.return_date is null then ddate+ interval '1' day else aa.return_date end) and ddate>=aa.rd)  
where (DATE_TRUNC('day', return_date)-ddate) >'10 days' group by ddate order by ddate;

/*SOLUTION*/
create view date as
select distinct to_char(DATE_TRUNC('day',rental_date), 'YYYY-MM-DD') 
as date, DATE_TRUNC('day',rental_date) as ddate from rental order by date;

create view raport as
select date.date, new_rentals.new_rentals, 
active_rentals.active_rentals, rented_titles.rented_titles,
customer_with_rentals.customer_with_rentals, COALESCE(rentals_over_10days.rentals_over_10days, 0) 
as rentals_over_10days
from date
left join new_rentals on new_rentals.ddate=date.ddate
left join active_rentals on active_rentals.ddate=new_rentals.ddate
left join rented_titles on rented_titles.ddate=active_rentals.ddate
left join customer_with_rentals on customer_with_rentals.ddate = rented_titles.ddate
left join rentals_over_10days on rentals_over_10days.ddate=customer_with_rentals.ddate
;

select * from raport;


