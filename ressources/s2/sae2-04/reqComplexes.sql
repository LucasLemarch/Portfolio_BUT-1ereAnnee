-- CAS BD'Lire
-- Programmeurs : Harel      Corentin B1, 
--                Decharrois Adrien   B1, 
--                Lemarchand Lucas    B2
-- Date : 01/06/22



-- REQUETE A

-- Lister les clients (numéro et nom) triés par ordre alphabétique du nom

SELECT	numClient, nomClient
FROM	Client
ORDER BY nomClient;

/* Résultat :

 numclient |  nomclient  
-----------+-------------
         7 | Don Devello
         2 | Fissile
         9 | Ginal
         3 | Hauraque
        10 | Hautine
        11 | Kament
         5 | Menvussa
         8 | Ohm
         4 | Poret
         6 | Timable
         1 | Torguesse
(11 lignes)
*/



-- REQUETE B

-- Lister les clients (numéro, nom) et leur nombre d’achats (que l’on nommera nbA) triés par ordre
-- décroissant de leur nombre d’achats (sans prendre en compte la quantité achetée)

SELECT	c.numClient, nomClient, SUM(quantite) as nbA
FROM	Client c join Vente v on c.numClient = v.numClient join Concerner cn on cn.numVente =  v.numVente
GROUP BY c.numClient
ORDER BY nbA DESC;

/* Résultat :

 numclient |  nomclient  | nba  
-----------+-------------+------
         4 | Poret       | 8816
         6 | Timable     | 6639
         8 | Ohm         | 6159
         7 | Don Devello | 5664
         9 | Ginal       | 4564
         3 | Hauraque    | 4307
         5 | Menvussa    | 4093
        10 | Hautine     | 3865
         2 | Fissile     | 3651
         1 | Torguesse   | 2645
        11 | Kament      | 1691
(11 lignes)
*/



-- REQUETE C

-- Lister les clients (numéro, nom) avec leur coût total d’achats (que l’on nommera coutA) triés
-- par leur coût décroissant, qui ont totalisé au moins 50000€ d’achats...

SELECT	c.numClient, nomClient, SUM(prixVente * quantite) as coutA 
FROM	Client c JOIN Vente v      ON c.numClient = v.numClient
				 JOIN Concerner cn ON cn.numVente = v.numVente 
GROUP BY c.numClient 
HAVING	SUM(prixVente * quantite) >= 50000 
ORDER BY coutA DESC;

/* Résultat :

 numclient |  nomclient  |   couta   
-----------+-------------+-----------
         4 | Poret       | 129209.55
         6 | Timable     |   93406.5
         8 | Ohm         |   92865.9
         7 | Don Devello |   82909.4
         9 | Ginal       |   66003.9
        10 | Hautine     |   59519.1
         5 | Menvussa    |   56772.3
         3 | Hauraque    |     51684
(8 lignes)
*/



-- REQUETE D

-- Afficher le chiffre d’affaire des ventes effectuées en 2021 (on pourra utiliser la fonction
-- extract pour récupérer l’année seule d’une date)

SELECT	SUM( prixVente * quantite )
FROM	Concerner c JOIN Vente v ON c.numVente = v.numVente
WHERE	EXTRACT(YEAR FROM dteVente) = 2021;

/* Résultat :

   sum   
---------
 54833.6
(1 ligne)
*/



-- REQUETE E

-- Créer une vue appelée CA qui affiche le chiffre d’affaire réalisé par année en listant dans
-- l’ordre croissant des années (champ appelé annee) et en face le chiffre réalisé (appelé chA)

DROP VIEW IF EXISTS CA;

CREATE VIEW CA(annee, cha)
AS	SELECT	EXTRACT( YEAR FROM dteVente) as annee, SUM( prixVente * quantite ) as cha
	FROM	Concerner c JOIN Vente v ON c.numVente = v.numVente
	GROUP BY annee
	ORDER BY annee;

