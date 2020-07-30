-- Empty Table
TRUNCATE TABLE `test`.`company`;

-- Load Data (replace existing data)
LOAD DATA LOW_PRIORITY LOCAL INFILE '/home/max/share/csv-import/foo.csv' REPLACE INTO TABLE `test`.`company` CHARACTER SET utf8 FIELDS TERMINATED BY ';' OPTIONALLY ENCLOSED BY '"' ESCAPED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES (`ID`, `Name`, `FirstName`, `Job`);