CREATE DATABASE inventory_database;
USE inventory_database;

CREATE TABLE items (
	itemId VARCHAR (4) PRIMARY KEY,
    itemName VARCHAR (100) NOT NULL,
    category VARCHAR (100) NOT NULL,
    quantity INT NOT NULL,
    unit VARCHAR (15) NOT NULL,
    description VARCHAR (100),
    status VARCHAR (15),
	expirationDate DateTime NOT NULL
);

CREATE TABLE itemAlert (
	alertId VARCHAR (10) PRIMARY KEY,
    itemId VARCHAR (40), FOREIGN KEY (itemId) REFERENCES items(itemId) ON DELETE CASCADE,
    type VARCHAR (100),
    generatedAt DateTime
);

SELECT * FROM items;
SELECT * FROM itemAlert;
