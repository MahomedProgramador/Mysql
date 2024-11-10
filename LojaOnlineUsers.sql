/*
***************************************************
    Users
***************************************************
*/
-- client
USE BuyDB;
DROP USER IF EXISTS 'clt'@'%';
DROP USER IF EXISTS 'clt'@'localhost';
CREATE USER 'clt'@'%' IDENTIFIED BY 'client';
CREATE USER 'clt'@'localhost' IDENTIFIED BY 'client';

GRANT SELECT, INSERT, UPDATE ON BuyDB.Author TO 'clt'@'%';
GRANT SELECT, INSERT, UPDATE ON BuyDB.Author TO 'clt'@'localhost';
GRANT SELECT, INSERT, UPDATE ON BuyDB.Book TO 'clt'@'%';
GRANT SELECT, INSERT, UPDATE ON BuyDB.Book TO 'clt'@'localhost';
GRANT SELECT, INSERT, UPDATE ON BuyDB.BookAuthor TO 'clt'@'%';
GRANT SELECT, INSERT, UPDATE ON BuyDB.BookAuthor TO 'clt'@'localhost';
GRANT SELECT, INSERT, UPDATE ON BuyDB.Client TO 'clt'@'%';
GRANT SELECT, INSERT, UPDATE ON BuyDB.Client TO 'clt'@'localhost';
GRANT SELECT, INSERT, UPDATE ON BuyDB.Electronic TO 'clt'@'%';
GRANT SELECT, INSERT, UPDATE ON BuyDB.Electronic TO 'clt'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON BuyDB.Order TO 'clt'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON BuyDB.Order TO 'clt'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON BuyDB.OrderedItem TO 'clt'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON BuyDB.OrderedItem TO 'clt'@'localhost';
GRANT SELECT, INSERT, UPDATE ON BuyDB.Product TO 'clt'@'%';
GRANT SELECT, INSERT, UPDATE ON BuyDB.Product TO 'clt'@'localhost';
GRANT SELECT, INSERT, UPDATE ON BuyDB.Recomendation TO 'clt'@'%';
GRANT SELECT, INSERT, UPDATE ON BuyDB.Recomendation TO 'clt'@'localhost';

/*
-- Exportar o código para o ficheiro e correr no servidor.

SELECT CONCAT(
"GRANT SELECT, INSERT, UPDATE ON BuyDB.", table_name, " TO 'clt'@'%';",
"GRANT SELECT, INSERT, UPDATE ON BuyDB.", table_name, " TO 'clt'@'localhost';"
)
FROM information_schema.tables
WHERE table_schema = "BuyDB" AND
table_name <> "Operator";

GRANT DELETE ON BuyDB.Order TO 'clt'@'%';
GRANT DELETE ON BuyDB.Order TO 'clt'@'localhost';

GRANT DELETE ON BuyDB.OrderedItem TO 'clt'@'%';
GRANT DELETE ON BuyDB.OrderItem TO 'clt'@'localhost';

*/

USE BuyDB;
GRANT EXECUTE ON PROCEDURE BuyDB.CreateOrder TO 'clt'@'%',
'clt'@'localhost';

USE BuyDB;
GRANT EXECUTE ON
PROCEDURE BuyDB.TotalOrderCalculation 
TO 'clt'@'%',
'clt'@'localhost';

USE BuyDB;
GRANT EXECUTE ON
PROCEDURE BuyDB.AddProductToOrder 
TO 'clt'@'%',
'clt'@'localhost';

-- operator 
USE BuyDB;
DROP USER IF EXISTS 'operator'@'%';
DROP USER IF EXISTS 'operator'@'localhost';
CREATE USER 'operator'@'%' IDENTIFIED BY 'operator';
CREATE USER 'operator'@'localhost' IDENTIFIED BY 'operator';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON BuyDB.* TO 'operator'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON BuyDB.* TO 'operator'@'localhost';


-- admin BuyDB
USE BuyDB;
DROP USER IF EXISTS 'admin_buydb'@'%';
DROP USER IF EXISTS 'admin_buydb'@'localhost';
CREATE USER 'admin_buydb'@'%' IDENTIFIED BY 'admin_buydb';
CREATE USER 'admin_buydb'@'localhost' IDENTIFIED BY 'admin_buydb';

GRANT ALL PRIVILEGES ON BuyDB.* TO 'admin_buydb'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON BuyDB.* TO 'admin_buydb'@'localhost' WITH GRANT OPTION;