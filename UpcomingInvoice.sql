select 
    c.id
    ,s.id
    ,c.name
    ,si.plan_interval
    ,cast(s.current_period_end as date) as "current_period_end"
    ,sum(si.plan_amount / 100) as "plan_amount"
    ,cast(sum(si.plan_amount / 100) - case
        when cp.percent_off is null and cp.amount_off is not null then (cp.amount_off / 100)
        when cp.percent_off is not null and cp.amount_off is null then ((sum(si.plan_amount) * ((cp.percent_off / 100))) / 100)
        else 0
        end as bigint) as "net_amount"
    ,(i.amount_due / 100) as "last_invoice_amount"
    ,s.status
from customers c
    left join subscriptions s
        on s.customer_id = c.id
    left join subscription_items si
        on si.subscription_id = s.id
    left join coupons cp
        on s.discount_coupon_id = cp.id
    left join (select customer_id, max(date) as "latest_invoice_date" from invoices group by customer_id) ii
        on ii.customer_id = c.id
    left join invoices i
        on i.customer_id = ii.customer_id and i.date = ii.latest_invoice_date
where s.status is not null
group by 
    c.id
    ,s.id
    ,c.name
    ,si.plan_interval
    ,s.current_period_end
    ,i.amount_due
    ,cp.amount_off
    ,cp.percent_off
    ,s.status
order by c.name asc