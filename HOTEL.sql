drop table pokoje;
CREATE TABLE pokoje(
  pokoj_id number(3) PRIMARY KEY,
  numer varchar2(5),
  kategoria varchar2(30), -- vip i standard
  rodzaj_pokoju  varchar2(30),-- rodzinny , jednoosobowy, malzenski
  cena_za_dobe number(3),-- 70/os - vip , 50/os -standard
  czy_wolny varchar2(10),-- wolny , zajety
  ilosc_miejsc number(3)-- od 1 do 5 
); 
drop table goscie;
CREATE TABLE goscie(
  gosc_id number(3) PRIMARY KEY,
  imie varchar2(20),
  nazwisko varchar2(30),
  numer_dowodu varchar2(8),
  miasto varchar2(20),
  ulica_numer_domu varchar2(30),
  liczba_wizyt number(4)
); 
drop table rezerwacje;
CREATE TABLE rezerwacje(
  rezerwacja_id number(3) PRIMARY KEY,
  id_goscia number(2) NOT NULL,
  id_pokoju number(2),
  status varchar2(30), -- zamowione , przydzielone, oczekujace
  data_rozpoczecia DATE,
  data_zakonczenia DATE,
  koszt_pokoju number(6),
  czy_oplacono varchar2(30),--oplacone / nieoplacone 
  notatka varchar2(30),
  FOREIGN KEY (id_goscia) REFERENCES goscie(gosc_id),
  FOREIGN KEY (id_pokoju) REFERENCES pokoje(pokoj_id)
); 


INSERT into pokoje values (1, '1a', 'vip', 'jednoosobowy',70,'wolny',1); 
INSERT into pokoje values (2, '1b', 'standard', 'rodzinny',250,'wolny',5);
INSERT into pokoje values (3, '2a', 'standard', 'malzenski',100,'wolny',1);
INSERT into pokoje values (4, '2b', 'standard', 'rodzinny',150,'wolny',3);
INSERT into pokoje values (5, '3a', 'vip', 'malzenski',140,'wolny',1); 

INSERT into goscie values (1, 'Anna', 'Szczesna', 'AAa4456','Warszawa','Gdyniewska 09-123', 1);
INSERT into goscie values (2, 'Renia', 'Janowska', 'ABa4456','Sopot','Sopocka 09-123', 3);
INSERT into goscie values (3, 'Jan', 'Kowalski', 'AuR4456','Warszawa','Marszalkowska 09-123', 1);
INSERT into goscie values (4, 'Franek', 'Dobrawy', 'rAa4456','Kielce','Kielce 09-123', 5); 

INSERT into rezerwacje values (1, 2, 2, 'zamowione', TO_DATE('2019/11/09', 'yyyy/mm/dd'),TO_DATE('2019/11/16', 'yyyy/mm/dd'),null,'nieoplacone','-');
INSERT into rezerwacje values (2, 4, 1, 'zamowione', TO_DATE('2019/10/04', 'yyyy/mm/dd'),TO_DATE('2019/10/14', 'yyyy/mm/dd'),null,'nieoplacone','vip');
select * from rezerwacje ; 
select * from goscie ;
select * from pokoje ;  

--zad3
-- tworzenie i deklaracja pakietu 
DROP PACKAGE zad3;
CREATE OR REPLACE PACKAGE zad3
is
PROCEDURE dodaj_goscia(gosc_id number, imie varchar2, nazwisko varchar2, numer_dowodu varchar2, miasto varchar2, ulica_nr_domu varchar2);
FUNCTION czywolny(id_pokoju NUMBER,d1 DATE,d2 DATE) RETURN BOOLEAN;
PROCEDURE wypisz_wolne_pokoje(d1 DATE, d2 DATE);
FUNCTION znajdz_goscia_po_dowodzie(nr_dowodu varchar2) RETURN number;
PROCEDURE dodaj_rezerwacje(nr_dowodu varchar2, id_pokoju number,status varchar2, data_rozpoczecia DATE, data_zakonczenia DATE ,notatka varchar2);
PROCEDURE zgloszenie_goscia_do_hotelu(nr_dowodu varchar2, data_przybycia date);
PROCEDURE usun_rezerwacje(id_goscia1 number);
FUNCTION  diff_date(id_goscia1 number) return number;
PROCEDURE rachunek(nr_dowodu  varchar2);
PROCEDURE nie_zgloszone_osoby;
END zad3;  