/* Résultat :

SELECT * FROM CA;

 annee |   cha    
-------+----------
  2000 |    34059
  2001 | 52773.45
  2002 |    46129
  2003 |  15867.5
  2004 |  45393.9
  2005 |  64904.7
  2006 |  14602.5
  2007 |  34254.8
  2008 |  19389.8
  2009 |  14755.2
  2010 |  15545.4
  2011 |  17137.5
  2012 |  29922.4
  2013 |    11316
  2014 |  46403.7
  2015 |   9294.3
  2016 |  25570.3
  2017 |  23346.3
  2018 |  76295.8
  2019 |    59304
  2020 |    24000
  2021 |  54833.6
(22 lignes)
*/



-- REQUETE F

-- Lister tous les clients (numéro et nom) ayant acheté des BD de la série ‘Astérix le gaulois’

SELECT	numClient, nomClient 
FROM	CLIENT 
WHERE	numClient IN (	SELECT	v.numClient 
						FROM	VENTE v JOIN CONCERNER c ON v.numVente = c.numVente
										JOIN BD b        ON c.isbn     = b.isbn 
										JOIN SERIE s     ON b.numSerie = s.numSerie 
						WHERE	s.nomSerie = 'Asterix le gaulois'					);

/* Résultat :

 numclient |  nomclient  
-----------+-------------
         3 | Hauraque
        11 | Kament
         8 | Ohm
        10 | Hautine
         9 | Ginal
         7 | Don Devello
         1 | Torguesse
         5 | Menvussa
         2 | Fissile
         4 | Poret
         6 | Timable
(11 lignes)
*/



-- REQUETE G

-- Lister les clients (numéro et nom) qui n’ont acheté que les BD de la série ‘Asterix le gaulois’
-- (en utilisant la clause EXCEPT)

/* A : Client qui ont acheté une bd Asterix le gaulois
   B : Client qui ont acheté une bd autre que Asterix le gaulois
				A EXCEPT B										*/

SELECT	numClient, nomClient 
FROM	CLIENT 
WHERE	numClient IN (	SELECT	v.numClient 
						FROM	VENTE v JOIN CONCERNER c ON v.numVente = c.numVente
										JOIN BD b        ON c.isbn     = b.isbn 
										JOIN SERIE s     ON b.numSerie = s.numSerie 
						WHERE	s.nomSerie = 'Asterix le gaulois'					)

EXCEPT

SELECT	numClient, nomClient 
FROM	CLIENT 
WHERE	numClient IN (	SELECT	v.numClient 
						FROM	VENTE v JOIN CONCERNER c ON v.numVente = c.numVente
										JOIN BD b        ON c.isbn     = b.isbn 
						WHERE	b.numSerie != (	SELECT	numSerie 
												FROM	SERIE 
												WHERE	nomSerie = 'Asterix le gaulois'	)	);

/* Résultat :

 numclient | nomclient 
-----------+-----------
         3 | Hauraque
(1 ligne)
*/



-- REQUETE H

-- Créer et afficher une vue nommée best5 qui liste les 5 meilleurs clients (ayant donc dépensé le
-- plus d’argent en BD) en affichant leur numéro, nom et adresse mail, ainsi que le nombre total de
-- BD qu’ils ont acheté (champ nbBD en tenant compte des quantités achetées), ainsi que le total de
-- leurs achats (champ coutA).

DROP VIEW IF EXISTS best5;
CREATE VIEW best5(numClient, nomClient, mailClient, nbA, coutA)
AS	SELECT	c.numClient, nomClient, mailClient, SUM(quantite) AS nbA, SUM(prixVente * quantite) AS coutA 
	FROM	Client c JOIN Vente v      ON c.numClient = v.numClient 
					JOIN Concerner cn ON cn.numVente = v.numVente 
	GROUP BY c.numClient
	ORDER BY coutA DESC 
	FETCH FIRST 5 ROWS ONLY;

/* Résultat :

SELECT * FROM best5;

 numclient |  nomclient  |   mailclient    | nba  |   couta   
-----------+-------------+-----------------+------+-----------
         4 | Poret       | mail@he.fr      | 8816 | 129209.55
         6 | Timable     | mail@limelo.com | 6639 |   93406.5
         8 | Ohm         | mail@odie.net   | 6159 |   92865.9
         7 | Don Devello | mail@he.fr      | 5664 |   82909.4
         9 | Ginal       | mail@ange.fr    | 4564 |   66003.9
(5 lignes)
*/



