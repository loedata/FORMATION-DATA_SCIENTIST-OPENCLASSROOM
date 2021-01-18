SELECT * FROM entity;
-- 215896 lignes

----------------------------------------------------------------------------------
-- UNIQUE
----------------------------------------------------------------------------------
SELECT DISTINCT * FROM entity; -- UNIQUE
-- 215896 lignes ==> pas de doublons

----------------------------------------------------------------------------------
-- PROJECTION
----------------------------------------------------------------------------------
SELECT id, name, status FROM entity;

----------------------------------------------------------------------------------
-- RESTRICTION
----------------------------------------------------------------------------------
SELECT * FROM entity WHERE name = 'Big Data Crunchers Ltd.';

--id	name	jurisdiction	jurisdiction_description	incorporation_date	status	service_provider	source	note	id_address	end_date	url	lifetime
--0	Big Data Crunchers Ltd.	BAH	Bahamas	2007-04-02	Active		Dummy data (neither from Panama Papers nor Offshore Leaks. Manually added for pedagogical purpose)		10000000			

SELECT * FROM entity 
WHERE (id < 10000004 AND (NOT id < 10000000)) OR (name = 'Big Data Crunchers Ltd.');

/*
10000001	TIANSHENG INDUSTRY AND TRADING CO., LTD.	SAM	Samoa	2006-03-23	Defaulted	Mossack Fonseca	Panama Papers		168350018331811	2013-02-15	http://offshoreleaks.icij.org/nodes/10000001	2521
10000002	NINGBO SUNRISE ENTERPRISES UNITED CO., LTD.	SAM	Samoa	2006-03-27	Defaulted	Mossack Fonseca	Panama Papers		168350018331811	2014-02-15	http://offshoreleaks.icij.org/nodes/10000002	2882
10000003	HOTFOCUS CO., LTD.	SAM	Samoa	2006-01-10	Defaulted	Mossack Fonseca	Panama Papers		168350018331811	2012-02-15	http://offshoreleaks.icij.org/nodes/10000003	2227
*/

----------------------------------------------------------------------------------
-- PRODUIT CARTESIEN
----------------------------------------------------------------------------------

SELECT * FROM entity, address ; -- TRES COUTEUSE !

----------------------------------------------------------------------------------
-- PROJECTION - FONCTIONS SCALAIRES, AS
----------------------------------------------------------------------------------

SELECT 45, 20, 'bonjour' ;
--45	20	bonjour 

SELECT id * 2, name, status FROM entity ;

SELECT ABS( (- id) *2 ) AS calcul_bizarre, name, status FROM entity;

SELECT name || '(' || status || ')' AS name_and_status FROM entity ;

-- Version MySQL :
--SELECT concat(name,'(',status,')') AS name_and_status FROM entity ;
   
SELECT CURRENT_DATE > incorporation_date FROM entity;

SELECT datetime('now') > incorporation_date FROM entity;


----------------------------------------------------------------------------------
-- UNION -- mêmes colonnes ==> Projection
----------------------------------------------------------------------------------
-- liste de toutes les sociétés et tous les intermédiaires
SELECT name, id_address FROM intermediary 
UNION
SELECT name, id_address FROM entity ;

----------------------------------------------------------------------------------
-- EXCEPT
----------------------------------------------------------------------------------
--liste des entités qui ne sont pas des intermédiaires
SELECT name, id_address FROM intermediary 
EXCEPT
SELECT name, id_address FROM entity ;

----------------------------------------------------------------------------------
-- INTERSECT
----------------------------------------------------------------------------------
-- sociétés présentes dans entité et intermédiaire
SELECT name, id_address FROM intermediary 
INTERSECT
SELECT name, id_address FROM entity ;


----------------------------------------------------------------------------------
-- REQUETE IMBRIQUEE
----------------------------------------------------------------------------------
SELECT *
FROM adulte
WHERE numero_securite_sociale IN (
    SELECT numero_securite_sociale FROM marseillais
) ;