create or replace package body zad3
is
id_goscia number(3);
numer_dowodu varchar2(8);

-- wpisz nowego goscia
PROCEDURE dodaj_goscia(gosc_id number, imie varchar2, nazwisko varchar2, numer_dowodu varchar2, miasto varchar2, ulica_nr_domu varchar2)
  IS
  BEGIN
    INSERT into goscie VALUES(gosc_id, imie, nazwisko, numer_dowodu, miasto, ulica_nr_domu, 1);
END dodaj_goscia;
--funkcja pomocnicza sprawdzajaca czy pokoj jest wolny od d1 do d2
FUNCTION czywolny(id_pokoju NUMBER,d1 DATE,d2 DATE)
RETURN BOOLEAN
IS
BEGIN
 FOR rez IN ( select * from rezerwacje where d1 <= data_rozpoczecia AND d2 >= data_zakonczenia) loop
    if id_pokoju = rez.id_pokoju then
         RETURN FALSE;
    END IF;
    end loop;
   RETURN TRUE;
END;
--wypisanie pokoi wolnych miedzy data d1 a d2
PROCEDURE wypisz_wolne_pokoje(d1 DATE, d2 DATE)
    IS
  BEGIN
       for pok in ( select * from pokoje)loop
           if czywolny(pok.pokoj_id,d1,d2)= true then
            DBMS_OUTPUT.PUT_LINE('POKOJ  ' ||  pok.numer || ' jest wolny w tym czasie ');
           end if;
    end loop;
END wypisz_wolne_pokoje; 
--funkcja pomocnicza
FUNCTION znajdz_goscia_po_dowodzie(nr_dowodu varchar2) return number
  is 
    id_1 number(3);
  BEGIN
     SELECT goscie.gosc_id INTO id_1 FROM goscie WHERE numer_dowodu = nr_dowodu;
    RETURN id_1;
  END znajdz_goscia_po_dowodzie;
--dokonanie rezerwacji  
PROCEDURE dodaj_rezerwacje (nr_dowodu varchar2, id_pokoju number,status varchar2, data_rozpoczecia DATE, data_zakonczenia DATE , notatka varchar2 )
is 
 id_goscia number(3);
 liczba_wizyt1 number(4);
 rezerwacja_id number(4);
 BEGIN
        SELECT COUNT(*) INTO rezerwacja_id FROM rezerwacje;
        id_goscia := zad3.znajdz_goscia_po_dowodzie(nr_dowodu);
        SELECT liczba_wizyt into liczba_wizyt1 FROM goscie WHERE id_goscia = goscie.gosc_id;
        liczba_wizyt1 := liczba_wizyt1 + 1;
        rezerwacja_id := rezerwacja_id +1;
        INSERT INTO rezerwacje values(rezerwacja_id , id_goscia, id_pokoju, status, data_rozpoczecia, data_zakonczenia,null,'nieoplacone',notatka);
        UPDATE goscie SET liczba_wizyt = liczba_wizyt1 WHERE goscie.gosc_id = id_goscia;

 END dodaj_rezerwacje; 
 -- gosc zglosil sie do hotelu
PROCEDURE zgloszenie_goscia_do_hotelu(nr_dowodu varchar2, data_przybycia date)
  is 
   id_goscia1 number(3);
   v_date date;
   wrong exception;
  begin
  SELECT SYSDATE INTO v_date FROM dual;
  if data_przybycia > v_date then RAISE wrong;
  else
   id_goscia1 := znajdz_goscia_po_dowodzie(nr_dowodu);
FOR rez IN ( select * from rezerwacje ) loop
       if data_przybycia = rez.data_rozpoczecia AND id_goscia1 = rez.id_goscia then
        rez.status := 'przydzielone';
        UPDATE rezerwacje set rezerwacje.status = rez.status where rezerwacje.rezerwacja_id = rez.rezerwacja_id ; 
        UPDATE pokoje SET pokoje.czy_wolny = 'zajety' WHERE pokoje.pokoj_id = rez.id_pokoju;
       end if;
    end loop;
    end if;
