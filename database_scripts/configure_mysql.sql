--
-- Create the Festivals API database user and configure rights
--

CREATE USER 'festivals_api_user'@'%' IDENTIFIED BY 'user_password';

GRANT SELECT, INSERT, UPDATE, DELETE ON festivals_api_database.* TO 'festivals_api_user'@'*';