-- REQUETE I

-- Construire et afficher une vue bdEditeur qui affiche le nombre de BD vendues par an et par
-- éditeur, par ordre croissant des années et des noms d’éditeurs. On y affichera le nom de
-- l’éditeur, l’année considérée et le nombre de BD publiées.

DROP VIEW IF EXISTS bdEditeur;

CREATE VIEW bdEditeur
AS	SELECT	EXTRACT( YEAR FROM dteVente) as annee, nomEditeur, SUM(quantite) as quantite_achete
	FROM	Vente v JOIN Concerner c ON v.numVente = c.numVente 
					JOIN BD b ON b.isbn = c.isbn
					JOIN Serie s ON s.numSerie = b.numSerie
					JOIN Editeur e ON e.numEditeur = s.numEditeur
	GROUP BY annee, nomEditeur
	ORDER BY annee, nomEditeur;

/* Résultat :

SELECT * FROM bdEditeur;

 annee |       nomediteur       | quantite_achete 
-------+------------------------+-----------------
  2000 | Dargaud                |            1362
  2000 | Lombard                |            1025
  2001 | Dargaud                |            1718
  2001 | Les humanoides associe |             157
  2001 | Lombard                |            1433
  2002 | Dargaud                |            1363
  2002 | Les humanoides associe |            1210
  2002 | Lombard                |             495
  2003 | Dargaud                |             415
  2003 | Lombard                |             245
  2003 | Pika Edition           |             608
  2004 | Dargaud                |            1778
  2004 | Lombard                |             537
  2004 | Tonkan                 |             794
  2005 | Bamboo Edition         |             567
  2005 | Dargaud                |            2525
  2005 | Tonkan                 |            1241
  2006 | Dargaud                |             826
  2006 | Lombard                |             295
  2007 | Bamboo Edition         |             922
  2007 | Dargaud                |            1485
  2008 | Dargaud                |            1235
  2008 | Lombard                |             247
  2009 | Lombard                |             928
  2010 | Dargaud                |             837
  2010 | Lombard                |             346
  2011 | Dargaud                |             308
  2011 | Delcourt               |             941
  2012 | Dargaud                |             624
  2012 | Delcourt               |             704
  2012 | Lombard                |             796
  2013 | Dargaud                |             277
  2013 | Delcourt               |             592
  2014 | Dargaud                |             857
  2014 | Delcourt               |            1879
  2014 | Lombard                |             648
  2015 | Dargaud                |             169
  2015 | Lombard                |             457
  2016 | Dargaud                |            1478
  2016 | Lombard                |             277
  2016 | Vents d Ouest          |             245
  2017 | Dargaud                |            1340
  2017 | Lombard                |             457
  2018 | Dargaud                |            2221
  2018 | Lombard                |            1282
  2018 | Vents d Ouest          |            2090
  2019 | Dargaud                |            1299
  2019 | Lombard                |            1920
  2019 | Vents d Ouest          |             456
  2020 | Dargaud                |              34
  2020 | Vents d Ouest          |             780
  2021 | Delcourt               |             456
  2021 | Lombard                |            2324
  2021 | Vents d Ouest          |             406
(54 lignes)
*/



-- REQUETE J

-- Construire et afficher une vue bdEd10 qui affiche les éditeurs qui ont publié plus de 10 BD, en
-- donnant leur nom et email, ainsi que le nombre de BD différentes qu’ils ont publiées.

DROP VIEW IF EXISTS bdEd10;

CREATE VIEW bdEd10(nomEditeur, mailEditeur, nbBd)
AS	SELECT	e.nomEditeur, mailEditeur, COUNT(isbn) AS nbBd
	FROM	EDITEUR e JOIN SERIE s ON e.numEditeur = s.numEditeur
					JOIN BD b    ON s.numSerie   = b.numSerie
	GROUP BY e.numEditeur
	HAVING   COUNT(isbn) > 10;

/* Résultat :

SELECT * FROM bdEd10;

 nomediteur |    mailediteur     | nbbd 
------------+--------------------+------
 Dargaud    | contact@dargaud.fr |   49
 Lombard    | info@Lombard.be    |   27
(2 lignes)
*/