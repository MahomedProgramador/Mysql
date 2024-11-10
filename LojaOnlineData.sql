
/*
 ***************************************************
   Inserção nas tabelas
 ***************************************************
*/

-- Client
USE BuyDB;
INSERT INTO `Client` (firstname, surname, email, `password`, address, zip_code, city, country, phone_number, birthdate)
VALUES
('Cristiano', 'Ronaldo', 'cristiano@ronaldo.com', 'Password1!', 'Rua A, 123', 1, 'Lisboa', 'Portugal', '912345678', '1980-05-15'),
('Leonel', 'Messi', 'leonel@messi.com', 'Password2!', 'Av. B, 456', 2, 'Coimbra', 'Portugal', '913456789', '1990-10-20'),
('Zinedine', 'Zidane', 'zinedine@zidane.com', 'Password3!', 'Rua C, 789', 4, 'Porto', 'Portugal', '914567890', '1985-08-25');


-- Order
USE BuyDB;
INSERT INTO `Order` (client_id, date_time, delivery_method, status, payment_card_number,
payment_card_name, payment_card_expiration)
VALUES
(1, '2024-09-27', DEFAULT, DEFAULT, 1234567812345678, 'Cristiano Ronaldo', '2035-07-31'),
(2, DEFAULT, 'urgente', 'processing', 8765432187654321, 'Leonel Messi', '2036-05-15'),
(3, DEFAULT, 'urgente', 'closed', 8765432187485421, 'Zinedine Zidane', '2036-09-15');

-- Product
USE BuyDB;
INSERT INTO Product ( id, quantity, price, vat, active, score, product_image, reason)
VALUES
('1', 100, 29.99, 23.0, TRUE, 4, 'image_url_1', NULL),
('2', 50, 999.99, 23.0, TRUE, 5, 'image_url_2', NULL),
('3', 75, 9.99, 6.0, TRUE, 3, 'image_url_3', NULL),
('4', 25, 29.99, 23.0, TRUE, 4, 'image_url_1', NULL);

-- Book
USE BuyDB;
INSERT INTO Book (product_id, isbn13, title, genre, publisher, publication_date)
VALUES
('1', '978-3-16-148410-0', 'Onde te foste meter?', 'Drama', 'PROG20', '2023-03-01'),
('3', '978-0-306-40615-7', 'Porque precisas de programar?', 'Terror', 'Programming', '2020-11-11'),
('4', '978-1-56619-909-4', 'Continuas a insistir?', 'CS', 'Comedy', '2017-05-01');


-- Electronic
USE BuyDB;
INSERT INTO Electronic (product_id, serial_number, brand, model, type, spec_tec)
VALUES
('2','1234567890', 'Asus', 'XYZ', "laptop", '1 TB disco, 36 GB RAM');

-- Author
USE BuyDB;
INSERT INTO Author (name, fullname, birthdate)
VALUES
('Pavel', 'Nedved', '1975-01-11'),
('Viktor', 'Gyokeres', '1953-06-25');

-- BookAuthor
USE BuyDB;
INSERT INTO BookAuthor (product_id, author_id)
VALUES
('1', 1), 
('3', 2);  

-- Recomendation
USE BuyDB;
INSERT INTO Recomendation (product_id, client_id, reason, start_date)
VALUES
('1', 1, 'Great Depression', '2023-09-20'),
('2', 3, 'A must-have for tech enthusiasts', '2023-09-22'),
('3', 2, 'Perfect for not having a life', '2023-09-21');


-- OrderedItem
USE BuyDB;
INSERT INTO OrderedItem (order_id, product_id, quantity, price, vat_amount)
VALUES
(1, '1', 2, 29.99, 6.90),
(2, '2', 1, 999.99, 45.99),
(3, '2', 1, 999.99, 240);

-- Operator
USE BuyDB;
INSERT INTO Operator (firstname, surname, email, password)
VALUES
('Diego', 'Maradona', 'diego@maradona.com','Password4!'),
('Luca', 'Modric', 'luca@modric.com', 'Password5!');

/*
**********************************************
 Consultas
***********************************************
*/

USE BuyDB;
CALL ProductByType('laptop');

USE BuyDB;
CALL DailyOrders('2024-09-27');

USE BuyDB;
CALL TotalOrderCalculation(1);

USE BuyDB;
CALL ClientOrdersByYear(1,'2024');


USE BuyDB;
CALL AddProductToOrder(1, '3', 1);

USE BuyDB;
CALL CreateOrder(3, 'regular', 1235877812135678, 'Messi', '2030-05-01', @id_order);
CALL AddProductToOrder(@id_order, '1', 2);

USE BuyDB;
CALL CreateBook('6', 10, 29.99, 23, 1, 5,
                 'image.jpg', 'Grande livro para adormecer', '978-3-16-148410-0', 
                 'Estruturas de dados', 'Drama', 'Nerd', '1925-04-10');
  
USE BuyDB;
CALL CreateElectronic('7', 5, 199.99, 23, 1, 3,
                 'electronic7.jpg', 'Mediano', 1234567890123, 'Samsung', 'abc', 'TV', '32" QLED TV');


