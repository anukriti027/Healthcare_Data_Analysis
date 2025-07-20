select *
from healthcare;

--1.How many total patient records are in the dataset?
select count(admission_id) as total_admissions
from healthcare;

--2.What is the average billing amount for each admission type?
select Admission_type, avg(billing_amount) as Average_billing_amount
from healthcare
group by Admission_type;

--3.What is the distribution of blood group among patients?
select blood_group, count(name)as Total_patients
from healthcare
group by blood_group;

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
select Name
from healthcare
group by Name
having (count(admission_id)<> 1)

--9.What is the average billing amount for each diagnosis (medical condition)?
select Medical_condition, avg(billing_amount) as Avg_billing_amount
from healthcare
group by medical_condition

--10.Rank hospitals by their total billing amount using window functions.
select Hospital, 
sum(billing_amount) as Total_billing_amount,
rank() over(order by sum(billing_amount) desc) as Rank
from healthcare
group by hospital

--11.Which patients had a greater than 50% increase in average length of stay year-over-year?
with yearly_stay as (
    select name,
           datepart(year,Admission_date) as year,
           avg(datediff(day, Admission_date, Discharge_date)) as avg_stay
    from Healthcare
    group by name, datepart(year,Admission_date)
),
stay_diff as (
    select curr.name,
           curr.year as current_year,
           prev.avg_stay as prev_avg,
           curr.avg_stay as curr_avg,
           ((curr.avg_stay - prev.avg_stay) * 1.0 / nullif(prev.avg_stay, 0)) as pct_increase
    from yearly_stay curr
    join yearly_stay prev
      on curr.name = prev.name AND curr.year = prev.year + 1
)
select name, current_year, prev_avg, curr_avg, pct_increase
from stay_diff
where pct_increase > 0.5;


--12.Identify patients who were readmitted within 30 days of their previous discharge.

with cte as (select Name, admission_date,
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
datediff(day, admission_date, prev_discharge_dt) as No_of_days_bw_hospitaization
from prev
where datediff(day, admission_date, prev_discharge_dt) >0
and datediff(day, admission_date, prev_discharge_dt) < 30

--13.Flag Readmissions Based on Length of Stay
/*Question:
Use CASE WHEN to label each patient record as:
'Short Stay' if Length of Stay < 3 days
'Normal Stay' if between 3 and 7 days
'Long Stay' if > 7 days*/

select Name, Admission_date, Discharge_date, 
case when datediff(day, admission_date,discharge_date ) < 3 THEN 'Short'
when datediff(day, admission_date,discharge_date) between 3 and 7 THEN 'Normal'
when datediff(day, admission_date,discharge_date) > 7 THEN 'Long'
end as Length_of_hospitalization
from healthcare