----------------------------------------------------------------------------------
-- JOINTURE INTERNE
----------------------------------------------------------------------------------
-- retrouver l'adresse de entreprise Big Data Crunchers Ltd.
SELECT * FROM entity, address 
 WHERE entity.id_address = address.id_address ;

-- OU
SELECT * 
FROM entity 
    JOIN address ON entity.id_address = address.id_address ;
    
----------------------------------------------------------------------------------
-- JOINTURE SUR PLUSIEURS COLONNES
----------------------------------------------------------------------------------
-- EXEMPLE
-- Première méthode :
SELECT * FROM t1, t2 WHERE (t1.fk1 = t2.pk1 AND t1.fk2 = t2.pk2);
-- Seconde méthode :
SELECT * FROM t1 JOIN t2 ON (t1.fk1 = t2.pk1 AND t1.fk2 = t2.pk2);

-- Société bidon
SELECT * 
FROM entity, address 
WHERE entity.id_address = address.id_address 
  AND entity.name = 'Big Data Crunchers Ltd.';
  
--id	name	jurisdiction	jurisdiction_description	incorporation_date	status	service_provider	source	note	id_address	end_date	url	lifetime	address	countries	country_codes	id_address:1	source_id
--0	Big Data Crunchers Ltd.	BAH	Bahamas	2007-04-02	Active		Dummy data (neither from Panama Papers nor Offshore Leaks. Manually added for pedagogical purpose)		10000000				504 rue de la requête Hesscuhel, Paris, France	FRA	France	10000000	2
    
----------------------------------------------------------------------------------
-- JOINTURE AVEC UNE TABLE D'ASSOCIATION
----------------------------------------------------------------------------------
-- retrouver les intermédiaires en plus de l'adresse
SELECT
    i.id as intermediary_id,
    i.name as intermediary_name,
    e.id as entity_id,
    e.name as entity_name,
    e.status as entity_status
FROM 
    intermediary i,
    assoc_inter_entity a,
    entity e
WHERE
    a.entity = e.id
    AND a.inter = i.id
    AND e.name = 'Big Data Crunchers Ltd.' ;

/*    
intermediary_id	intermediary_name	entity_id	entity_name	entity_status
5000	Pacher Banking S.A.	0	Big Data Crunchers Ltd.	Active
5001	Plouf Financial Services Corp.	0	Big Data Crunchers Ltd.	Active
*/

----------------------------------------------------------------------------------
-- JOINTURE EXTERNE GAUCHE
----------------------------------------------------------------------------------
SELECT *
FROM entity
    LEFT OUTER JOIN address ON entity.id_address = address.id_address;
    
----------------------------------------------------------------------------------
-- JOINTURE EXTERNE DROITE
----------------------------------------------------------------------------------
SELECT *
FROM entity
    RIGHT OUTER JOIN address ON entity.id_address = address.id_address;

----------------------------------------------------------------------------------
-- JOINTURE ENTIERE
----------------------------------------------------------------------------------
SELECT *
FROM entity
    FULL OUTER JOIN address ON entity.id_address = address.id_address;
    
----------------------------------------------------------------------------------
-- AGREGATION
----------------------------------------------------------------------------------
SELECT status, count(*) FROM entity GROUP BY status;

----------------------------------------------------------------------------------
-- FONCTIONS D'AGREGATION : MAX
----------------------------------------------------------------------------------
SELECT max(incorporation_date) AS maxi FROM entity ;
--2015-12-18

----------------------------------------------------------------------------------
-- FONCTIONS D'AGREGATION : MIN
----------------------------------------------------------------------------------
SELECT incorporation_date FROM entity ;

SELECT min(id) FROM entity ;
--0

SELECT incorporation_date, min(id) FROM entity ;
--2007-04-02	0

----------------------------------------------------------------------------------
-- FONCTIONS D'AGREGATION : COUNT
----------------------------------------------------------------------------------
SELECT count(*) FROM entity ;
--215896

----------------------------------------------------------------------------------
-- FONCTIONS D'AGREGATION : ABS et scalaire AS
----------------------------------------------------------------------------------
SELECT abs(id) AS valeur_absolue FROM entity ;

