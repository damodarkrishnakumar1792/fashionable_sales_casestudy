
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    fulfilment_sk as unique_field,
    count(*) as n_records

from "fashionable"."main_core"."dim_fulfilment"
where fulfilment_sk is not null
group by fulfilment_sk
having count(*) > 1



  
  
      
    ) dbt_internal_test