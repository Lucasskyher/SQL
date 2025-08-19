select avg(salario) from funcionario;

select round(avg(salario):: numeric, 2) from funcionario;

select codept, round(avg(salario):: numeric, 2) from funcionario
group by 1 order by 2;

select codept, avg(salario) as media, stddev(salario) as desvio_padrao,
percentile_cont(0.5) within group (order by salario)
from funcionario group by 1;

select avg(salario), percentile_cont(0.5) within group
(order by salario) from funcionario;

select salario from funcionario where codept = 1;

select tipo, status, count(*) from projeto
group by tipo, status order by tipo;


--------------------------------------------

select qtdef, count(codp) from
(select codp, count(codf) as qtdef from alocacao
group by 1) quantidade_funcionario_projeto group by qtdef;

----------------valores nulos------------------------

select p.nome, a.codf, p.dataf, a.datafim from alocacao a 
join projeto p on a.codp = p.codigo where (a.datafim > p.dataf)
or (a.datafim is null and p.dataf is not null);

----------------CASE-----------------

select nome,
case
	when tipo = 'T' then 'Terceirização'
	when tipo = 'C' then 'Colaboração'
	else 'desconhecido'
end as tipo_projeto
from projeto;

-------------------------------------

select
case tipo
	when 'T' then 'Terceirização'
	when 'C' then 'Colaboração'
	else 'desconhecido'
end as tipo_projeto,
	count(*) 	
from projeto 
group by tipo_projeto;


----------------------------------

select codp projeto,
case 
	when qtdef<= 3 then 'pouco'
	when qtdef<= 6 then 'medio'
	else 'muito'
end as classe
from (select codp, count(codf) qtdef from alocacao
group by codp) quantidade_funcionario_projeto;
 

-------------------------------------------

select classe, count(projeto) from (
select codp as projeto,
case 
	when qtdef<= 3 then 'pouco'
	when qtdef<= 6 then 'medio'
	else 'muito'
end as classe
from (select codp, count(codf) as qtdef from alocacao
group by codp) as quantidade_funcionario_projeto
) as classificacao 
group by classe;

-----------------cte------------------------------
with teste as (
select codp, count(codf) qtd from alocacao group by codp
),

teste2 as (
select t.codp,
case
	when t.qtd <= 3 then 'pouco'
	when t.qtd <= 6 then 'medio'
	else 'muito'
end classe
from teste t
),

teste3 as(
select classe, count(codp) cnt
from teste2
group by classe
)

select classe from teste3 where cnt = 2;


-------------------------------------

select classe from (
select classe, count(projeto) as cnt from (
select codp as projeto,
case 
	when qtdef<= 3 then 'pouco'
	when qtdef<= 6 then 'medio'
	else 'muito'
end as classe
from (select codp, count(codf) as qtdef from alocacao
group by codp) as quantidade_funcionario_projeto
) as classificacao 
group by classe
) where cnt = 2;

----------------------------------------

select p.nome,
case
	when exists (
		select 1 from alocacao a
		where a.codp = p.codigo
	) then 'Já tem alocacao'
	else 'Não tem alocacao'
end as status_alocacao
from projeto p;


----------------------------------------

select
case
	when exists (
		select 1 from alocacao a
		where a.codp = p.codigo
	) then 'Já tem alocacao'
	else 'Não tem alocacao'
end as status_alocacao,
count (*) as quantidade
from projeto p
group by status_alocacao;

------------------------------------

select status_alocacao, count(status_alocacao) quantidade from (
select
case
	when exists (
		select 1 from alocacao a
		where a.codp = p.codigo
	) then 'Já tem alocacao'
	else 'Não tem alocacao'
end as status_alocacao
from projeto p
) group by status_alocacao;

-----------------COALESCE-----------------------

select nome, COALESCE(email, 'sem email') As contato
from funcionario;

-------------------------------------

select f.nome, coalesce(g.nome, 'Gerente geral') from
funcionario f left join funcionario g on f.gerente = g.codigo;


------------------Exercicio(1-CASE)--------------------


select nome, salario,
case 
	when salario >= 10000 then 'Alta'
	when salario >= 5000 and salario <= 9999 then 'Média'
	else 'Baixa'
