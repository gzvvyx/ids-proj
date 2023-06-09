drop table Person cascade constraints;
drop table Employee cascade constraints;
drop table Room cascade constraints;
drop table Reservation cascade constraints;
drop table Apartment cascade constraints;
drop table Regular cascade constraints;
drop table Service cascade constraints;
drop table RoomService cascade constraints;
drop table ReservationPerson cascade constraints;
drop table ReservationService cascade constraints;

create table Person (
  PersonID number generated by default as identity primary key,
  Name varchar2(25) check (regexp_like(Name, '^[A-Z][a-z]+\ [A-Z][a-z]+$')) not null,
  Sex varchar2(6) check (Sex in ('Male', 'Female')),
  Address varchar2(100) not null,
  Mail varchar2(30) check (regexp_like(Mail, '^[a-zA-Z0-9_%*-+]+\@[a-z.]+\.[a-z]{2,3}$')),
  Birth date not null
);

-- Generalizace/specializace podle 3. pravidla v prezentaci
-- aby bylo mozne poslat PK toho kdo vytvoril rezervaci jako FK do rezervace
-- a zaroven PK vsech lidi, na ktere se rezervace vstahuje
create table Employee (
  PersonID number generated by default as identity primary key,
  Name varchar2(25) check (regexp_like(Name, '^[A-Z][a-z]+\ [A-Z][a-z]+$')) not null,
  Sex varchar2(6) check (Sex in ('Male', 'Female')),
  Address varchar2(100) not null,
  Mail varchar2(30) check (regexp_like(Mail, '^[a-zA-Z0-9_%*-+]+\@[a-z.]+\.[a-z]{2,3}$')),
  Birth date not null,
  Login varchar2(8) not null,
  Authorization varchar2(8) check (Authorization in ('Employee', 'Admin', 'Manager')) not null
);

create table Service (
  ServiceID number generated by default as identity primary key,
  Name varchar2(25) check (regexp_like(Name, '^[A-Z][a-z\ ]+$')) not null,
  Price number(*,2) not null,
  Description varchar2(255)
);

create table Room (
  RoomNumber number generated by default as identity primary key,
  Floor number(2,0) not null,
  IsAvailable char check ( IsAvailable in ('Y', 'N')) not null,
  Price number(*,2) not null,
  Description varchar2(255)
);

-- Generalizace/specializace podle 1. pravidla v prezentaci
-- protoze regular a apartment jsou pouze dodatecne informace o room entite
create table Regular (
  Bed varchar2(7) check (Bed in ('Single', 'Double','2Single')) not null,
  RoomInfo number not null,
  FOREIGN KEY (RoomInfo) REFERENCES Room(RoomNumber)
);

create table Apartment (
  Room_quantity number not null,
  Capacity number not null,
  DoubleBed char check ( DoubleBed in ('Y', 'N')) not null,
  Room number not null,
  FOREIGN KEY (Room) REFERENCES Room(RoomNumber)
);

create table Reservation (
  ReservationID number generated by default as identity primary key,
  DateFrom date,
  DateTo date,
  Price number(*,2),
  Payment varchar2(7) check ( Payment in ('Card', 'Cash', 'Bitcoin')) not null,
  RoomNumber number not null,
  MadeBy number not null,
  FOREIGN KEY (RoomNumber) REFERENCES Room(RoomNumber) on delete cascade,
  FOREIGN KEY (Madeby) REFERENCES Employee(PersonID) on delete cascade
);

create table RoomService (
    PRIMARY KEY (Room, Service),
    Room number not null,
    Service number not null,
    FOREIGN KEY (Room) REFERENCES Room(RoomNumber) on delete cascade,
    FOREIGN KEY (Service) REFERENCES Service(ServiceID) on delete cascade
);

create table ReservationPerson (
    PRIMARY KEY (Reservation, Person),
    Reservation number not null,
    Person number not null,
    FOREIGN KEY (Reservation) REFERENCES Reservation(ReservationID) on delete cascade,
    FOREIGN KEY (Person) REFERENCES Person(PersonID) on delete cascade
);

create table ReservationService (
    PRIMARY KEY (Reservation, Service),
    Reservation number not null,
    Service number not null,
    FOREIGN KEY (Reservation) REFERENCES Reservation(ReservationID) on delete cascade,
    FOREIGN KEY (Service) REFERENCES Service(ServiceID) on delete cascade
);

insert into Room (Floor, IsAvailable, Price, Description) values ('1','N','305.59','Apartman pro rodiny');
insert into Room (Floor, IsAvailable, Price, Description) values ('2','N','250.257','Pokoj se dvema normalnimi postelemi');
insert into Room (Floor, IsAvailable, Price, Description) values ('3','Y','167.00','Pokoj s jednou spojenou posteli');
insert into Room (Floor, IsAvailable, Price, Description) values ('5','N','385.02','Pokoj, ktery jeste nebyl rezervovany');