/*
10000001
10000002
10000003
10000004
...
*/

----------------------------------------------------------------------------------
-- ATTRIBUTS DE PARTITIONNEMENT : DANS GROUPBY
----------------------------------------------------------------------------------
SELECT count(*), status FROM entity GROUP BY status ;

/*
57990	Active
1416	Bad debt account
21	Change in administration pending
16043	Changed agent
100090	Defaulted
423	Discontinued
22377	Dissolved
...
*/

----------------------------------------------------------------------------------
-- AGGREGATION : GROUPBY
----------------------------------------------------------------------------------
-- nombre d'entités qui ont créés les 2 intermédiaires 5000 et 5001 trouvées plus haut
SELECT
    i.id as intermediary_id, 
    i.name as intermediary_name,
    e.jurisdiction, 
    count(*) 
FROM 
    intermediary i,
    assoc_inter_entity a, 
    entity e 
WHERE 
    a.entity = e.id 
    AND a.inter = i.id 
    AND (i.id = 5000 OR i.id = 5001) 
GROUP BY 
    i.id, i.name, e.jurisdiction;

/*
5000	Pacher Banking S.A.	ANG	32
5000	Pacher Banking S.A.	BAH	162
5000	Pacher Banking S.A.	BLZ	2
5000	Pacher Banking S.A.	BVI	1161
5000	Pacher Banking S.A.	CRI	2
5000	Pacher Banking S.A.	CYP	2
5000	Pacher Banking S.A.	HK	4
5000	Pacher Banking S.A.	JSY	2
5000	Pacher Banking S.A.	MLT	1
5000	Pacher Banking S.A.	NEV	12
5000	Pacher Banking S.A.	NIUE	97
5000	Pacher Banking S.A.	NZL	2
5000	Pacher Banking S.A.	PMA	493
5000	Pacher Banking S.A.	SAM	53
5000	Pacher Banking S.A.	SEY	154
5000	Pacher Banking S.A.	UK	2
5000	Pacher Banking S.A.	UY	2
5000	Pacher Banking S.A.	WYO	2
5001	Plouf Financial Services Corp.	ANG	10
5001	Plouf Financial Services Corp.	BAH	53
5001	Plouf Financial Services Corp.	BLZ	2
5001	Plouf Financial Services Corp.	BVI	382
5001	Plouf Financial Services Corp.	CRI	2
5001	Plouf Financial Services Corp.	CYP	1
5001	Plouf Financial Services Corp.	HK	2
5001	Plouf Financial Services Corp.	JSY	1
5001	Plouf Financial Services Corp.	NEV	4
5001	Plouf Financial Services Corp.	NIUE	31
5001	Plouf Financial Services Corp.	NZL	1
5001	Plouf Financial Services Corp.	PMA	162
5001	Plouf Financial Services Corp.	SAM	16
5001	Plouf Financial Services Corp.	SEY	50
5001	Plouf Financial Services Corp.	UK	2
5001	Plouf Financial Services Corp.	UY	1
5001	Plouf Financial Services Corp.	WYO	1
*/    

----------------------------------------------------------------------------------
-- ORDER BY : FONCTION DE TRI 
----------------------------------------------------------------------------------
SELECT * FROM entity ORDER BY lifetime ;

-- ASC : ascendant par défaut
SELECT * FROM entity ORDER BY incorporation_date ASC ;

-- DESC : descendant - à préciser
SELECT * FROM entity ORDER BY incorporation_date DESC ;

-- SUR PLUSIEURS COLONNES
SELECT * FROM entity ORDER BY incorporation_date DESC, name, status ;

SELECT 
    i.id AS intermediary_id,
    i.name AS intermediary_name,
    e.jurisdiction,
    e.jurisdiction_description,
    count(*) as cnt
FROM 
    intermediary i,
    assoc_inter_entity a,
    entity e    
WHERE 
    a.entity = e.id AND 
    a.inter = i.id AND 
    (i.id = 5000 OR i.id = 5001) 