EXCEPTION
WHEN wrong THEN
dbms_output.put_line('Data przybycia goœcia do hotelu nie moze byc wieksza od dzisiejszej');
END zgloszenie_goscia_do_hotelu;
--usun rezerwacje
PROCEDURE usun_rezerwacje( id_goscia1 number)
  is 
   
  begin
    DELETE FROM rezerwacje WHERE rezerwacje.id_goscia = id_goscia1;
END usun_rezerwacje; 
-- funkcja pomocnicza ró¿nica dat
FUNCTION diff_date(id_goscia1 number) return number
    is
        rozpoczecie date;
        zakonczenie date;
    begin
        SELECT data_rozpoczecia into rozpoczecie FROM rezerwacje WHERE rezerwacje.id_goscia = id_goscia1;
        SELECT data_zakonczenia into zakonczenie FROM rezerwacje WHERE rezerwacje.id_goscia = id_goscia1;
    return zakonczenie - rozpoczecie;
END;

-- przygotuj rachunek dla goœcia (przyznaj¹c mu rabat jeœli jest czêstym goœciem)
PROCEDURE rachunek(nr_dowodu varchar2)
    is 
    id_goscia1 number(3);
    id_pokoju1 number(3);
    liczba_dni number(3);
    koszt number(6);
    liczba_wizyt1 number(3);
    cena_za_dobe1 number(4);
    status_rezerwacji varchar2(30);
    WRONG exception;
  
  begin
    id_goscia1 := znajdz_goscia_po_dowodzie(nr_dowodu);
    liczba_dni := diff_date(id_goscia1);
    for rez in(select * from rezerwacje) loop 
    if rez.id_goscia = id_goscia1 then 
    id_pokoju1 := rez.id_pokoju;
    status_rezerwacji:= rez.status;
    end if; 
    end loop;
    for pok in( select * from pokoje)loop 
    if  id_pokoju1 = pok.pokoj_id then 
    cena_za_dobe1:= pok.cena_za_dobe;
    end if;
    end loop;
    for g in ( select * from goscie) loop
    if g.gosc_id = id_goscia1 then
    liczba_wizyt1 := g.liczba_wizyt;
    end if;
    end loop;
    IF liczba_wizyt1 >= 2 THEN  cena_za_dobe1 := cena_za_dobe1 - (cena_za_dobe1 * 0.2); -- rabat
    ELSIF liczba_wizyt1 >=10 THEN  cena_za_dobe1 := cena_za_dobe1 - (cena_za_dobe1 * 0.3); -- rabat
    END IF;
    koszt := liczba_dni * cena_za_dobe1;
   
    if status_rezerwacji = 'przydzielone' then
    UPDATE rezerwacje SET koszt_pokoju = koszt,czy_oplacono = 'oplacono' where rezerwacje.id_goscia = id_goscia1 ;
    UPDATE pokoje SET pokoje.czy_wolny = 'wolny' WHERE pokoje.pokoj_id =  id_pokoju1;-- jesli wystawiamy rachunek nasz gosc opuszcza pokoj
    UPDATE goscie SET goscie.liczba_wizyt = liczba_wizyt1 where goscie.gosc_id = id_goscia1;
    else RAISE WRONG;
    end if;
    EXCEPTION
    WHEN WRONG THEN
    dbms_output.put_line('Rachunek jest wystawiany gosciom zakwaterowanym na koniec pobytu!');
END rachunek;
-- wyznacz osoby, które dokona³y rezerwacji, a jeszcze nie zg³osi³y siê danego dnia
 PROCEDURE nie_zgloszone_osoby
    is
        v_date date;
    begin
SELECT SYSDATE INTO v_date FROM dual;
    for rez in ( select * from rezerwacje ) loop
     if rez.data_rozpoczecia <= v_date AND rez.status = 'zamowione' then
       for gosc in (select * from goscie)loop
         if gosc.gosc_id = rez.id_goscia then 
            dbms_output.put_line(gosc.imie ||' '|| gosc.nazwisko);
         end if;
      end loop;
     end if;
    end loop;
END nie_zgloszone_osoby; 

END;
SET SERVEROUTPUT ON
select * from rezerwacje;
select * from goscie;