insert into Apartment (Room_quantity, Capacity, DoubleBed, Room) values ('3', '5', 'Y', '1');
insert into Regular (Bed, RoomInfo) values ('2Single', '2');
insert into Regular (Bed, RoomInfo) values ('Double', '3');
insert into Regular (Bed, RoomInfo) values ('Double', '4');


insert into Person (Name, Sex, Address, Mail, Birth) values ('Tomas Novy', 'Male', 'Kocotomov 38', 'kocotom@gmail.com', date '1999-01-16');
insert into Person (Name, Sex, Address, Mail, Birth) values ('Andrej Nespor', 'Male', 'Na vyherni 38', 'xnespo10@stud.fit.vutbr.cz', date '2002-07-20');
insert into Person (Name, Sex, Address, Mail, Birth) values ('Matej Tomko', 'Male', 'Trapakov 38', 'xtomko07@fit.vutbr.cz', date '2002-08-02');
insert into Person (Name, Sex, Address, Mail, Birth) values ('Timotej Vesely', 'Male', 'Madarsko 38', 'veselyt@hotmail.com', date '2001-04-01');
insert into Person (Name, Sex, Address, Mail, Birth) values ('Adriana Nebeska', 'Female', 'Moravska 38', 'adrinka@seznam.cz', date '2001-11-16');


insert into Employee (Name, Sex, Address, Mail, Birth, Login, Authorization) values ('Josef Holy', 'Male', 'Pod mostem 69, Zlin', 'josefholy@gmial.com', date '1984-02-02', 'xholyz00', 'Employee');
insert into Employee (Name, Sex, Address, Mail, Birth, Login, Authorization) values ('Andrea Zelena', 'Female', 'Na vyhlidce 36, Brno', 'andreazelena@email.cz', date '1991-03-03', 'xzelen00','Admin');
insert into Employee (Name, Sex, Address, Mail, Birth, Login, Authorization) values ('Jan Modry', 'Male', 'Nad mostem 69, Ostrava', 'janmodry@gmial.com', date '1984-02-02', 'xmodry00', 'Employee');


insert into Service (Name, Price, Description) values ('Snidane', '156.65', 'Hoste maji narok na snidani v nasi restauraci po predlozeni dukazu rezervace');
insert into Service (Name, Price, Description) values ('Uklid po vystehovani', '18832.00', 'Automaticka sluzba po vystehovani');
insert into Service (Name, Price, Description) values ('Bezbarierovy pristup', '0', 'Pokoj s bezbarierovym pristupem');
insert into Service (Name, Price, Description) values ('Vecere', '100', 'Vecere');


insert into Reservation (DateFrom, DateTo, Price, Payment, RoomNumber, MadeBy) values (date '2023-03-24', date '2023-03-27', '55.55', 'Card', '1', '1');
insert into Reservation (DateFrom, DateTo, Price, Payment, RoomNumber, MadeBy) values (date '2023-03-28', date '2023-03-29', '66.55', 'Cash', '1', '1');
insert into Reservation (DateFrom, DateTo, Price, Payment, RoomNumber, MadeBy) values (date '2023-03-24', date '2023-03-27', '77.55', 'Bitcoin', '2', '1');
insert into Reservation (DateFrom, DateTo, Price, Payment, RoomNumber, MadeBy) values (date '2023-04-24', date '2023-05-27', '343.14', 'Bitcoin', '3', '3');


insert into RoomService (Room, Service) values ('1', '3');
insert into RoomService (Room, Service) values ('4', '3');

insert into ReservationPerson (Reservation, Person) values ('1', '1');
insert into ReservationPerson (Reservation, Person) values ('1', '2');
insert into ReservationPerson (Reservation, Person) values ('2', '3');
insert into ReservationPerson (Reservation, Person) values ('4', '2');

insert into ReservationService (Reservation, Service) values ('1', '2');
insert into ReservationService (Reservation, Service) values ('2', '1');
insert into ReservationService (Reservation, Service) values ('4', '1');

------------------------------------- TRIGGERS ----------------------------------------

-- Trigger 1
-- Update price of a reservation whenever a new room is added or removed from it
CREATE OR REPLACE TRIGGER update_reservation_price
AFTER INSERT ON ReservationService
FOR EACH ROW
DECLARE
    new_service_price Service.Price%TYPE;
BEGIN
    -- Get the price of the newly added service
    SELECT Price INTO new_service_price FROM Service WHERE ServiceID = :new.Service;

    -- Update the reservation price by adding the price of the new service
    UPDATE Reservation
    SET Price = Price + new_service_price
    WHERE ReservationID = :new.Reservation;
