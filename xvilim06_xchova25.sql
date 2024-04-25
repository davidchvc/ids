-- SQL skript pro vytvoreni zakladnich struktur databaze a jejich naplneni a dalsi praci s daty
-- Dan Vilimvsky    (xvilim06)
-- David Chovanec   (xchova25)
--
-- 4. cast projektu IDS
-- Tym: xvilim06
-- Zadani: 7) Autoopravna

DROP MATERIALIZED VIEW uzivatel_objednavka;
DROP INDEX osoba_OP_jmeno_prijmeni;
DROP INDEX objednavka_OP_cena_zhotoveno;
DROP SEQUENCE "oprava_id_seq";
DROP TABLE specializace_mechanik;
DROP TABLE specializace;
DROP TABLE material_oprava;
DROP TABLE oprava;
DROP TABLE mechanik;
DROP TABLE objednavka;
DROP TABLE material;
DROP TABLE osoba;


create table osoba (
    "OP" INT NOT NULL PRIMARY KEY,
    "jmeno_prijmeni" VARCHAR (120) NOT NULL
        CHECK(regexp_like("jmeno_prijmeni", '^[A-Z][a-z]* [A-Z][a-z]*$')),
    "tel_cislo" INT NOT NULL,
    "email" VARCHAR(200) NOT NULL
        CHECK(regexp_like("email", '^[A-Za-z0-9][A-Za-z0-9]*\@[A-Za-z0-9][A-Za-z0-9]*\.[a-z]*'))
);

/*
Zde dedi mechanik vlastnosti osoby, jedna se o generalizaci/specializaci. K implementaci jsme zvolili moznost implementovat tabulku pro rodicovsky typ osoba a zaroven
tabulku pro podtyp mechanik, ktery ma shodny primarni klic s nadtypem, v tomto pripade cislo obcanskeho prukazu. Navic pak obsahuje data, ktera nejsou treba znat
o svych zakaznicich, pouze zamestnancich.
*/
create table mechanik (
    "OP" INT NOT NULL PRIMARY KEY,
        FOREIGN KEY ("OP") REFERENCES osoba ("OP"),
    "bydliste" VARCHAR(300) NOT NULL,
    "datum_narozeni" DATE NOT NULL,
    "mzda" INT NOT NULL,
    "bankovni_spojeni" VARCHAR(25) NOT NULL
);

create table specializace (
    "id" INT NOT NULL PRIMARY KEY,
    "typ" VARCHAR(300)
);

create table objednavka (
    "id" INT NOT NULL PRIMARY KEY,
    "datum_vytvoreni" DATE NOT NULL,
    "predpokladane_datum_vyrizeni" DATE NOT NULL,
    "datum_zhotoveni" DATE DEFAULT NULL,
    "predpokladana_cena" INT NOT NULL,
    "finalni_cena" INT DEFAULT NULL,
    "zhotoveno" INT DEFAULT 0,
    "id_osoba" INT NOT NULL,
        CONSTRAINT "objednavka_osoba_id_fk"
            FOREIGN KEY ("id_osoba") REFERENCES osoba ("OP")
);

create table oprava (
    "id" INT NOT NULL PRIMARY KEY,
    "typ" VARCHAR(300) NOT NULL,
    "straveny_cas" INT DEFAULT NULL,
    "predpokladana_cena" INT NOT NULL,
    "finalni_cena" INT DEFAULT NULL,
    "zhotoveno" INT DEFAULT 0,
    "id_objednavky" INT NOT NULL,
        CONSTRAINT "oprava_objednavka_id_fk"
            FOREIGN KEY ("id_objednavky") REFERENCES objednavka ("id"),
    "id_mechanik" INT NOT NULL,
        CONSTRAINT "oprava_mechanik_id_fk"
            FOREIGN KEY ("id_mechanik") REFERENCES mechanik ("OP")
);

create table material (
    "id" INT NOT NULL PRIMARY KEY,
    "mnozstvi_na_sklade" INT DEFAULT 0,
    "cena" INT NOT NULL
);

create table material_oprava (
    "id_material_oprava" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "mnozstvi" INT NOT NULL,
    "id_material" INT NOT NULL,
    CONSTRAINT "material_oprava_id_fk"
		FOREIGN KEY ("id_material") REFERENCES material ("id"),
    "id_oprava" INT NOT NULL,
    CONSTRAINT "oprava_material_id_fk"
		FOREIGN KEY ("id_oprava") REFERENCES oprava ("id")
);

