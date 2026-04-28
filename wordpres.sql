#this is the SQL script file

#it's contien data base it's tell the mariadb how to creat and fil a database
#install the database (creat tables create structer prepar wordpress schema )
#import data (restor backups migratw wibsites )
#this is the sql code 

-- ##CREATE DATABASE [IF NOT EXISTS] database_name;
-- ###CREATE DATABASE ==> this is as an abstract unit 
-- #[IF NOT EXISTS] ==> this to check is the data base name is EXISTS already

-- #database_name ==> this this to geet to the data base a name it's not okey if i put like this name_01 or name_some_thing_else it's we can use "" or not and upercase or lawercase it's all pass
CREATE DATABASE IF NOT EXISTS wordpress;
-- #than we crreat the cshema of this database 
CREATE SCHEMA IF NOT EXISTS wordpress;

-- know creat user
CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'mypassword';
--assign the permission or the 
--give in the privileges to a user is calls ¨granting¨ and remove privileges is call "revoking"
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';
--ALL PRIVILEGES mean INSERT, UPDATE, DELETE
