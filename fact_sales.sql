-- Create sales table
CREATE TABLE sales
(
	month 			TEXT 		NOT NULL,
	week			TEXT		NOT NULL,
	customercode		TEXT		NOT NULL,
	sku			VARCHAR(14)	NOT NULL,
	qty			NUMERIC		NOT NULL,
	cogs			NUMERIC		NOT NULL,
	revenue			NUMERIC		NOT NULL,
	cogsusd			NUMERIC			,
	revenueusd		NUMERIC			,		
	yearweek		TEXT			,
	FOREIGN KEY (yearweek) 		REFERENCES calendar(yearweek),
	FOREIGN KEY (customercode) 	REFERENCES distributionchannel(customercode),
	FOREIGN KEY (sku) 		REFERENCES product(sku)
);

-- Create the trigger function to populate cogsusd, revenueusd, fk_date
CREATE OR REPLACE FUNCTION clean_sales() RETURNS TRIGGER AS $$
BEGIN
	-- update cogs_usd and revenueusd
	NEW.cogsusd 	:= NEW.cogs/25000;
    	NEW.revenueusd 	:= NEW.revenue/25000;
	-- update yearweek
	NEW.yearweek 	:= SUBSTRING(NEW.week,1,6);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
CREATE TRIGGER clean_sales
BEFORE INSERT OR UPDATE ON sales
FOR EACH ROW
EXECUTE FUNCTION clean_sales();

-- Change data type of usd value column
ALTER TABLE sales
ALTER COLUMN cogsusd TYPE DECIMAL(10, 2);
ALTER TABLE sales
ALTER COLUMN revenueusd TYPE DECIMAL(10, 2);

-- Copy data to sales table
COPY sales (month, week, customercode, sku, qty, cogs, revenue)
FROM 'D:\personal_project\retail_dashboard\sales.csv'
DELIMITER ','
CSV HEADER;

-- Recheck sales table data
select * from sales limit 10;