create table specializace_mechanik (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "id_specializace" INT NOT NULL,
        CONSTRAINT "specializace_mechanik_id_fk"
            FOREIGN KEY ("id_specializace") REFERENCES specializace ("id"),
    "id_mechanik" INT NOT NULL,
        CONSTRAINT "mechanik_specializace_id_fk"
            FOREIGN KEY ("id_mechanik") REFERENCES mechanik ("OP")
);

-------trigger1----------
--Pokud pri vkladani nove opravy neni zadana "id", je vygenerovana automaticky

CREATE SEQUENCE "oprava_id_seq" START WITH 101 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER "oprava_id_not_null"
    BEFORE INSERT ON oprava FOR EACH ROW
BEGIN
    IF :NEW."id" IS NULL THEN
        :NEW."id" := "oprava_id_seq".NEXTVAL;
    END IF;
END;
/


-------trigger2----------
--Pokud pri tvorbe nove opravy neni prirazen mechanik, priradi se nahodny mechanik bez ohledu na jeho specializaci

CREATE OR REPLACE TRIGGER "auto_assign_mechanik"
BEFORE INSERT ON oprava
FOR EACH ROW
DECLARE
random_mechanik NUMBER;

BEGIN

SELECT "ID_MECHANIK" INTO random_mechanik FROM
    (SELECT "M"."OP" AS "ID_MECHANIK" FROM mechanik "M"
     ORDER BY dbms_random.value)
  WHERE rownum = 1;

IF :new."id_mechanik" IS NULL THEN
    :new."id_mechanik" := random_mechanik;
END IF;
END;
/

insert into osoba ("OP", "jmeno_prijmeni", "tel_cislo", "email")
values (123456789, 'Petr Novy', 989456123, 'petanov@seznam.cz');
insert into osoba ("OP", "jmeno_prijmeni", "tel_cislo", "email")
values (223456789, 'Alexandr Maly', 589456123, 'alik78@centrum.cz');
insert into osoba ("OP", "jmeno_prijmeni", "tel_cislo", "email")
values (323456789, 'David Chytry', 689456123, '11clever11@gmail.com');
insert into osoba ("OP", "jmeno_prijmeni", "tel_cislo", "email")
values (784542587, 'Hurvinek Dreveny', 450158857, 'milujuduby@rezbar.sk');
insert into osoba ("OP", "jmeno_prijmeni", "tel_cislo", "email")
values (111555777, 'Kvetoslav Kudrlinka', 666333666, 'zelenina4real@rajskazahrada.md');
insert into osoba ("OP", "jmeno_prijmeni", "tel_cislo", "email")
values (897987786, 'Pepik Duchodce', 775842328, 'nemamemail@cojedomena.cech');
insert into osoba ("OP", "jmeno_prijmeni", "tel_cislo", "email")
values (456544478, 'Marecek Hlinik', 777888999, 'jsemseprestehoval@humpolec.cz');

insert into mechanik ("OP", "bydliste", "datum_narozeni", "mzda", "bankovni_spojeni" )
values (123456789, 'Friedberg', TO_DATE('8-11-1948', 'dd/mm/yyyy'), 23568, '753421869/0100');
insert into mechanik ("OP", "bydliste", "datum_narozeni", "mzda", "bankovni_spojeni" )
values (323456789, 'Petrohrad', TO_DATE('7-1-1979', 'dd/mm/yyyy'), 33568, '853421869/0200');
insert into mechanik ("OP", "bydliste", "datum_narozeni", "mzda", "bankovni_spojeni" )
values (456544478, 'Humpolec', TO_DATE('1-10-1976', 'dd/mm/yyyy'), 99666, '789653287/0300');

insert into specializace ("id", "typ")
values (4488, 'prevodovky');
insert into specializace ("id", "typ")
values (4487, 'motor');
insert into specializace ("id", "typ")
values (4486, 'lakovani');
insert into specializace ("id", "typ")
values (4485, 'brzdy');
insert into specializace ("id", "typ")
values (4484, 'vysavani');

