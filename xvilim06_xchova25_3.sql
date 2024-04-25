-- SQL skript pro vytvoreni zakladnich struktur databaze a jejich naplneni
-- Dan Vilimvsky    (xvilim06)
-- David Chovanec   (xchova25)
--
-- 3. cast projektu IDS
-- Tym: xvilim06
-- Zadani: 7) Autoopravna

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
values (79797979, 'chlazeni', 5, 1523, 5847363, 1, 787878, 123456789);
insert into oprava ("id", "typ", "straveny_cas", "predpokladana_cena", "finalni_cena", "zhotoveno", "id_objednavky", "id_mechanik")
values (89797979, 'chlazeni', 1, 153, 5847363, 0, 187878, 323456789);
insert into oprava ("id", "typ", "straveny_cas", "predpokladana_cena", "finalni_cena", "zhotoveno", "id_objednavky", "id_mechanik")
values (99797979, 'chlazeni', 58, 152, 5847363, 1, 287878, 323456789);
insert into oprava ("id", "typ", "straveny_cas", "predpokladana_cena", "finalni_cena", "zhotoveno", "id_objednavky", "id_mechanik")
values (19797979, 'chlazeni', 3, 123, 5847363, 1, 287878, 323456789);
insert into oprava ("id", "typ", "straveny_cas", "predpokladana_cena", "finalni_cena", "zhotoveno", "id_objednavky", "id_mechanik")
values (78965265, 'vysavani', 0, 299, NULL, 0, 297878, 323456789);

insert into material ("id", "mnozstvi_na_sklade", "cena")
values (65412, 2, 125);
insert into material ("id", "mnozstvi_na_sklade", "cena")
values (75412, 28, 1215);
insert into material ("id", "mnozstvi_na_sklade", "cena")
values (95412, 22, 1259);
insert into material ("id", "mnozstvi_na_sklade", "cena")
values (75856, 7, 7888);

insert into material_oprava ("mnozstvi", "id_material", "id_oprava")
values (21, 65412, 79797979);
insert into material_oprava ("mnozstvi", "id_material", "id_oprava")
values (21, 75412, 89797979);
insert into material_oprava ("mnozstvi", "id_material", "id_oprava")
values (21, 95412, 19797979);

insert into specializace_mechanik ("id_specializace", "id_mechanik")
values (4488, 123456789);
insert into specializace_mechanik ("id_specializace", "id_mechanik")
values (4487, 323456789);
insert into specializace_mechanik ("id_specializace", "id_mechanik")
values (4486, 323456789);
insert into specializace_mechanik ("id_specializace", "id_mechanik")
values (4484, 323456789);

-- spojeni dvou tabulek - vypis informaci o mechanikove vyplate

SELECT "O"."jmeno_prijmeni" AS "Jméno a příjmení", "O"."OP" AS "Číslo OP", "M"."mzda" AS "Mzda", "M"."bankovni_spojeni" AS "Bankovní účet"
FROM osoba "O", mechanik "M"
WHERE "O"."OP" = "M"."OP"

-- spojeni dvou tabulek - material pouzity na opravu

SELECT "O"."id" AS "ID opravy", "O"."typ" AS "Typ opravy", "M"."id_material" AS "ID materiálu", "M"."mnozstvi" AS "Počet požití"
FROM oprava "O", material_oprava "M"
WHERE "O"."id" = "M"."id_oprava"

-- spojeni tri tabulek - vypise prirazeni cisla OP mechanika k jeho specializacim

SELECT "M"."OP" AS "Číslo OP", "S"."typ" AS "Specializace"
FROM mechanik "M", specializace "S", specializace_mechanik "SM"
WHERE ("M"."OP" = "SM"."id_mechanik" AND "S"."id" = "SM"."id_specializace")

-- group by s agregacni funkci - vypise OP mechanika se specializaci a kolik jich ma

SELECT "id_mechanik" AS "Občanský průkaz mechanika", COUNT(*) Počet FROM specializace_mechanik GROUP BY "id_mechanik"

-- group by s agregacni funkci - vypise id objednavky a kolik ma oprav

SELECT "id_objednavky" AS "ID objednávky", COUNT(*) Počet FROM oprava GROUP BY "id_objednavky"

-- exists - vypise vsechny mechaniky z tabulky osob

SELECT "O"."jmeno_prijmeni" AS "Jméno a příjmení"
FROM osoba "O"
WHERE EXISTS
(
    SELECT "M"."OP"
    FROM mechanik "M"
    WHERE  "M"."OP" = "O"."OP"
)

-- in - vypise klienty, kteri nejsou mechanici

SELECT "O"."jmeno_prijmeni" AS "Jméno a příjmení"
FROM osoba "O"
WHERE "O"."OP" NOT IN
(
    SELECT DISTINCT "M"."OP"
    FROM mechanik "M"
)