END;

INSERT INTO ReservationService (Reservation, Service) values ('1', '4');

-- Trigger 2
-- trigger that prevents the deletion of a Room if it is currently part of an active reservation
CREATE OR REPLACE TRIGGER check_reservation_date
BEFORE INSERT ON Reservation
FOR EACH ROW
BEGIN
    IF :new.DateFrom < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20000, 'Cannot make a reservation with a start date in the past.');
    END IF;
END;

-- Vyhodi error
-- INSERT INTO Reservation (DateFrom, DateTo, Price, Payment, RoomNumber, MadeBy) values (date '1000-03-24', date '1000-03-27', '55.55', 'Card', '1', '1');

------------------------------------- PROCEDURES --------------------------------------

-- Procedure 1
-- Update the price of a service based on the input ServiceID
CREATE OR REPLACE PROCEDURE update_service_price
    (p_service_id IN Service.ServiceID%TYPE,
     p_new_price IN Service.Price%TYPE)
IS
BEGIN
    UPDATE Service SET Price = p_new_price WHERE ServiceID = p_service_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Service price updated successfully.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Invalid Service ID');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
        ROLLBACK;
END;


-- Procedure 2
-- Use cursor to display all reservations for a given room number
CREATE OR REPLACE PROCEDURE display_reservations_for_room
    (p_room_number IN Room.RoomNumber%TYPE)
IS
    CURSOR c_reservations IS
        SELECT ReservationID, DateFrom, DateTo, Price
        FROM Reservation
        WHERE RoomNumber = p_room_number;
    v_reservation_id Reservation.ReservationID%TYPE;
    v_date_from Reservation.DateFrom%TYPE;
    v_date_to Reservation.DateTo%TYPE;
    v_price Reservation.Price%TYPE;
BEGIN
    OPEN c_reservations;
    DBMS_OUTPUT.PUT_LINE('Reservations for Room ' || p_room_number || ':');
    LOOP
        FETCH c_reservations INTO v_reservation_id, v_date_from, v_date_to, v_price;
        EXIT WHEN c_reservations%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_reservation_id || ' ' || v_date_from || ' ' || v_date_to || ' ' || v_price);
    END LOOP;
    CLOSE c_reservations;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;

-- Old service price
-- SELECT Name, Price FROM Service
-- WHERE ServiceID = 1;

-- Potřeba DBMSOUTPUT pro zobrazení outputu (CTRL + F8)
-- Změny pro Proceduru2 můžeme vidět také skrze zakomentované selecty
BEGIN
    update_service_price(1, 10);
    display_reservations_for_room(1);
end;

-- New service price
-- SELECT Name, Price FROM Service
-- WHERE ServiceID = 1;

------------------------------ SELECT w/ WITH & CASE -----------------------------------

-- WITH klauzle k definici sub-query, která spojí tabulky Reservation, ReservationPerson, Person, ReservationService a Service
-- Získá infomrace o všech rezervacích
-- Complete reservation info W&C select
WITH reservation_info AS (
  SELECT
    r.ReservationID,
    r.DateFrom,
    r.DateTo,
    r.Price,
    r.Payment,
    rp.Person,
    p.Name,
    rs.Service,
    s.Name AS ServiceName,
    s.Price AS ServicePrice
  FROM Reservation r
  LEFT JOIN ReservationPerson rp ON r.ReservationID = rp.Reservation
  LEFT JOIN Person p ON rp.Person = p.PersonID
  LEFT JOIN ReservationService rs ON r.ReservationID = rs.Reservation
  LEFT JOIN Service s ON rs.Service = s.ServiceID
)
SELECT
  ReservationID,
  Name,
  DateFrom,
  DateTo,
  Price,
  Payment,
  CASE
    WHEN ServicePrice IS NOT NULL THEN Price + SUM(ServicePrice) OVER (PARTITION BY ReservationID)
    ELSE Price
  END AS TotalPrice
FROM reservation_info
ORDER BY ReservationID;


----------------------------------- SELECTS -------------------------------------------

-- Pocet rezervaci podle zamestnance + maximalni a prumerna cena rezervace
-- 2 tables
-- Number of res by employee + max, avg price
SELECT e.Name, e.Login as Employee_Name, COUNT(r.ReservationID) as Number_of_Reservations, MAX(r.Price) as Max_Price, AVG(r.Price) as Average_Price
FROM Employee e
JOIN Reservation r ON e.PersonID = r.MadeBy
GROUP BY e.Name, e.Login;

-- Jmena vsech lidi v systemu a pocet jejich rezervaci (vcetne zamestnancu)
-- 2 tables
-- All people registered and their ResCount
SELECT p.Name, count(r.ReservationID) AS ReservationCount
FROM Person p
LEFT JOIN Reservation r ON p.PersonID = r.MadeBy
GROUP BY p.Name
ORDER BY ReservationCount DESC;