insert into objednavka("id", "datum_vytvoreni", "predpokladane_datum_vyrizeni", "datum_zhotoveni", "predpokladana_cena", "finalni_cena", "zhotoveno", "id_osoba")
values (787878, TO_DATE('4-11-2008', 'dd/mm/yyyy'), TO_DATE('24-1-2009', 'dd/mm/yyyy'), TO_DATE('8-1-2009', 'dd/mm/yyyy'), 1523, 8473, 1, 123456789);
insert into objednavka("id", "datum_vytvoreni", "predpokladane_datum_vyrizeni", "datum_zhotoveni", "predpokladana_cena", "finalni_cena", "zhotoveno", "id_osoba")
values (187878, TO_DATE('14-5-2015', 'dd/mm/yyyy'), TO_DATE('1-1-2016', 'dd/mm/yyyy'), TO_DATE('5-1-2016', 'dd/mm/yyyy'), 523, 5863, 1, 223456789);
insert into objednavka("id", "datum_vytvoreni", "predpokladane_datum_vyrizeni", "datum_zhotoveni", "predpokladana_cena", "finalni_cena", "zhotoveno", "id_osoba")
values (287878, TO_DATE('24-1-2011', 'dd/mm/yyyy'), TO_DATE('4-11-2012', 'dd/mm/yyyy'), TO_DATE('2-1-2012', 'dd/mm/yyyy'), 11523, 583, 1, 223456789);
insert into objednavka("id", "datum_vytvoreni", "predpokladane_datum_vyrizeni", "datum_zhotoveni", "predpokladana_cena", "finalni_cena", "zhotoveno", "id_osoba")
values (297878, TO_DATE('29-3-2023', 'dd/mm/yyyy'), TO_DATE('18-4-2023', 'dd/mm/yyyy'), NULL, 299, NULL, 0, 897987786);

insert into oprava ("id", "typ", "straveny_cas", "predpokladana_cena", "finalni_cena", "zhotoveno", "id_objednavky", "id_mechanik")
values (NULL, 'chlazeni', 5, 1523, 1583, 1, 787878, NULL);
insert into oprava ("id", "typ", "straveny_cas", "predpokladana_cena", "finalni_cena", "zhotoveno", "id_objednavky", "id_mechanik")
values (89797979, 'chlazeni', 1, 10500, 12200, 0, 187878, 323456789);
insert into oprava ("id", "typ", "straveny_cas", "predpokladana_cena", "finalni_cena", "zhotoveno", "id_objednavky", "id_mechanik")
values (99797979, 'chlazeni', 58, 152, 112, 1, 287878, 323456789);
insert into oprava ("id", "typ", "straveny_cas", "predpokladana_cena", "finalni_cena", "zhotoveno", "id_objednavky", "id_mechanik")
values (NULL, 'chlazeni', 3, 123, 5847363, 1, 287878, NULL);
insert into oprava ("id", "typ", "straveny_cas", "predpokladana_cena", "finalni_cena", "zhotoveno", "id_objednavky", "id_mechanik")
values (78965265, 'vysavani', 0, 299, NULL, 0, 297878, NULL);

insert into material ("id", "mnozstvi_na_sklade", "cena")
values (65412, 2, 125);
insert into material ("id", "mnozstvi_na_sklade", "cena")
values (75412, 28, 1215);
insert into material ("id", "mnozstvi_na_sklade", "cena")
values (95412, 22, 1259);
insert into material ("id", "mnozstvi_na_sklade", "cena")
values (75856, 7, 7888);

insert into material_oprava ("mnozstvi", "id_material", "id_oprava")
values (21, 65412, 99797979);
insert into material_oprava ("mnozstvi", "id_material", "id_oprava")
values (21, 75412, 89797979);
insert into material_oprava ("mnozstvi", "id_material", "id_oprava")
values (21, 95412, 78965265);

insert into specializace_mechanik ("id_specializace", "id_mechanik")
values (4488, 123456789);
insert into specializace_mechanik ("id_specializace", "id_mechanik")
values (4487, 323456789);
insert into specializace_mechanik ("id_specializace", "id_mechanik")
values (4486, 323456789);
insert into specializace_mechanik ("id_specializace", "id_mechanik")
values (4484, 323456789);


-- Predvedeni triggeru1
-- Pri vkladani dat byla schvalne vynechana dve policka id opravy, tzn., ze v tabulkach budou id opravy 101 a 102
SELECT oprava."id" FROM oprava;

-- predvedeni triggeru2
-- Pri vkladani dat byla schvalne vynechana tri policka s id mechanika, tzn., ze u vsech oprav by mel byt prirazen mechanik
SELECT oprava."id_mechanik" FROM oprava;


