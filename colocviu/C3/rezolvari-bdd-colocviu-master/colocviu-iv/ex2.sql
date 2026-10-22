-- PT FIECARE ANGAJAT CEL MAI MARE DISCOUNT IN BANI (ORDERS SI ORDER_DETAILS E ONE TO MANY)

with sume_discount as (
   select e.employeeid,
          o.orderid,
          sum(od.unitprice * od.quantity * od.discount) as suma_discount
     from employees e
     join orders o
   on e.employeeid = o.employeeid
     join order_details od
   on od.orderid = o.orderid
    group by o.orderid,
             e.employeeid
    order by employeeid
)
select g.employeeid,
       g.orderid,
       g.suma_discount
  from sume_discount g
  join (
   select employeeid,
          max(suma_discount) as max_discount
     from sume_discount
    group by employeeid
) max_sums
on g.employeeid = max_sums.employeeid
   and g.suma_discount = max_sums.max_discount;