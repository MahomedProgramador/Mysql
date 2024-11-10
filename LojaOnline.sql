DROP DATABASE IF EXISTS BuyDB;
CREATE DATABASE BuyDB;

USE BuyDB;
-- CLIENT
DROP TABLE IF EXISTS `Client`;
CREATE TABLE `Client`(
	id INTEGER PRIMARY KEY AUTO_INCREMENT, 
    firstname VARCHAR(250) NOT NULL,
    surname VARCHAR(250) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE, 
    `password` BINARY(32) NOT NULL,
    address VARCHAR(100) NOT NULL,
    zip_code TINYINT NOT NULL,
    city VARCHAR(30) NOT NULL,
    country VARCHAR(30) DEFAULT 'Portugal',
    phone_number VARCHAR(15), 
    birthdate DATE NOT NULL,
    last_login DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT client_emailCHK CHECK (email REGEXP 
    "^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$"),   
    CONSTRAINT client_phonenumberCHK CHECK (LENGTH(phone_number) >= 6)
  );

USE BuyDB;
-- ORDER
DROP TABLE IF EXISTS `Order`;
CREATE TABLE `Order`(
    id INTEGER PRIMARY KEY AUTO_INCREMENT, 
    client_id INTEGER NOT NULL, 
    date_time DATETIME NOT NULL DEFAULT (CURDATE()),
    delivery_method VARCHAR(10) DEFAULT 'regular',
    `status` VARCHAR(10) DEFAULT 'open', 
    payment_card_number LONG NOT NULL,
    payment_card_name VARCHAR(20) NOT NULL,
    payment_card_expiration DATE NOT NULL, 
    CONSTRAINT delivery_methodCHK CHECK (delivery_method IN ('regular', 'urgente')),   
    CONSTRAINT statusCHK CHECK (`status` IN ('open', 'processing', 'pending', 'closed', 'cancelled')),
    CONSTRAINT fk_cliente_id FOREIGN KEY (client_id) REFERENCES `Client`(id) ON DELETE CASCADE ON UPDATE CASCADE -- Se apagar o clt nao tenho interesse em ter as ordens
  );
   
USE BuyDB;
  -- PRODUCT   
DROP TABLE IF EXISTS Product;
CREATE TABLE Product(
	id VARCHAR(10) PRIMARY KEY,
    quantity INTEGER NOT NULL, 
    price DECIMAL(12,2) NOT NULL,
    vat FLOAT NOT NULL COMMENT 'Vat percentage',
    active BOOLEAN NOT NULL DEFAULT TRUE,
    score TINYINT,
    product_image VARCHAR(500),
    reason VARCHAR(500), 
    CONSTRAINT quantityCHK CHECK (quantity >= 0),
    CONSTRAINT priceCHK CHECK (price >= 0),
    CONSTRAINT vatCHK CHECK (vat BETWEEN 0 AND 100),      
    CONSTRAINT scoreCHK CHECK (score BETWEEN 1 AND 5)  
);

-- BOOK
USE BuyDB;
DROP TABLE IF EXISTS Book;
CREATE TABLE Book(
	product_id VARCHAR(10) PRIMARY KEY,  
    isbn13 VARCHAR(20), 
    title VARCHAR(50) NOT NULL,
    genre VARCHAR(50) NOT NULL,
    publisher VARCHAR(100) NOT NULL, 
    publication_date DATE NOT NULL,
    CONSTRAINT fk_Product_Book FOREIGN KEY (product_id) REFERENCES Product(id) ON DELETE CASCADE ON UPDATE CASCADE
  );

  -- ELECTRONIC   
USE BuyDB;
DROP TABLE IF EXISTS Electronic;
CREATE TABLE Electronic(
	product_id VARCHAR(10) PRIMARY KEY,      
    serial_number BIGINT NOT NULL UNIQUE,
    brand VARCHAR(20) NOT NULL,
    model VARCHAR(20) NOT NULL,
    type VARCHAR(10) NOT NULL,
    spec_tec LONGTEXT NOT NULL,
    CONSTRAINT fk_product_electronic FOREIGN KEY (product_id) REFERENCES Product(id) ON DELETE CASCADE ON UPDATE CASCADE     
);

-- AUTHOR
USE BuyDB;
DROP TABLE IF EXISTS Author;
CREATE TABLE Author(
	id INTEGER PRIMARY KEY AUTO_INCREMENT, 
    name VARCHAR(100) COMMENT "Author's literary/pseudo name, for which he is known", 
    fullname VARCHAR(100) COMMENT "Autor's real full name",
    birthdate DATE 
);

