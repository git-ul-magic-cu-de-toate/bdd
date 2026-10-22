   set SERVEROUTPUT on;

-- //  Daca furnizorul (supplier-ul) a livrat produse in cel putin 10 regiuni distincte. Afisati "Da" sau "Nu".(2p)

declare
   cursor c_regiuni is
   select supplierid,
          count(*) as nr_regiuni
     from (
      select distinct s.supplierid,
                      o.shipregion
        from suppliers s
        join products p
      on s.supplierid = p.supplierid
        join order_details od
      on p.productid = od.productid
        join orders o
      on od.orderid = o.orderid
       where o.shipregion is not null
   )
    group by supplierid;

   regiuni_row c_regiuni%rowtype;
begin
   open c_regiuni;
   loop
      fetch c_regiuni into regiuni_row;
      exit when c_regiuni%notfound;
      if regiuni_row.nr_regiuni >= 10 then
         dbms_output.put_line('SUPPLIER CU ID: '
                              || regiuni_row.supplierid
                              || ' NR REGIUNI: '
                              || regiuni_row.nr_regiuni
                              || ' DA');
      else
         dbms_output.put_line('SUPPLIER CU ID: '
                              || regiuni_row.supplierid
                              || ' NR REGIUNI: '
                              || regiuni_row.nr_regiuni
                              || ' NU');
      end if;

   end loop;

   close c_regiuni;
end;

-- select supplierid,
--        case
--           when count(*) >= 10 then
--              'DA'
--           else
--              'NU'
--        end as pestezecereg
--   from (
--    select distinct s.supplierid,
--                    o.shipregion
--      from suppliers s
--      join products p
--    on s.supplierid = p.supplierid
--      join order_details od
--    on p.productid = od.productid
--      join orders o
--    on od.orderid = o.orderid
--     where o.shipregion is not null
-- )
--  group by supplierid
--  order by supplierid;