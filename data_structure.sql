
--
-- Table structure for table `actor`
--

CREATE TABLE actor (
  actor_id SERIAL NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  last_update TIMESTAMP NOT NULL,
  PRIMARY KEY  (actor_id)
) ;
 -- 'last_modified' update of timestamp
CREATE OR REPLACE FUNCTION update_modified_column() 
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_update = now();
    RETURN NEW; 
END;
$$ language 'plpgsql';

-- trigger for 'actor.last_update'
CREATE TRIGGER update_actor_modtime BEFORE UPDATE ON
actor FOR EACH ROW EXECUTE PROCEDURE  update_modified_column();

--
-- Table structure for table `language`
--

CREATE TABLE language (
  language_id SERIAL NOT NULL,
  name CHAR(20) NOT NULL,
  last_update TIMESTAMP NOT NULL,
  PRIMARY KEY (language_id)
) ;
CREATE TRIGGER update_actor_modtime BEFORE UPDATE ON
public.language FOR EACH ROW EXECUTE PROCEDURE  update_modified_column();

--
-- Table structure for table `film`
--

create type enum1 AS ENUM('G','PG','PG-13','R','NC-17');
CREATE TABLE film (
  film_id SERIAL NOT NULL check (film_id>0),
  title VARCHAR(128) NOT NULL,
  description TEXT DEFAULT NULL,
  release_year INT DEFAULT NULL,
  language_id SMALLINT NOT NULL,
  original_language_id SMALLINT  DEFAULT NULL,
  rental_duration SMALLINT  NOT NULL DEFAULT 3,
  rental_rate DECIMAL(4,2) NOT NULL DEFAULT 4.99,
  length SMALLINT DEFAULT NULL,
  replacement_cost DECIMAL(5,2) NOT NULL DEFAULT 19.99,
  rating enum1 DEFAULT 'G',
  special_features VARCHAR  DEFAULT NULL,
  last_update TIMESTAMP NOT NULL, 
  PRIMARY KEY  (film_id),
  FOREIGN KEY (language_id) REFERENCES language (language_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ;
CREATE TRIGGER update_actor_modtime BEFORE UPDATE ON
film FOR EACH ROW EXECUTE PROCEDURE  update_modified_column();

--
-- Table structure for table `category`
--

CREATE TABLE category (
  category_id SERIAL NOT NULL ,
  name VARCHAR(25) NOT NULL,
  last_update TIMESTAMP NOT NULL ,
  PRIMARY KEY  (category_id)
) ;
CREATE TRIGGER update_actor_modtime BEFORE UPDATE ON
category FOR EACH ROW EXECUTE PROCEDURE  update_modified_column();

--
-- Table structure for table `film_category`
--

CREATE TABLE film_category (
  film_id SMALLINT  NOT NULL,
  category_id SMALLINT  NOT NULL,
  last_update TIMESTAMP NOT NULL, 
  PRIMARY KEY (film_id, category_id),
  FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (category_id) REFERENCES category (category_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ;
CREATE TRIGGER update_actor_modtime BEFORE UPDATE ON
film_category FOR EACH ROW EXECUTE PROCEDURE  update_modified_column();

--
-- Table structure for table `film_actor`
--

CREATE TABLE film_actor (
  actor_id SMALLINT NOT NULL, 
  film_id SMALLINT  NOT NULL,
  last_update TIMESTAMP NOT NULL,
  PRIMARY KEY  (actor_id,film_id),
  FOREIGN KEY (actor_id) REFERENCES actor (actor_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ;
CREATE TRIGGER update_actor_modtime BEFORE UPDATE ON
film_actor FOR EACH ROW EXECUTE PROCEDURE  update_modified_column();

--
-- Table structure for table `country`
--

CREATE TABLE country (
  country_id SERIAL NOT NULL ,
  country VARCHAR(50) NOT NULL,
  last_update TIMESTAMP NOT NULL,
  PRIMARY KEY  (country_id)
) ;
CREATE TRIGGER update_actor_modtime BEFORE UPDATE ON
country FOR EACH ROW EXECUTE PROCEDURE  update_modified_column();

--
-- Table structure for table `city`
--

CREATE TABLE city (
  city_id SERIAL NOT NULL ,
  city VARCHAR(50) NOT NULL,
  country_id SMALLINT  NOT NULL,
  last_update TIMESTAMP NOT NULL, 
  PRIMARY KEY  (city_id),
  FOREIGN KEY (country_id) REFERENCES country (country_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ;
CREATE TRIGGER update_actor_modtime BEFORE UPDATE ON
city FOR EACH ROW EXECUTE PROCEDURE  update_modified_column();

--
-- Table structure for table `address`
--

CREATE TABLE address (
  address_id SERIAL NOT NULL,
  address VARCHAR(50) NOT NULL,
  address2 VARCHAR(50) DEFAULT NULL,
  district VARCHAR(20) NOT NULL,
  city_id SMALLINT  NOT NULL,
  postal_code VARCHAR(10) DEFAULT NULL,
  phone VARCHAR(20) NOT NULL,
  last_update TIMESTAMP NOT NULL, 
  PRIMARY KEY  (address_id),
  FOREIGN KEY (city_id) REFERENCES city (city_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TRIGGER update_actor_modtime BEFORE UPDATE ON
address FOR EACH ROW EXECUTE PROCEDURE  update_modified_column();

--
-- Table structure for table `store`
--

CREATE TABLE store (
  store_id SERIAL NOT NULL, 
  manager_staff_id INT NOT NULL,
  address_id SMALLINT  NOT NULL,
  last_update TIMESTAMP NOT NULL, 
  PRIMARY KEY  (store_id),
  FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ;
CREATE TRIGGER update_actor_modtime BEFORE UPDATE ON
store FOR EACH ROW EXECUTE PROCEDURE  update_modified_column();

--
-- Table structure for table `staff` 
--

CREATE TABLE staff (
  staff_id SERIAL NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  address_id SMALLINT  NOT NULL,
  picture VARCHAR DEFAULT NULL,
  email VARCHAR(50) DEFAULT NULL,
  store_id INT NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  username VARCHAR(16) NOT NULL,
  password VARCHAR(40) DEFAULT NULL,
  last_update TIMESTAMP NOT NULL,
  PRIMARY KEY  (staff_id),
  FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (store_id) REFERENCES store (store_id) ON DELETE RESTRICT ON UPDATE CASCADE

);
	
 CREATE TRIGGER update_actor_modtime BEFORE UPDATE ON
staff FOR EACH ROW EXECUTE PROCEDURE  update_modified_column();

--
-- Table structure for table `customer`
--

CREATE TABLE customer (
  customer_id SERIAL NOT NULL,
  store_id SMALLINT NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  email VARCHAR(50) DEFAULT NULL,
  address_id SMALLINT NOT NULL,
  active SMALLINT  NOT NULL DEFAULT 1,
  create_date TIMESTAMP NOT NULL,
  last_update TIMESTAMP, 
  PRIMARY KEY  (customer_id),
  FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (store_id) REFERENCES store (store_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ;
CREATE TRIGGER update_actor_modtime BEFORE UPDATE ON
customer FOR EACH ROW EXECUTE PROCEDURE  update_modified_column();

--
-- Table structure for table `inventory`
--

CREATE TABLE inventory (
  inventory_id SERIAL NOT NULL,
  film_id SMALLINT NOT NULL,
  store_id SMALLINT  NOT NULL,
  last_update TIMESTAMP NOT NULL, 
  PRIMARY KEY  (inventory_id),
  FOREIGN KEY (store_id) REFERENCES store (store_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TRIGGER update_actor_modtime BEFORE UPDATE ON
inventory FOR EACH ROW EXECUTE PROCEDURE  update_modified_column();

--
-- Table structure for table `rental`
--

CREATE TABLE rental (
  rental_id SERIAL NOT null,
  rental_date TIMESTAMP NOT NULL,
  inventory_id INT NOT NULL,
  customer_id SMALLINT  NOT NULL,
  return_date TIMESTAMP DEFAULT NULL,
  staff_id SMALLINT  NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
  PRIMARY KEY (rental_id),
  FOREIGN KEY (staff_id) REFERENCES staff (staff_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (inventory_id) REFERENCES inventory (inventory_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ;
CREATE TRIGGER update_actor_modtime BEFORE UPDATE ON
rental FOR EACH ROW EXECUTE PROCEDURE  update_modified_column();

--
-- Table structure for table `payment`
--

CREATE TABLE payment (
  payment_id SERIAL NOT NULL,
  customer_id SMALLINT NOT NULL,
  staff_id SMALLINT NOT NULL,
  rental_id INT DEFAULT NULL,
  amount DECIMAL(5,2) NOT NULL,
  payment_date TIMESTAMP NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
  PRIMARY KEY  (payment_id),
  FOREIGN KEY (rental_id) REFERENCES rental (rental_id) ON DELETE SET NULL ON UPDATE CASCADE,
  FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (staff_id) REFERENCES staff (staff_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ;
CREATE TRIGGER update_actor_modtime BEFORE UPDATE ON
payment FOR EACH ROW EXECUTE PROCEDURE  update_modified_column();