BEGIN 
 --zad3.dodaj_goscia(5, 'Kasia','Kowal','A28993','Siedlce','3maja 23'); 
  --zad3.dodaj_rezerwacje('AuR4456', 3,'zamowione', TO_DATE('2019/10/13', 'yyyy/mm/dd'),TO_DATE('2019/10/18', 'yyyy/mm/dd'),'standard');
 --zad3.wypisz_wolne_pokoje(TO_DATE('2019/11/20', 'yyyy/mm/dd'),TO_DATE('2019/11/28', 'yyyy/mm/dd'));
--zad3.zgloszenie_goscia_do_hotelu('rAa4456', TO_DATE('2019/10/04', 'yyyy/mm/dd'));
 --DBMS_OUTPUT.PUT_LINE(zad3.diff_date(2));
--zad3.rachunek('rAa4456');
--zad3.usun_rezerwacje(2);
zad3.nie_zgloszone_osoby();
END;
INSERT into rezerwacje values (1, 2, 2, 'zamowione', TO_DATE('2019/10/09', 'yyyy/mm/dd'),TO_DATE('2019/10/16', 'yyyy/mm/dd'),null,'nieoplacone','-');

select * from goscie;
select * from rezerwacje; 
select * from pokoje; 
-- zad4  
CREATE TABLE podsum(
    id_gosc number(3) PRIMARY KEY,
    imie varchar2(20),
    nazwisko varchar2(30),
    ile_razy number(3),
    jak_dlugo number(4)
);
select * from podsum;
drop table podsum;
--funkcja pomocnicza do zadania 4 sprawdzajaca czy gosc dokonal rezerwazji i obliczajaca na podstawie tego
-- dlugosc pobytu w przeciwnym wypadku zwracajaca 0 gdy gosc nie dokonal rezerwacji i dlugosc pobytu jest
-- nieznana
CREATE OR REPLACE function pobyt_w_hotelu (id_gosc number)return number
is 
pobyt number(4);
begin 
pobyt:=0;
 for rez in (select * from rezerwacje) loop
 if id_gosc = rez.id_goscia then 
pobyt:= rez.data_zakonczenia- rez.data_rozpoczecia;
end if;
end loop;
return pobyt;
end;
-- procedura ktora dla kazdego goscia hotelowego oblicza ile ile razy i jak dlugo byl w 
-- hotelu informacje wstawia do tabeli podsum 
CREATE OR REPLACE PROCEDURE przebywanie_w_hotelu
    is
    pobyt number(4);
    begin 
    for gosc in (select * from goscie)loop
     pobyt:= pobyt_w_hotelu(gosc.gosc_id);
     INSERT INTO podsum VALUES (gosc.gosc_id, gosc.imie , gosc.nazwisko , gosc.liczba_wizyt ,pobyt);
    end loop;
  END;
--procedura usuwa wszystkie rezerwacje dotycz¹ce pobytów starszych ni¿ z przed piêciu lat
 
CREATE OR REPLACE PROCEDURE usun_stare_rezerwacje
    is
    l_date date;
    begin
    l_date := ADD_MONTHS (SYSDATE, -5*12); -- 5 lat wstecz
    DELETE FROM rezerwacje WHERE rezerwacje.data_zakonczenia < l_date;
END;
select * from rezerwacje;
begin
--dbms_output.put_line(pobyt_w_hotelu(5));
--przebywanie_w_hotelu();
--INSERT into rezerwacje values (4, 1, 5, 'zamowione', TO_DATE('2013/08/09', 'yyyy/mm/dd'),TO_DATE('2013/08/16', 'yyyy/mm/dd'),null,'nieoplacone','-');--dane testowe
usun_stare_rezerwacje();
end;  
-- zad 5 
-- trigger spawdzajacy czy data rozpoczecia jest wczesniejsza niz data zakonczenia
create or replace trigger czy_data_sie_zgadza
before insert or update of data_rozpoczecia, data_zakonczenia
on rezerwacje
for each row
declare
  temp Date;
begin
    if(TO_DATE(:NEW.data_rozpoczecia, 'YYYY-MM-DD') > TO_DATE(:NEW.data_zakonczenia, 'YYYY-MM-DD')) 
    then        
       temp:=:NEW.data_rozpoczecia;
       :NEW.data_rozpoczecia := :NEW.data_zakonczenia;
       :NEW.data_zakonczenia := temp;
    end if;
end;
-- trigger - wyzwalacz aktualizuje wartosci ile_razy i jak_dlugo w tabeli Podsum
create or replace trigger aktualizator_podsum
after INSERT OR UPDATE of id_goscia,data_zakonczenia,data_rozpoczecia
on rezerwacje