GROUP BY 
    i.id, i.name, e.jurisdiction, e.jurisdiction_description
ORDER BY 
    cnt DESC
LIMIT 5;

-- récupérer en plus les legnes pour lesquelles cnt >100


----------------------------------------------------------------------------------
-- HAVING - aggrégation
----------------------------------------------------------------------------------
SELECT 
    i.id AS intermediary_id,
    i.name AS intermediary_name,
    e.jurisdiction,
    e.jurisdiction_description,
    count(*) as cnt
FROM 
    intermediary i,
    assoc_inter_entity a,
    entity e
WHERE 
    a.entity = e.id AND 
    a.inter = i.id AND 
    (i.id = 5000 OR i.id = 5001) 
GROUP BY 
    i.id, i.name, e.jurisdiction, e.jurisdiction_description
HAVING    count(*) > 100 
ORDER BY cnt DESC;

/*
5000	Pacher Banking S.A.	BVI	British Virgin Islands	1161
5000	Pacher Banking S.A.	PMA	Panama	493
5001	Plouf Financial Services Corp.	BVI	British Virgin Islands	382
5000	Pacher Banking S.A.	BAH	Bahamas	162
5001	Plouf Financial Services Corp.	PMA	Panama	162
5000	Pacher Banking S.A.	SEY	Seychelles	154
*/

----------------------------------------------------------------------------------
-- LIKE : RECHERCHE DANS UNE CHAINE
----------------------------------------------------------------------------------
SELECT * FROM entity WHERE name LIKE 'A%' ;
/*
10000009	AMARANDAN LTD.	SAM	Samoa	2004-01-26	Defaulted	Mossack Fonseca	Panama Papers		168350018331811	2006-02-15	http://offshoreleaks.icij.org/nodes/10000009	751
10000017	ANGELIKA INTERNATIONAL LTD.	SAM	Samoa	2004-01-26	Defaulted	Mossack Fonseca	Panama Papers		142060071134550	2006-02-15	http://offshoreleaks.icij.org/nodes/10000017	751
10000031	Aegis Infocom Inc.	SAM	Samoa	2006-01-17	Active	Mossack Fonseca	Panama Papers		123957483684293		http://offshoreleaks.icij.org/nodes/10000031	
...
*/

/*
'OpenClassrooms' LIKE '%Class%'            TRUE
'OpenClassrooms' LIKE '%Class%ms'          TRUE
'OpenClassrooms' LIKE '%Class%ms%'         TRUE
'OpenClassrooms' LIKE 'Open_lassrooms'     TRUE
'OpenClassrooms' LIKE 'Open__lassrooms'    FALSE
'OpenClassrooms' LIKE '_OpenClassrooms'    FALSE
'OpenClassrooms' LIKE 'Op__Cla%'           TRUE
'OpenClassrooms' LIKE '%OpenClas%srooms%'  TRUE 
*/

-- ATTENTION MINUSCULES/MAJUSCULES
SELECT * FROM entity WHERE lower(name) LIKE 'a%' ;

SELECT * FROM intermediary WHERE lower(name) LIKE '%pacher%banking%' ;
/*
5000	Pacher Banking S.A.	2			0	
5002	pacher banking sa	2			0	
*/

-- voir i 2 sociétés intermédiaires sont doublons
SELECT 
    i.id AS intermediary_id,
    i.name AS intermediary_name,
    e.jurisdiction,
    e.jurisdiction_description,
    count(*) as cnt
FROM 
    intermediary i,
    assoc_inter_entity a,
    entity e
WHERE 
    a.entity = e.id AND 
    a.inter = i.id AND 
    (   lower(i.name) LIKE '%pacher%banking%'
        OR
        lower(i.name) LIKE '%plouf%financial%services%')
GROUP BY 
    i.id, i.name, e.jurisdiction, e.jurisdiction_description
HAVING 
    count(*) > 100 ;
