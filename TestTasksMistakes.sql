--1. Вывести топ-3 клуба с самой дорогой защитой (Defender-*)
select top 3 
       club
  from (select club,
               sum(price) as AmtDef
          from v_ovechkin.Test_Task
         where position like 'Defender -%'
         group by club)
order by AmtDef desc


--8.Посчитать, в какой команде раньше всего закончится контракт у 5 игроков
with contractExpires as (
select club, 
       min(contract_expires) as MinDate, 
       max(Cnt) as MaxCnt
  from (select club,
               contract_expires,
               Rank() over(partition by club order by contract_expires) as Rnk,
               count()                                                  as Cnt
          from v_ovechkin.Test_Task
         where contract_expires != '1970-01-01'
         group by club, contract_expires)
 where Rnk <= 5
 group by club)
select top 1
       club
  from contractExpires
 order by MinDate, MaxCnt desc



--9. В каком возрасте игроки, в основном, выходят на пик своей зарплаты
select top 1
       age
  from (select age,
               count() as Cnt 
          from v_ovechkin.Test_Task
         where price = max_price
         group by age)
 order by Cnt desc, age