-------procedure1----------
--Pri zadani cisla OP zakaznika vypise informace o jiz ukoncenych objednavkach, jejich mnozstvi, celkove cene a prumerne cene za objednavku
SET serveroutput ON; --nevim zda ma byt zakomentovana/pri testech na skolnim serveru jsem vyuzil moznost povolit output v prostredi DataGripu (potom je tento radek chapan jako chyba)

CREATE OR REPLACE PROCEDURE objednavka_uzivatel (OP_uzivatele osoba.OP%TYPE) AS
BEGIN
    DECLARE CURSOR kurzor IS
        SELECT osoba."OP", osoba."jmeno_prijmeni", objednavka."id", objednavka."finalni_cena"
        FROM osoba, objednavka
        WHERE OP_uzivatele = osoba."OP" AND objednavka."id_osoba" = osoba."OP" AND objednavka."zhotoveno" = 1;
    v_OP_osoby osoba."OP"%TYPE;
    v_jmeno_osoby osoba."jmeno_prijmeni"%TYPE;
    v_ID_objednavky objednavka."id"%TYPE;
    v_finalni_cena objednavka."finalni_cena"%TYPE;
    v_suma NUMBER;
    v_pocet NUMBER;
    v_prumer NUMBER;
    BEGIN    
        v_suma := 0;
        v_pocet := 0;
        v_prumer := 0;
        OPEN kurzor;
        LOOP
            FETCH kurzor INTO v_OP_osoby, v_jmeno_osoby, v_ID_objednavky, v_finalni_cena;
            EXIT WHEN kurzor%NOTFOUND;
            v_pocet := v_pocet + 1;
            v_suma := v_suma + v_finalni_cena;
        END LOOP;
        CLOSE kurzor;
        v_prumer := v_suma / v_pocet;
        dbms_output.put_line('Zakaznik ' || v_jmeno_osoby || ' s cislem OP ' || v_OP_osoby || ' jiz zaplatil ' ||
        v_pocet || ' objednavek za celkovou cenu '|| v_suma || ' Kc a prumer za objednavku tedy cini '|| v_prumer || ' Kc.');
        EXCEPTION WHEN zero_divide THEN
            BEGIN
                dbms_output.put_line('Dany zakaznik zatim nema ukoncenou a zaplacenou zadnou objednavku.');
            END;
    END;
END;
/

--testovani prvni procedury
-- zakaznik 123456789 ma jednu objednavku s cenou pres 8000
BEGIN
    objednavka_uzivatel(123456789);
END;
-- zakaznik 223456789 ma dve objednavky s celkovou cenou pres 6000
BEGIN
    objednavka_uzivatel(223456789);
END;
-- zakaznik 897987786 nema zatim zadnou ukoncenou objednavku
BEGIN
    objednavka_uzivatel(897987786);
END;


-------procedure2----------
-- Vypise statistiku o provedenych opravach delsich nez zadany cas v hodinach
CREATE OR REPLACE PROCEDURE pocet_oprav_delsich_nez (zadany_cas INT) AS
    v_pocet_oprav NUMBER;
    v_pocet_oprav_nad NUMBER;
    v_podil NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_pocet_oprav FROM oprava WHERE oprava."zhotoveno" = 1;
    SELECT COUNT(*) INTO v_pocet_oprav_nad FROM oprava WHERE oprava."zhotoveno" = 1 AND oprava."straveny_cas" > zadany_cas;
    v_podil := ROUND(100 * v_pocet_oprav_nad / v_pocet_oprav, 2);
    dbms_output.put_line('Ze zhotovenych ' || v_pocet_oprav || ' oprav zabralo vice nez ' || zadany_cas || ' hodin presne ' || v_pocet_oprav_nad ||
    ' oprav, coz cini ' || v_podil || '%.');
    EXCEPTION WHEN zero_divide THEN
        BEGIN
            dbms_output.put_line('V systemu neni zadna zadana oprava.');
        END;
END;
/

--testovani druhe procedury
-- necham si vypsat pocet a podil oprav nad 50 hodin
-- ze zhotovenych oprav vyhovuje pouze jedna, podil 33%
BEGIN
    pocet_oprav_delsich_nez(50);
END;
-- necham si vypsat pocet a podil oprav nad 150 hodin
-- ze zhotovenych oprav nevyhovuje zadna oprava
BEGIN
    pocet_oprav_delsich_nez(150);
END;