-- BOOKAUTHOR
USE BuyDB;
DROP TABLE IF EXISTS BookAuthor;
CREATE TABLE BookAuthor(
	  id INTEGER PRIMARY KEY AUTO_INCREMENT, 
    product_id VARCHAR(10),
    author_id INTEGER NOT NULL,
    CONSTRAINT fk_Product_BookAuthor FOREIGN KEY (product_id) REFERENCES Product(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_Author FOREIGN KEY (author_id) REFERENCES Author(id) ON DELETE CASCADE,
    CONSTRAINT unique_book_author UNIQUE (product_id, author_id)
);

-- RECOMENDATION
USE BuyDB;
DROP TABLE IF EXISTS Recomendation;
CREATE TABLE Recomendation(
	id INTEGER PRIMARY KEY AUTO_INCREMENT, 
    product_id VARCHAR(10) NOT NULL,
    client_id INTEGER NOT NULL,
    reason VARCHAR(500), 
    start_date DATE,
    CONSTRAINT fk_product_recomendation FOREIGN KEY (product_id) REFERENCES Product(id),
    CONSTRAINT fk_client_Recomendation FOREIGN KEY (client_id) REFERENCES Client(id) 
);

-- ORDEREDITEM
USE BuyDB;
DROP TABLE IF EXISTS OrderedItem;
CREATE TABLE OrderedItem(
	id INTEGER PRIMARY KEY AUTO_INCREMENT, 
    order_id INTEGER NOT NULL,
    product_id VARCHAR(10) NOT NULL,    
    quantity INTEGER NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    vat_amount DECIMAL(12,2) NOT NULL,
    CONSTRAINT order_quantityCHK CHECK (quantity >= 0),
    CONSTRAINT order_priceCHK CHECK (price >= 0),
    CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES `Order`(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_product_orderedItem FOREIGN KEY (product_id) REFERENCES Product(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT order_vat_amountCHK CHECK (vat_amount >= 0)
);

-- OPERATOR
USE BuyDB;
DROP TABLE IF EXISTS Operator;
CREATE TABLE Operator(
	id INTEGER PRIMARY KEY AUTO_INCREMENT, 
    firstname VARCHAR(250) NOT NULL,
    surname VARCHAR(250) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE, 
    `password` BINARY(32) NOT NULL,
    CONSTRAINT operator_emailCHK CHECK (email REGEXP 
    "^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$")
);

/*
****************************************************
    TRIGGERS
****************************************************
*/

-- ClientPassValidation
USE BuyDB;
DROP TRIGGER IF EXISTS ClientPassValidation;
DELIMITER //
CREATE TRIGGER ClientPassValidation BEFORE INSERT ON `Client`
FOR EACH ROW
BEGIN
  DECLARE PASS_INVALIDA CONDITION FOR SQLSTATE '45000';
  IF (NEW.`password` NOT REGEXP '^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!$#?%]).{6,50}$') THEN
    SIGNAL PASS_INVALIDA
    SET MESSAGE_TEXT = 'Palavra passe incorrecta';
  END IF;  
  SET NEW.`password` = UNHEX(SHA2(NEW.`password`, 256));
END//   

DELIMITER ;

-- ReasonInactivatingProduct
USE BuyDB;
DELIMITER //
CREATE TRIGGER ReasonInactivatingProduct
BEFORE UPDATE ON Product
FOR EACH ROW
BEGIN
    IF NEW.active = FALSE AND (NEW.reason IS NULL OR NEW.reason = '') THEN
        SIGNAL SQLSTATE '45001'
        SET MESSAGE_TEXT = 'The reason field must be filled when the product is inactive.';
    END IF;
END;
//

DELIMITER ;
-- ValidateISBN13
USE BuyDB;
DROP TRIGGER IF EXISTS ValidateISBN13;
DELIMITER //
CREATE TRIGGER ValidateISBN13 BEFORE INSERT ON Book
FOR EACH ROW 
BEGIN
    DECLARE DADOS_INVALIDOS CONDITION FOR SQLSTATE '45003';
        
    IF NOT ISBN13Valid(NEW.isbn13) THEN
        SIGNAL DADOS_INVALIDOS SET MESSAGE_TEXT = 'Invalid ISBN13';
    END IF;
END//

DELIMITER ;
-- OperatorPassValidation
USE BuyDB;
DROP TRIGGER IF EXISTS OperatorPassValidation;
DELIMITER //
CREATE TRIGGER OperatorPassValidation BEFORE INSERT ON Operator
FOR EACH ROW
BEGIN
  DECLARE PASS_INVALIDA CONDITION FOR SQLSTATE '45002';
  IF (NEW.`password` NOT REGEXP '^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!$#?%]).{6,50}$') THEN
    SIGNAL PASS_INVALIDA
    SET MESSAGE_TEXT = 'Palavra passe incorrecta';
  END IF;  
  SET NEW.`password` = UNHEX(SHA2(NEW.`password`, 256));
END//


DELIMITER ;
/*
****************************************************    
    Functions
****************************************************
*/

-- ISBN13Valid
USE BuyDB;
DROP FUNCTION IF EXISTS ISBN13Valid;
DELIMITER //
CREATE FUNCTION ISBN13Valid(ISBN VARCHAR(20))
RETURNS BOOL
DETERMINISTIC
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE Soma INT DEFAULT 0;
    DECLARE Control INT DEFAULT 0;
    DECLARE CleanedISBN CHAR(13);
  
    SET CleanedISBN = REPLACE(ISBN, '-', '');

    IF CleanedISBN NOT RLIKE '^[0-9]{13}$' THEN
        RETURN FALSE;
    END IF;

    WHILE i <= 12 DO
        IF MOD(i, 2) = 1 THEN
            SET Soma = Soma + CAST(SUBSTRING(CleanedISBN, i, 1) AS UNSIGNED);
        ELSE
            SET Soma = Soma + CAST(SUBSTRING(CleanedISBN, i, 1) AS UNSIGNED) * 3;
        END IF;
        SET i = i + 1;
    END WHILE;
    	
    SET Control = (10 - (Soma % 10)) % 10;

    IF Control = CAST(SUBSTRING(CleanedISBN, 13, 1) AS UNSIGNED) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END//

DELIMITER ;

/*
***************************************************
    Procedures
***************************************************
*/

-- ProductbyType
USE BuyDB;
DROP PROCEDURE IF EXISTS ProductbyType;
DELIMITER //
CREATE PROCEDURE ProductbyType(IN product_type VARCHAR(255))
BEGIN
    IF product_type IS NULL THEN
        SELECT 
            p.id, 
            p.price,
            p.score,
            r.reason,
            p.active,
            p.product_image,
            e.type
        FROM Product AS p
        JOIN Recomendation AS r ON
        p.id = r.product_id
        JOIN Electronic AS e ON
        p.id = e.product_id;        
    ELSE
        SELECT 
            p.id, 
            p.price, 
            p.score, 
            r.reason, 
            p.active, 
            p.product_image,
            e.type
        FROM Product AS p
        JOIN Recomendation AS r 
        ON p.id = r.product_id
        JOIN Electronic AS e
        ON p.id = e.product_id
        WHERE e.type = product_type;
    END IF;
END//


DELIMITER ;
-- DailyOrders
USE BuyDB;
DROP PROCEDURE IF EXISTS DailyOrders;
DELIMITER //
 CREATE PROCEDURE DailyOrders(IN requested_date DATE)
BEGIN
        SELECT  o.date_time,
            o.delivery_method,
            o.status,
            CONCAT(c.firstname, " ", c.surname) as full_name,
            oi.quantity,
            oi.price,
            p.price,     
            e.brand,
            e.model,
            b.title,
            b.genre       
         FROM `Order` AS o
         JOIN OrderedItem AS oi
         ON o.id = oi.order_id
         JOIN Client AS c 
         ON c.id = o.client_id
         JOIN Product as p 
         ON p.id = oi.product_id
         LEFT JOIN Electronic AS e
         ON p.id = e.product_id
         LEFT JOIN Book AS b
         ON p.id = b.product_id
    WHERE DATE(o.date_time) = requested_date ;

END //

DELIMITER ;

-- ClientOrdersByYear
USE BuyDB;
DROP PROCEDURE IF EXISTS ClientOrdersByYear;
DELIMITER //
CREATE PROCEDURE ClientOrdersByYear(IN clt_id INT, IN `year` VARCHAR(4))
BEGIN
        SELECT o.date_time,
        o.delivery_method,
        o.status,
        CONCAT(c.firstname, " ", c.surname) as full_name,
        oi.quantity,
        oi.price,
        b.title,
        b.genre,
        e.brand,
        e.model     
    FROM `Order` as o
    JOIN OrderedItem oi
    ON o.id = oi.order_id
    JOIN Client c
    ON c.id = o.client_id
    LEFT JOIN Electronic AS e
    ON oi.product_id = e.product_id
    LEFT JOIN Book AS b
    ON oi.product_id = b.product_id    
    WHERE client_id = clt_id AND YEAR(date_time) = `year`;
END //

DELIMITER ;

-- Create Order
USE BuyDB;
DROP PROCEDURE IF EXISTS CreateOrder;
DELIMITER //
CREATE PROCEDURE CreateOrder(IN ctl_id INT,IN dlvry_method VARCHAR(10),IN credit_card_number LONG,
    IN credit_card_name VARCHAR(20), IN credit_card_expiration DATE, OUT id_order INT)
BEGIN       
   INSERT INTO `Order` (client_id, date_time, delivery_method, status, payment_card_number,
   payment_card_name, payment_card_expiration)
   VALUES
   (ctl_id, NOW(), dlvry_method, DEFAULT, credit_card_number, credit_card_name, credit_card_expiration); 
   SET id_order = LAST_INSERT_ID();
    
END//
DELIMITER ;


-- OrderCalculation
USE BuyDB;
DROP PROCEDURE IF EXISTS TotalOrderCalculation;
DELIMITER //
CREATE PROCEDURE TotalOrderCalculation(
    IN OrderId INT)
BEGIN
DECLARE total DECIMAL(12, 2);
    -- Calcula o total da encomenda
    SELECT SUM(oi.quantity * oi.price * (1 + p.vat / 100)) INTO total 
    FROM OrderedItem AS oi
    JOIN Product AS p ON oi.product_id = p.id
    WHERE oi.order_id = OrderId;

      SELECT total AS sum_of_total_orders;
END//
DELIMITER ;

-- AddProductToOrder
USE BuyDB;
DROP PROCEDURE IF EXISTS AddProductToOrder;
DELIMITER //
CREATE PROCEDURE AddProductToOrder(IN id_order INT, IN prdt_id VARCHAR(10), IN qt INT)
BEGIN    
    DECLARE product_price DECIMAL(12,2);
    DECLARE product_vat FLOAT;

    SELECT price, vat INTO product_price, product_vat
    FROM Product
    WHERE id = prdt_id; 

    INSERT INTO OrderedItem (order_id,product_id, quantity, price, vat_amount)
    VALUES
    (id_order, prdt_id, qt, product_price, (product_price * product_vat / 100));
    
END//
DELIMITER ;

-- CreateBook
USE BuyDB;
DROP PROCEDURE IF EXISTS CreateBook;
DELIMITER //
CREATE PROCEDURE CreateBook(IN prdt_id VARCHAR(10), IN qt INT, IN prc DECIMAL(12,2), IN vat_percentage FLOAT, IN act BOOLEAN,
                            IN scr TINYINT, IN image VARCHAR(500), IN rsn VARCHAR(500),
                            IN isbn VARCHAR(20), IN ttl VARCHAR(50), IN gnr VARCHAR(50),
                            IN pblshr VARCHAR(100), IN pblctn_dt DATE)
BEGIN
   
    INSERT INTO Product (id, quantity, price, vat, active, score, product_image, reason)
    VALUES
        (prdt_id ,qt, prc, vat_percentage, act, scr, image, rsn);
    
    INSERT INTO Book(product_id, isbn13, title, genre, publisher, publication_date)
    VALUES
        (prdt_id, isbn, ttl, gnr, pblshr, pblctn_dt);

END //
DELIMITER ;

-- CreateElectronic

USE BuyDB;
DROP PROCEDURE IF EXISTS CreateElectronic;
DELIMITER //
CREATE PROCEDURE CreateElectronic
                            (IN prdt_id VARCHAR(10), IN qt INT, IN prc DECIMAL(12,2), IN vat_percentage FLOAT, IN act BOOLEAN,
                            IN scr TINYINT, IN image VARCHAR(500), IN rsn VARCHAR(500),
                            IN srl_nmbr BIGINT, IN brnd VARCHAR(50), IN mdl VARCHAR(20),
                            IN tp VARCHAR(20), IN spc_tc LONGTEXT)
BEGIN
   
    INSERT INTO Product (id, quantity, price, vat, active, score, product_image, reason)
    VALUES
        (prdt_id ,qt, prc, vat_percentage, act, scr, image, rsn);
    
    INSERT INTO Electronic(product_id, serial_number, brand, model, type, spec_tec)
    VALUES
        (prdt_id, srl_nmbr, brnd, mdl, tp, spc_tc);
END //

DELIMITER ;