end faixa_salarial
from funcionario;

------------------Exercicio(2-CASE)---------------------

select p.nome,
case
	when exists(
	select 1 from funcionario where gerente = p.codigo
	) then 'Gerente'
	else 'Comum'
end tipo_funcionario
from funcionario p;

----------------CTE-----------------------

with media_salarial as (
select avg(salario) as media from funcionario 
)
select f.nome, f.salario from funcionario f, media_salarial m
where f.salario > m.media;

-------------------------------------


with total_horas_funcionario as(
select nome, sum(horas) total_horas from alocacao join
funcionario on codigo = codf group by 1),

media_horas_geral as (
select avg(total_horas) media_geral from total_horas_funcionario
)

select t.nome, t.total_horas, m.media_geral
from total_horas_funcionario t cross join media_horas_geral m
order by t.nome;


------------------------------------------

with recursive retorna_gerente as (
	select codigo, nome, 'gerente geral'::character varying as gerente, 1 as nivel 
	from funcionario where gerente is null
	union
	select f.codigo, f.nome, g.nome as gerente,  nivel + 1
 	from funcionario f join retorna_gerente g on f.gerente = g.codigo)

select nome, gerente, nivel from retorna_gerente order by nivel,nome;

-----------------------------------------------


select f.nome, g.nome gerente from funcionario f
join funcionario g on f.gerente = g.codigo;

------------------EXERCICIO(1-CTE)-----------------------

with qtdfunc_aloc as (
select codp, count(codf) qtdef from alocacao group by codp),

medicao as (
select codp,
case
	when qtdef <= 3 then 'pouco'
	when qtdef <= 6 then 'medio'
	else 'muito'
end classe
from qtdfunc_aloc
)

select classe, count(codp) from medicao group by classe;


------------------EXERCICIO(2-CTE)-----------------------

with recursive retorna_dep as (
	select codigo, nome, 'Direção'::character varying as dep_pai, 1 as nivel 
	from departamento where deptp is null
	union
	select f.codigo, f.nome, g.nome as dep_pai, nivel + 1 
	from departamento f join retorna_dep g on f.deptp = g.codigo)
	
select nome, dep_pai as departamento_pai, nivel from retorna_dep 
order by nivel, nome;


--------------------Funções de Janela-----------------------

select nome, salario, 
avg(salario) over(partition by codept) from funcionario;

select codp, codf, horas, datai,
sum(horas) over(partition by codp) as horas_total from alocacao;

---função de order by diferente--

select nome, salario from funcionario Where codept = 1 order by salario;

------order by em func.janela------

select nome, salario, 
avg(salario) over(order by salario) as media from funcionario;

-----------rank----------

select nome, salario,
rank() over(order by salario desc) as ranking from funcionario;

-------dense: não pula números quando há empates-------

select nome, salario,
dense_rank() over(order by salario desc) as ranking from funcionario;

----------compara valores lead(x, 1(compara com 1 linha abaixo))---------

select nome, salario,
lead(salario, 1) over(order by salario) as salario_mais_alto from funcionario;

-------lead(x, x, 0(valores null = 0))------
select nome, salario,
lead(salario, 2, 0) over(order by salario) as salario_mais_alto from funcionario;

-------------lag: contrario de lead lag(x,1(pode ser omitido))---------------

select nome, salario,
lag(salario, 1) over (order by salario) as salario_mais_baixo from funcionario;

-----rank de horas trabalhadas num projeto----

with horas_projeto as 
(select codp, sum(horas) soma from alocacao group by codp)

select codp, soma,
dense_rank() over(order by soma desc) as ranking from horas_projeto;

---------------rank funcionario(horas) por dep-------

with horas_funcionario as
(select codf, sum(horas) soma from alocacao group by codf)

select h.codf, h.soma, f.codept,
dense_rank() over (partition by codept order by soma desc) as ranking
from horas_funcionario h join funcionario f on h.codf = f.codigo;



------------rows------------

select codigo, nome, datai, valor,
avg(valor) over(
	order by datai
	rows between 1 preceding and current row
) as media_movel_projetos
from projeto;

