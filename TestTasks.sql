--1. Вывести топ-3 клуба с самой дорогой защитой (Defender-*)
select top 3 *
  from bundesliga_player
 where position like 'Defender -%'
 order by price desc


--2. В разрезе клуба и игрока посчитать, сколько игроков подписало контракт с клубом после него
select club,
       name,
       Rnk -1 as CntPlayers
  from (select club, 
       name, 
       RANK() over(partition by club order by joined_club desc) as Rnk
  from bundesliga_player
 group by club, name, joined_club)

 
--3. Выбрать клубы, где средняя стоимость французских игроков больше 5 млн 
select club
  from bundesliga_player
 where nationality = 'France'
 group by club
having avg(price) > 5


--4. Выбрать клубы, где доля немцев выше 90%
select club
  from bundesliga_player
 group by club
having (countIf(id, nationality = 'Germany')*100/count(id)) > 90
 
 
 --5. Выбрать самого высокооплачиваемого игрока в своем возрасте (на выходе имя + зарплата)
 select name,
        price
   from (select name,
                price,
                Rank() over(partition by age order by price desc) as Rnk
           from bundesliga_player
          group by name,
                   price,
                   age)
  where Rnk = 1
  
 
 --6. Выбрать игроков, которые зарабатывают в 1.5 раза больше, чем в среднем по своей позиции 
with avgPrice as (
 select position, 
        avg(price) as AvgPrice
   from bundesliga_player
  group by position
)
select name
  from bundesliga_player t1
  join avgPrice          t2 on t2.position = t1.position
 where price > AvgPrice*1.5
  
  
  --7. На какой позиции тяжелей всего получить контракт с какой-либо компанией (adidas, puma)
select top 1 position
  from (select position,
               count() as cnt 
          from bundesliga_player
         where outfitter = ''
         group by position)
  order by cnt desc


--8.Посчитать, в какой команде раньше всего закончится контракт у 5 игроков
select top 1 
       club
  from bundesliga_player
 where name in (select top 5 
                       name
                  from bundesliga_player
                 where contract_expires != '1970-01-01'
                    or contract_expires is not null
                 order by contract_expires)
   and (contract_expires != '1970-01-01'
    or contract_expires is not null)
group by club, contract_expires 
order by contract_expires desc


--9. В каком возрасте игроки, в основном, выходят на пик своей зарплаты
select avg(age) AS AverageAge
  from bundesliga_player
 where price = (select max(price) from bundesliga_player)


--10. У какой команды самый сыгранный состав (дольше всего играют вместе)
select top 1
       club
  from (select club,
               sum(date_diff(day, joined_club, today())) as CntDays
          from bundesliga_player
         group by club)
 order by CntDays desc
  
  
 --11. В каких командах есть тёзки
 select distinct
        club 
   from (select club,
                arrayElement(splitByChar(' ', name), 1) as FirstName,
                count() as Cnt
           from bundesliga_player
          group by club, FirstName
         having Cnt > 1)
 
          
--12. Вывести команды, где топ-3 игрока по зарплате занимают 50% платежной ведомости
with clubSpend as (
select club,
       sum(price) as AmtPriceClub
  from bundesliga_player
 group by club
),
topPlayersSpend as (
select club,
       sum(price) as AmtPricePlayer
  from (select club, 
               name,
               price,
               ROW_NUMBER() OVER(PARTITION BY club ORDER BY price DESC) AS RowNum 
          from bundesliga_player)
  where RowNum <= 3
  group by club
)
select t1.club
  from clubSpend       t1
  join topPlayersSpend t2 on t2.club = t1.club
 where AmtPricePlayer >= AmtPriceClub * 0.5