for each row
DECLARE
    pobyt number(3);
    ile number(3);
begin
     pobyt := :NEW.data_zakonczenia - :NEW.data_rozpoczecia;
     SELECT goscie.liczba_wizyt INTO ile FROM goscie WHERE goscie.gosc_id = :NEW.id_goscia ;
     UPDATE podsum SET podsum.ile_razy = ile, podsum.jak_dlugo = pobyt WHERE podsum.id_gosc = :NEW.id_goscia;
end; 
ALTER TRIGGER aktualizator_podsum ENABLE;
drop trigger aktualizator_podsum; 
select * from podsum;
select * from rezerwacje;
select * from goscie;
create or replace trigger aktualizator_podsum_gosc
before insert on goscie
for each row
begin
   INSERT INTO podsum VALUES (:NEW.gosc_id, :NEW.imie , :NEW.nazwisko , :NEW.liczba_wizyt ,0);
end;
begin 
INSERT into rezerwacje values (5, 1, 4, 'zamowione', TO_DATE('2019/10/17', 'yyyy/mm/dd'),TO_DATE('2019/10/26', 'yyyy/mm/dd'),null,'nieoplacone','standard');--dane testowe 
INSERT into rezerwacje values (6, 5, 5, 'zamowione', TO_DATE('2019/12/17', 'yyyy/mm/dd'),TO_DATE('2019/12/10', 'yyyy/mm/dd'),null,'nieoplacone','-');--dane testowe
INSERT into goscie values (6, 'Jan', 'Papis', 'bab3456','Radom','Krakowska 13', 1); 
end;
select * from goscie;
select * from rezerwacje;
select * from pokoje;
select *from podsum;
delete from rezerwacje where rezerwacja_id >3; 
--Dokonaj rezerwacji pokoju dla VIP-a na jedn¹ noc. Jeœli nie ma wolnego pokoju
--spe³niaj¹cego oczekiwania goœcia, wœród osób, które dokona³y rezerwacji na pokój
--spe³niaj¹cy specyfikacjê VIP-a, wybierz jedn¹ z nich - nie maj¹c¹ statusu VIP i zamieñ jej
--rezerwacjê na rezerwacjê dla VIP-a. Skasowan¹ rezerwacjê na pokój zamieñ na
--zamówion¹ rezerwacjê.

create or replace procedure rezerwacja_vipa(data_przyjazdu date , nr_dowodu varchar2 , rodzaj_pok varchar2)
is
data_odjazdu date;
id_g number(3);
id_rez number(3);
id_pok number(3);
begin
data_odjazdu:=data_przyjazdu + 1;
id_g:= zad3.znajdz_goscia_po_dowodzie(nr_dowodu);
for pok in (select * from pokoje) loop 
if pok.kategoria = 'vip' AND pok.rodzaj_pokoju =rodzaj_pok then
id_pok:= pok.pokoj_id;
end if;
end loop;
if zad3.czywolny(id_pok , data_przyjazdu , data_odjazdu) = true then
zad3.dodaj_rezerwacje(nr_dowodu, id_pok,'zamowione', data_przyjazdu,data_odjazdu,'vip');
ELSIF zad3.czywolny(id_pok , data_przyjazdu , data_odjazdu) = false then
for r in (select * from rezerwacje) loop
if r. id_pokoju = id_pok and r.notatka<>'vip' then
id_rez:= r.  rezerwacja_id;
end if;
end loop;
UPDATE rezerwacje SET rezerwacje.status = 'oczekujace' WHERE rezerwacje.rezerwacja_id = id_rez;
zad3.dodaj_rezerwacje(nr_dowodu, id_pok,'zamowione', data_przyjazdu,data_odjazdu,'vip');
end if;
end; 

select * from rezerwacje;
delete from goscie where gosc_id= 6;
delete from rezerwacje where rezerwacja_id = 6;
delete from podsum where podsum.id_gosc =6;
update rezerwacje set rezerwacje.status = 'zamowione' where rezerwacja_id = 5;
SET SERVEROUTPUT ON
begin 
rezerwacja_vipa(TO_DATE('2019/12/13', 'yyyy/mm/dd') , 'bab3456' ,'malzenski');

end;
