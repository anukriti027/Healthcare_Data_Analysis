select *
from healthcare

--1.How many total patient records are in the dataset?
select count(admission_id) as total_admissions
from healthcare

--2.What is the average billing amount for each admission type?
select Admission_type, avg(billing_amount) as Average_billing_amount
from healthcare
group by Admission_type

--3.What is the distribution of blood group among patients?
select blood_group, count(name)as Total_patients
from healthcare
group by blood_group

--4.How many admissions occurred each month in the year 2024?
select datepart(mm,admission_date) as Month_of_2024, count(admission_id) as Total_admission
from healthcare
where datepart(yy,admission_date)='2024'
group by datepart(mm,admission_date)
order by Month_of_2024 

--5.What is the average length of stay for patients grouped by their medical condition?
select Medical_condition,avg(datediff(day,admission_date, discharge_date)) as Average_length_of_stay
from healthcare
group by medical_condition

--6.What is the total billing amount per insurance provider?
select Insurance_provider, sum(billing_amount) as Total_billing_amount
from healthcare
group by insurance_provider

--7.Who are the top 5 doctors by total billing amount?
select top 5 Doctor, sum(billing_amount) as Total_billing_amount
from healthcare
group by doctor
order by total_billing_amount desc

--8.Which patients have been admitted more than once?
select name
from healthcare
group by name
having (count(admission_id)<> 1)

--9.What is the average billing amount for each diagnosis (medical condition)?
select Medical_condition, avg(billing_amount) as Avg_billing_amount
from healthcare
group by medical_condition

--10.Rank hospitals by their total billing amount using window functions.
select Hospital, 
sum(billing_amount) as total_billing_amount,
rank() over(order by sum(billing_amount) desc) as Rank
from healthcare
group by hospital

--11.Which patients had a greater than 50% increase in average length of stay year-over-year?
select * from healthcare;
with cte as (
	select name,
	year(admission_date) as year_adm,
	avg(datediff(day, admission_date, discharge_date))
	from healthcare
)

--12.Identify patients who were readmitted within 30 days of their previous discharge.

with cte as (select name, admission_date,
discharge_date,
row_number() over(partition by name order by admission_date) as rank1
FROM healthcare ),

prev as (select c1.name, 
c1.discharge_date as prev_discharge_dt ,c2.admission_date 
from cte c1
join cte c2
on c1.name = c2.name
and c1.rank1 = c2.rank1 + 1)

select name,
datediff(day, admission_date, prev_discharge_dt) as difference_hai_bhotnike
from prev
where datediff(day, admission_date, prev_discharge_dt) >0
and datediff(day, admission_date, prev_discharge_dt) < 30

--13.Flag Readmissions Based on Length of Stay
/*Question:
Use CASE WHEN to label each patient record as:
'Short Stay' if Length of Stay < 3 days
'Normal Stay' if between 3 and 7 days
'Long Stay' if > 7 days*/

select name, admission_date, discharge_date, 
case when datediff(day, admission_date,discharge_date ) < 3 THEN 'Short'
when datediff(day, admission_date,discharge_date) between 3 and 7 THEN 'Normal'
when datediff(day, admission_date,discharge_date) > 7 THEN 'Long'
end as length
from healthcare


13. Find the average billing amount for each hospital and compare it with the overall average billing. Show only hospitals that bill above average.
14. Identify the most common medical condition treated by each doctor.
15. For each patient, calculate the total number of days spent in hospital across all admissions. List the top 10 patients who spent the most days.
16. Find patients who have been admitted to more than one hospital.

