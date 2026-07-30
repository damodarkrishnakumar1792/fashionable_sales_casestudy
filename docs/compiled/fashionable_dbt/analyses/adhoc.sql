--Query 1
select count(*) from 
(    select
        order_id,
        min(order_date)                                        as order_date,
        count(*)                                                as line_item_count,
        -- Distinct product_sk, not distinct sku
        count(distinct product_sk)                              as distinct_product_count,
        sum(case when not is_cancelled then quantity end)       as total_units,
        sum(case when not is_cancelled then amount end)         as order_total_amount,
        sum(case when is_cancelled then 1 else 0 end)           as cancelled_line_count

    from main_core.fct_order_lines
    group by order_id ) ;
	
--Query 2	
select 
sales_channel,ship_service_level,
style,category, size,asin,courier_status,quantity, currency_code,
amount,ship_city,ship_state, ship_country
from main_staging.stg_fashionable_sales where order_id = '407-8364731-6449117';

--Query 3
select a.sku,b.sku,b.product_sk from 
main_intermediate.int_sales_enriched a 
left join main_core.dim_product b
on a.sku = b.sku limit 5;

--Query 4
with source_count as (
    select count(*) as row_count
    from main_intermediate.int_sales_enriched
),

fact_count as (
    select count(*) as row_count
    from main_core.fct_order_lines
)
select
		source_count.row_count as source_row_count,
		fact_count.row_count   as fact_row_count
	from source_count
	cross join fact_count
	where source_count.row_count != fact_count.row_count;

--Query 5
select *
from main_core.fct_order_lines
where is_cancelled
  and amount is not null;
		
--Query 6	
select *
from main_core.fct_order_lines
where not is_cancelled
  and (quantity is null or quantity <= 0);