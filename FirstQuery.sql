
USE Bank ;
CREATE TABLE Accounts
(Account_Id BIGINT IDENTITY(1,1) CONSTRAINT PK_Accounts PRIMARY KEY,
Account_Type VARCHAR(100) NULL,
Account_Number_Of_Cards BIGINT NULL,
Account_Balance MONEY NULL,
 );


CREATE TABLE Banks
(Bank_Id BIGINT IDENTITY(1,1) CONSTRAINT PK_Banks PRIMARY KEY,
 Bank_Name VARCHAR(100) NULL,
 Bank_Registration_Number VARCHAR(100) NULL,
 Bank_Address VARCHAR(100) NULL,
 Bank_City VARCHAR(100) NULL,
 Bank_Contact VARCHAR(100) NULL,
 );



CREATE TABLE Cards
(Card_Id BIGINT IDENTITY(1,1) CONSTRAINT PK_Cards PRIMARY KEY,
Card_Number  VARCHAR(100) NULL,
Card_Balance MONEY NULL,
Account_Id BIGINT NULL,
);
 
 
CREATE TABLE Clients
(Client_Id BIGINT IDENTITY(1,1) CONSTRAINT PK_Clients PRIMARY KEY,
Client_Name VARCHAR(100) NULL,
Client_Adress VARCHAR(100) NULL,
Client_Phone_Number VARCHAR(100) NULL,
Social_Status_Id BIGINT NULL,
Bank_Id BIGINT NULL,
);


CREATE TABLE SocialStatus
(SocialStatus_Id BIGINT IDENTITY(1,1) CONSTRAINT PK_SocialStatus PRIMARY KEY,
 SocialStatus_Number BIGINT NULL,
 SocialStatus_Name VARCHAR(100) NULL,
 );


 
 CREATE TABLE Subsidiaries
(Subsidiary_Id BIGINT IDENTITY(1,1) CONSTRAINT PK_Subsidiaries PRIMARY KEY,
 Subsidiary_Name VARCHAR(100) NULL,
 Subsidiary_City VARCHAR(100) NULL,
 Subsidiary_Address VARCHAR(100) NULL,
 Bank_Id BIGINT NULL,
 );
 
 
