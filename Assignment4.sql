/***********************************************
** File: Assignment4.sql
** Desc: Assignment 4
** Auth: Janmejay Dwivedi
** Date: 06/28/2018
************************************************/
use sakila;
########################## PROBLEM 1 ##########################
# a) List all customers that live in the Nepal?

select concat(c.first_name,' ',c.last_name) CustomerName
from customer c
join address a on c.address_id=a.address_id
join city on a.city_id=city.city_id
join country co on city.country_id=co.country_id
where co.country='Nepal';

# b) List all actors that appear in the movie titled Academy Dinosaur.

select concat(a.first_name,' ',a.last_name) ActorName
from actor a 
join film_actor fa on a.actor_id=fa.actor_id
join film f on fa.film_id=f.film_id
where f.title='ACADEMY DINOSAUR';

# c) What is the revenue generated by each employee ?

select concat(s.first_name,' ',s.last_name) Employee,sum(p.amount) revenue
from staff s
join payment p on s.staff_id=p.staff_id
group by s.first_name,s.last_name;

# d) List top 10 customers that rented the most movies.

select concat(c.first_name,' ',c.last_name) Customername
from payment p 
join customer c on p.customer_id=c.customer_id
group by c.first_name,c.last_name
order by sum(amount) desc
limit 10;

# e) List the inventory available in store to rent for each of the movies

select i.inventory_id,f.title 
from inventory i
join store st on i.store_id=st.store_id
join film f on i.film_id=f.film_id
left join rental r on i.inventory_id=r.inventory_id
where nullif(r.return_date,now()) <= now();

# f) List the top zipcodes that have the highest rental activity

select postal_code 
from (	select a.postal_code,count(r.rental_id) ra
		from rental r
		join customer c on r.customer_id=c.customer_id
		join address a on c.address_id=a.address_id
		group by a.postal_code
	) x
where x.ra=(
				select max(r) from (
				select a.postal_code,count(r.rental_id) r
				from rental r
				join customer c on r.customer_id=c.customer_id
				join address a on c.address_id=a.address_id
				group by a.postal_code
				) y 
            );

########################## PROBLEM 2 ##########################

# Note: For questions a, b, c below use a single query with a sub query
# a) List actors and customers whose first name is the same as the first name of the actor with ID 8

select concat(c.first_name, ' ', c.last_name) CustomerName
from customer c
where c.first_name=(	select first_name 
						from actor 
						where actor_id=8
					);

# b) List customers and payment amounts, with payments greater than average payment amount

select concat(c.first_name, ' ', c.last_name) CustomerName,p.amount
from customer c
join payment p on c.customer_id=p.customer_id
where p.amount>(select avg(amount) 
				from payment
			    );

# c) List customers who have rented movies at least once

select concat(c.first_name, ' ', c.last_name) CustomerName
from customer c 
where c.customer_id in (	select customer_id 
						from rental r 
					);

# Note: use IN clause with the sub query
# d) Find the floor of the maximum, minimum and average payment amount

select floor(max(amount)) MaxAmt, floor(min(amount)) MinAmt, floor(Avg(amount)) AvgAmt
from payment;

########################## PROBLEM 3 ##########################

# a) Create a view called actors_portfolio which contains information about actors
# and films ( including titles and category).

CREATE view actors_portfolio
as
select fa.actor_id,a.first_name ActorFName, a.last_name ActorLName,
       f.title,f.description,c.name category,f.release_year,
	   l.name language,f.rating,f.special_features
from film_actor fa  
 join film f on f.film_id=fa.film_id
 join actor a on fa.actor_id=a.actor_id
 join language l on f.language_id=l.language_id
join film_Category fc on f.film_id=fc.film_id
join category c on fc.category_id=c.category_id
order by fa.actor_id;

# b) Describe the structure of the view and query the view to get information on the actor ADAM GRANT

describe actors_portfolio;

select * 
from actors_portfolio 
where actor='ADAM GRANT';

# c) Insert a new movie titled Data Hero in Sci-Fi Category starring ADAM GRANT
# Note: If you see an error, explain why this is not permitted
#Ans if we are trying to insert record into view then

insert into actors_portfolio (actor_id,ActorFName,ActorLName,title,description,category,release_year,language,rating,special_features)
values(71,'ADAM', 'GRANT','Data Hero','Data Hero','Sci-Fi','2018','English','G','Testing');

#The above script shows error "Error Code: 1393. Can not modify more than one base table through a join view 'sakila.actors_portfolio'"
#The reason is that view is logical object and doesn't have any physical existance of its own. 
# The query mentioned below will insert data directly into the respective table.

insert into film(title,description,release_year,language_id,rental_duration,replacement_cost) 
values ('Data Hero','Data Hero','2018',1,4.50,21.06);

insert into film_actor(actor_id,film_id)
select 71, film_id
from film 
where title='Data Hero';

insert into film_Category(film_id,category_id)
select film_id,14
from film 
where title='Data Hero';

########################## PROBLEM 4 (Optional) ##########################

# a) Extract the street number ( characters 1 through 4 ) from customer addressLine1

select substring(a.address,1,POSITION(' ' in a.address)-1) StreetNo
from customer c
join address a on c.address_id= a.address_id;

# b) Find out actors whose last name starts with character A, B or C.

select first_name,last_name 
from actor 
where (last_name like 'A%' or last_name like 'B%' or last_name like 'C%');

# c) Find film titles that contains exactly 10 characters

select title 
from film 
where length(rtrim(ltrim(title)))=10;

# d) Format a payment_date using the following format e.g "22/1/2016"

select replace(DATE_FORMAT(payment_date,"%d %c %Y"),' ','/') payment_date
from payment;

# e) Find the number of days between two date values rental_date & return_date

select datediff(return_date,rental_date) 
from rental;