/*
5000	Pacher Banking S.A.	BAH	Bahamas	162
5000	Pacher Banking S.A.	BVI	British Virgin Islands	1161
5000	Pacher Banking S.A.	PMA	Panama	493
5000	Pacher Banking S.A.	SEY	Seychelles	154
5001	Plouf Financial Services Corp.	BVI	British Virgin Islands	382
5001	Plouf Financial Services Corp.	PMA	Panama	162
*/
    
----------------------------------------------------------------------------------
-- IN
----------------------------------------------------------------------------------
SELECT *
FROM address a
WHERE a.id_address IN (
    SELECT id_address
    FROM entity
    GROUP BY id_address
    HAVING count(*) > 500
    );

-- sur plusieurs colonnes
SELECT * FROM t1 WHERE t1.valeur1, t1.valeur2 IN (SELECT c1, c2 FROM t2) ;

----------------------------------------------------------------------------------
-- ALL / ANY
----------------------------------------------------------------------------------
SELECT * FROM nb_entities WHERE cnt_entities > ALL(SELECT cnt_entities FROM nb_entities WHERE intermediary_id IN (5000,5001,5002));

-- équivaut à

CREATE TABLE nb_entities AS
SELECT i.id AS intermediary_id, 
    i.name AS intermediary_name, 
    e.jurisdiction,
    e.jurisdiction_description,
    count(*) AS cnt_entities
FROM intermediary i, assoc_inter_entity a, entity e
WHERE a.entity = e.id AND a.inter = i.id
GROUP BY i.id, i.name, e.jurisdiction, e.jurisdiction_description;

----------------------------------------------------------------------------------
-- EXISTS
----------------------------------------------------------------------------------
/*
..
WHERE 
EXISTS...
*/

----------------------------------------------------------------------------------
-- TABLES TEMPORAIRES
----------------------------------------------------------------------------------
CREATE TEMP TABLE une_table_temporaire AS
SELECT id_address, count(*) AS cnt 
FROM entity 
GROUP BY id_address ;

SELECT * FROM une_table_temporaire a WHERE a.cnt > 500 ;

----------------------------------------------------------------------------------
-- OVER
----------------------------------------------------------------------------------
SELECT incorporation_date, min(id) FROM entity ;
-- provoque une erreur car min ne rretourne qu'une valeur 

SELECT incorporation_date, min(id) OVER() FROM entity;
--==> utiliser over min retournera autant d'éléments dans tuple que entity

----------------------------------------------------------------------------------
-- FENETRAGE OVER (PARTITION BY ...) ou OVER (PARTITION BY ... ORDER BY ...)
----------------------------------------------------------------------------------
-- REQUETE n°1
SELECT sum(cnt_entities) FROM nb_entities GROUP BY id_intermediary ;

-- REQUETE n°2
SELECT sum(cnt_entities) OVER (PARTITION BY id_intermediary) FROM nb_entities ;
--Dans la requête 2, si sum reçoit en entrée la liste de valeurs [10, 1, 5], elle ne renverra pas 16 mais plutôt [16, 16, 16].
SELECT id_intermediary, 
    jurisdiction, 
    cnt_entities, 
    sum(cnt_entities) OVER (PARTITION BY id_intermediary) AS entities_by_intermediary 
FROM nb_entities ;

----------------------------------------------------------------------------------
-- RANK() - Donne le rang des lignes
----------------------------------------------------------------------------------
SELECT 
    prenom, 
    temps, 
    rank() OVER (ORDER BY temps) 
FROM course ;

/*
prenom  temps  rank()  
Naïma  3 min 15 s  1  
Sarah  3 min 19 s  3  
Sonia  3 min 16 s  2  
Luc  10 min 39 s  4
*/

----------------------------------------------------------------------------------
-- SOMME CUMULEE ET RANG
----------------------------------------------------------------------------------
SELECT id_intermediary,
    jurisdiction,
    cnt_entities,
    rank()
        OVER(PARTITION BY id_intermediary ORDER BY cnt_entities DESC) AS rank,
    sum(cnt_entities) 
        OVER(PARTITION BY id_intermediary ORDER BY cnt_entities DESC) AS cum_sum
FROM nb_entities ;

----------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------