-------explain plan----------
-- Vypise uzivatele, kteri maji nejakou hotovou objednavku, pocet jejich objednavek a celkovou utratu, pak je seradi podle utraty
EXPLAIN PLAN FOR
SELECT
    osoba."OP" AS "OP zakaznika",
    osoba."jmeno_prijmeni" AS "Jmeno a prijmeni",
    COUNT(objednavka."id_osoba") AS "Pocet objednavek",
    SUM(objednavka."finalni_cena") AS "Celkova utrata"
FROM osoba
JOIN objednavka ON objednavka."id_osoba" = osoba."OP"
WHERE objednavka."zhotoveno" = 1
GROUP BY osoba."OP", osoba."jmeno_prijmeni"
ORDER BY "Celkova utrata" DESC;
--testovani
SELECT * FROM TABLE(dbms_xplan.display);

CREATE INDEX osoba_OP_jmeno_prijmeni ON osoba ("OP", "jmeno_prijmeni");
CREATE iNDEX objednavka_OP_cena_zhotoveno ON objednavka ("id_osoba", "finalni_cena", "zhotoveno");

-- Otestuje zda po vytvoreni indexu nebude probihat scan celych tabulek
EXPLAIN PLAN FOR
SELECT
    osoba."OP" AS "OP zakaznika",
    osoba."jmeno_prijmeni" AS "Jmeno a prijmeni",
    COUNT(objednavka."id_osoba") AS "Pocet objednavek",
    SUM(objednavka."finalni_cena") AS "Celkova utrata"
FROM osoba
JOIN objednavka ON objednavka."id_osoba" = osoba."OP"
WHERE objednavka."zhotoveno" = 1
GROUP BY osoba."OP", osoba."jmeno_prijmeni"
ORDER BY "Celkova utrata" DESC;
--testovani
SELECT * FROM TABLE(dbms_xplan.display);

-------materialized view----------
-- Vypise pocet objednavek od jednotlivych uzivatelu, a celkovou jejich utracenou castku
CREATE MATERIALIZED VIEW uzivatel_objednavka AS
SELECT
    osoba."OP",
    osoba."jmeno_prijmeni",
    osoba."tel_cislo",
    COUNT(objednavka."id_osoba") AS "Pocet objednavek zakaznika",
    SUM(objednavka."finalni_cena") AS "Utraceno"
FROM osoba
JOIN objednavka ON objednavka."id_osoba" = osoba."OP"
GROUP BY osoba."OP", osoba."jmeno_prijmeni", osoba."tel_cislo";

-- dukaz ze se jedna o samostatnou tabulku, nikoliv spojeni dvou tabulek v realnem case
-- Vypiseme pohled, aktualni databaze
SELECT * FROM uzivatel_objednavka;

-- Provedeni zmeny v puvodni databazi
insert into objednavka("id", "datum_vytvoreni", "predpokladane_datum_vyrizeni", "datum_zhotoveni", "predpokladana_cena", "finalni_cena", "zhotoveno", "id_osoba")
values (787811, TO_DATE('4-3-2018', 'dd/mm/yyyy'), TO_DATE('1-4-2018', 'dd/mm/yyyy'), TO_DATE('5-4-2018', 'dd/mm/yyyy'), 22180, 25800, 1, 123456789);

-- Pridali jsme objednavku, ktera by se v klasickem pohledu promitla, v materializovanem nikoliv
SELECT * FROM uzivatel_objednavka;


-------komplexni dotaz SELECT----------
SELECT
    oprava."id",
    oprava."typ",
    CASE
        WHEN oprava."finalni_cena" < 1000 THEN 'Levna oprava'
        WHEN oprava."finalni_cena" BETWEEN 1000 AND 10000 THEN 'Stredni oprava'
        ELSE 'Draha oprava'
    END AS "Cena opravy"
    FROM oprava
    WHERE oprava."zhotoveno" = 1;
    

-- Pristupova prava pro druheho clena tymu
GRANT ALL ON specializace_mechanik TO xchova25;
GRANT ALL ON specializace TO xchova25;
GRANT ALL ON material_oprava TO xchova25;
GRANT ALL ON oprava TO xchova25;
GRANT ALL ON mechanik TO xchova25;
GRANT ALL ON objednavka TO xchova25;
GRANT ALL ON material TO xchova25;
GRANT ALL ON osoba TO xchova25;

GRANT EXECUTE ON objednavka_uzivatel TO xchova25;
GRANT EXECUTE ON pocet_oprav_delsich_nez TO xchova25;

GRANT ALL ON uzivatel_objednavka TO xchova25;