-- Vsechny nekdy rezervovane mistnosti
-- 3 tables
-- Ever reserved rooms with service #3
SELECT r.*
FROM Room r
JOIN RoomService rs ON r.RoomNumber = rs.Room
JOIN Service s ON rs.Service = s.ServiceID
WHERE s.ServiceID = 3
AND r.RoomNumber IN (
  SELECT DISTINCT RoomNumber
  FROM Reservation
);

-- Rezervace a vydelek za posledni rok podle typu platby
-- Agg. func + group by
-- Reservations last year
SELECT Payment, COUNT(*) AS NumberOfReservations, SUM(res.Price) AS TotalRevenue
FROM Reservation res
WHERE res.DateFrom >= TRUNC(SYSDATE, 'YEAR')
GROUP BY Payment;

-- Prumerna cena pokoju pro kazde patro
-- Agg. func + group by
-- Avg price each floor
SELECT Floor, AVG(Price) AS AvgPrice
FROM Room
GROUP BY Floor;

-- Vsechny pokoje, ktere byly nekdy rezervovany
-- EXISTS predicate
-- Rooms ever reserved
SELECT * FROM Room r
WHERE EXISTS (
  SELECT * FROM Reservation res
  WHERE res.RoomNumber = r.RoomNumber
)
ORDER BY RoomNumber;

-- Pokoje typu regular, ktere maji typ postele double
-- IN predicate
-- Regular rooms with double beds
SELECT *
FROM Room
WHERE Room.RoomNumber IN (
  SELECT RoomInfo
  FROM Regular
  WHERE Bed = 'Double'
);

----------------------------- INDEX DEMONSTRATION -------------------------------------

-- Pocet rezervaci vytvorenych zamestnanci zenskeho pohlavi
-- Count of reservations made by women v1
EXPLAIN PLAN FOR
    SELECT
        E.Name,
        COUNT(R.ReservationID) AS pocet_rezervaci
    FROM Employee E
    JOIN Reservation R ON E.PersonID = R.madeBy
    WHERE E.Sex = 'Female'
    GROUP BY E.Name
    ORDER BY E.Name;

-- PLAN w/o index
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY());

CREATE INDEX sex_idx
ON Employee (Sex);
CREATE INDEX name_idx
ON Employee (Name);

-- Pocet rezervaci vytvorenych zamestnanci zenskeho pohlavi
-- Count of reservations made by women v2
EXPLAIN PLAN FOR
    SELECT
        E.Name,
        COUNT(R.ReservationID) AS pocet_rezervaci
    FROM Employee E
    JOIN Reservation R ON E.PersonID = R.madeBy
    WHERE E.Sex = 'Female'
    GROUP BY E.Name
    ORDER BY E.Name;

-- PLAN w/ index
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY());

DROP INDEX sex_idx;
DROP INDEX name_idx;

----------------------------------- RIGHTS -------------------------------------------

GRANT ALL ON Person TO XTOMKO06;
GRANT ALL ON Employee TO XTOMKO06;
GRANT ALL ON Room TO XTOMKO06;
GRANT ALL ON Reservation TO XTOMKO06;
GRANT ALL ON Apartment TO XTOMKO06;
GRANT ALL ON Regular TO XTOMKO06;
GRANT ALL ON Service TO XTOMKO06;
GRANT ALL ON RoomService TO XTOMKO06;
GRANT ALL ON ReservationPerson TO XTOMKO06;
GRANT ALL ON ReservationService TO XTOMKO06;

GRANT ALL ON update_service_price TO XTOMKO06;
GRANT ALL ON display_reservations_for_room TO XTOMKO06;

------------------------------- MATERIALIZED VIEW ------------------------------------

-- XTOMKO06 script
-- Materialized view of all available rooms in a hotel
DROP MATERIALIZED VIEW available_rooms;
CREATE MATERIALIZED VIEW available_rooms
BUILD IMMEDIATE
REFRESH COMPLETE ON COMMIT
AS SELECT RoomNumber, Floor, Price, Description
FROM XNESPO10.Room
WHERE IsAvailable = 'Y';

-- XTOMKO06 by dal prava XNESPO10
GRANT ALL ON available_rooms TO XTOMKO06;

-- Materialized view
SELECT * FROM available_rooms;
-- XTOMKO06.available_rooms

-- Set Room 1 as available
UPDATE XNESPO10.Room SET IsAvailable = 'Y'
WHERE RoomNumber = 1;
COMMIT;

-- Updated materialized view
SELECT * FROM available_rooms;
-- XTOMKO06.available_rooms