---------------

select codigo, nome, datai, valor,
avg(valor) over(
	order by datai
	rows between current row and 1 following
) as media_movel_projetos
from projeto;


-------identificar duplicatas-----------

----nao da pra ver mais infos(incorreta)----
select nome, count(*) from equipamento
group by nome
having(count(*)) > 1;

--------row_number()--------------------

select * from
(select *,
	row_number() over(partition by nome order by codigo) as numero_linha
	from equipamento) grupo_nome
where numero_linha > 1;

-----usando cte-----

with teste as
(select *, row_number() over(partition by nome order by codigo)
as numero_linha from equipamento)

select * from teste where numero_linha > 1;

--------equip que possuem mesmo nome mais dif codigo------------

select e.* from equipamento e where exists
(select 1 from equipamento e2 where e.nome = e2.nome
and e.codigo <> e2.codigo);

-----------identificar linhas identicas-----------------

select codigo, nome, tipo, count(*)
from equipamento
group by codigo, nome, tipo
having count(*) > 1;

----------identificar caracteres similar-----------

CREATE EXTENSION fuzzystrmatch;

select levenshtein('Minas Gerais', 'Minas G'); -- 5

select levenshtein('Minas Gerais', 'Mins G'); -- 6

select levenshtein('Minas Gerais', 'Minas Gerais'); -- 0

-------valores null group by-------------

select gerente,
sum(salario) as total_salarios
from funcionario f
group by gerente;


---para cada combinação de departamento e gerente 
---retorne a soma dos salários dos funcionários 

select d.nome, g.nome, sum(f.salario) as total_salarios
from funcionario f join funcionario g on f.gerente = g.codigo
join departamento d on d.codigo = f.codept
group by d.nome, g.nome
order by d.nome;

----grouping sets----

select 	coalesce(d.nome, 'Todos') as departamento, 
		coalesce(g.nome, 'Todos') as gerente,
		sum(f.salario) as total_salarios
from funcionario f join funcionario g on f.gerente = g.codigo
join departamento d on d.codigo = f.codept
group by grouping sets (d.nome, g.nome)
order by d.nome;

----rollup---------
-- Faz combinações das colunas da esquerda para direita, 
-- sempre incluindo a primeira coluna, 
-- seguindo a ordem das colunas na lista:
--Um grupo para cada combinação de nome do departamento com gerente
--Um grupo para cada departamento
--Não cria o grupo só de gerente

select 	coalesce(d.nome, 'Todos') as departamento, 
		coalesce(g.nome, 'Todos') as gerente,
		sum(f.salario) as total_salarios
from funcionario f join funcionario g on f.gerente = g.codigo
join departamento d on d.codigo = f.codept
group by rollup (d.nome, g.nome)
order by d.nome;

--------cube-----------

select 	coalesce(d.nome, 'Todos') as departamento,
		coalesce(g.nome, 'Todos') as gerente,
		sum(f.salario) as total_salarios
from funcionario f join funcionario g on
f.gerente = g.codigo join departamento d on d.codigo = f.codept
group by cube(d.nome, g.nome)
order by d.nome;


-----------sem pivotar-----------

select tipo, count(*) qtde 
from projeto
group by tipo;

------------pivotando------------

select 
count(*) Filter(where tipo = 'T') as tipo_T, 
count(*) Filter(where tipo = 'C') as tipo_C
from projeto;


--Quero saber quantas alocações existem para cada departamento, separadas pelo 
--tipo do projeto. Os tipos diferentes de projeto devem aparecer nas colunas do 
--resultado. Um projeto é considerado associado a um departamento se um 
--funcionário alocado no projeto trabalha no departamento 

SELECT 
d.nome AS departamento,
count(p.codigo) FILTER (WHERE p.tipo = 'T') AS tipo_T,
count(p.codigo) FILTER (WHERE p.tipo = 'C') AS tipo_c
FROM alocacao a
JOIN funcionario f ON a.codf = f.codigo
JOIN departamento d ON f.codept = d.codigo
JOIN projeto p ON a.codp = p.codigo
GROUP BY d.nome
ORDER BY d.nome;
