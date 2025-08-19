--1. Liste o código dos clientes que fizeram pedidos com valor total acima da média, mostrando 
--também quantos pedidos cada um fez que atendem a esta condição. 

with vm as (
select avg(valor_total) as media from pedido
)

select p.cliente_id, count(*) as qtd from pedido p, vm
where p.valor_total > vm.media group by p.cliente_id;

---------------------------------------------------

--2. Calcule o valor total de indicações por cidade (considerando que cada cliente indicado gera 
--um crédito fictício de R$10 para quem indicou). Para as cidades que não possuem clientes 
--que fizeram indicação, deve ser exibido o valor 0. 
--Ordene o resultado por cidade.  

with city as (
select distinct cidade from cliente
),

cnt as (
select indicado_por, count(*) as qtd from indicacao group by indicado_por),

jnt as (
select cl.cidade as ct, cnt.qtd * 10 as valor_total
from cliente cl join cnt on cl.cliente_id = cnt.indicado_por)

select city.cidade, coalesce(jnt.valor_total, 0) from city
left join jnt on city.cidade = jnt.ct order by city.cidade;

----------------------------------------------------

--3. Classifique os clientes em categorias (Bronze, Prata, Ouro)  
--baseado no valor total gasto em pedidos (Bronze < 3000, 
--3000 ≤ Prata < 15000, Ouro ≥ 15000 

with cl as (
select cliente_id, sum(valor_total) soma from pedido
group by cliente_id
)

select cliente.nome, coalesce(cl.soma, 0),
case
	when cl.soma >= 15000 then 'Ouro'
	when cl.soma >= 3000 then 'Prata'
	else 'Bronze'
end categoria
from cliente left join cl on cliente.cliente_id = cl.cliente_id;

-----------------------------------------------------

--4. Para cada produto, mostre o nome e se seu preço base está "Acima", "Abaixo" ou "Na" 
--média dos preços dos produtos. Ordene pelo nome do produto.  

with med as (
	select avg(preco_base) media from produto
)

select p.nome, p.preco_base, round(m.media::numeric, 2),
case
	when p.preco_base > m.media then 'Acima'
	when p.preco_base < m.media then 'Abaixo'
	else 'Na média'
end compara_media
from produto p, med m
order by p.nome;

-----------------------------------------------------

--5. Classifique os produtos por quantidade total vendida (usando DENSE_RANK), mostrando 
--também a posição no ranking. No resultado, 
--devem aparecer as seguintes informações, 
--código do produto, nome do produto, quantidade total vendida do produto, posição no 
--ranking. O produto na primeira posição 
--deve ser aquele com a maior quantidade vendida.  

with pv as (
	select produto_id, sum(quantidade) as qtd from itempedido group by produto_id
)

select p.produto_id, p.nome, pv.qtd, dense_rank() over(order by pv.qtd desc) as ranking
from produto p join pv on p.produto_id = pv.produto_id;

-----------------------------------------------------

--6. Para cada cidade, classifique os clientes por valor total gasto. No resultado da consulta, 
--devem ser apresentados o nome da cidade, o nome do cliente, o valor total gasto e a 
--posição no ranking.  

with clgastos as
(select cliente_id, sum(valor_total) as total from pedido group by cliente_id)

select c.cidade, c.nome, cg.total, 
dense_rank() over(partition by c.cidade order by cg.total desc) as ranking
from cliente c join clgastos cg on c.cliente_id = cg.cliente_id;

-----------------------------------------------------

--7. Para cada pedido, mostre o id do pedido, o id do cliente, valor total do pedido 
--e a média de valores de pedidos do mesmo cliente. Ordene o resultado 
--pelo id do cliente e id do pedido. 

select pedido_id, cliente_id, coalesce(valor_total, 0),
avg(valor_total) over(partition by cliente_id) from pedido
order by cliente_id, pedido_id;

-----------------------------------------------------
--8. Para cada pedido, mostre o id do pedido, o id do cliente, a data do pedido, a data do 
--próximo pedido do mesmo cliente (usando LEAD).  

select pedido_id, cliente_id, data_pedido,
lead(data_pedido, 1) over(partition by cliente_id order by data_pedido) as proxima_data
from pedido;

-----------------------------------------------------

--9. Para cada pedido, mostre o id do pedido, o id do cliente, a data do pedido, a data do 
--próximo pedido do mesmo cliente (usando LEAD) e a diferença entre as datas. 

with pre as (
select pedido_id, cliente_id, data_pedido,
lead(data_pedido, 1) over(partition by cliente_id order by data_pedido) as proxima_data
from pedido)

select pedido_id, cliente_id, data_pedido, proxima_data, proxima_data - data_pedido as diferenca
from pre;

-----------------------------------------------------
--10. Retorne o valor total de pedidos agrupado por: cidade

select distinct c.cidade, sum(p.valor_total) over(partition by c.cidade)
from cliente c join pedido p on c.cliente_id = p.cliente_id;

-----------------------------------------------------
--Retorne o valor total de pedidos agrupado por: ano

select extract(year from data_pedido) as date, sum(valor_total)
from pedido 
group by date;

-----------------------------------------------------
--Retorne o valor total de pedidos agrupado por: ano e cidade combinados

with ts as (

select cliente_id, extract(year from data_pedido) as date,
valor_total from pedido)

select distinct c.cidade, ts.date, sum(valor_total) over(partition by c.cidade, ts.date)
from cliente c join ts on c.cliente_id = ts.cliente_id;

--ou--
select c.cidade, extract(year from p.data_pedido) as date, sum(p.valor_total) as total
from cliente c join pedido p on c.cliente_id = p.cliente_id
group by c.cidade, date
order by c.cidade, date;

-----------------------------------------------------
--total geral. 

select sum(valor_total) as geral from pedido;

-----------------------------------------------------

select * from cliente;

select * from indicacao;

select * from itempedido;

select * from pedido;

select * from produto;
