------------------------------------LINQ--BETWEEN--TABLES-----------------------------------
-----Accounts-----Clients-----------
ALTER TABLE Accounts
ADD CONSTRAINT FK_Accounts_Clients
FOREIGN KEY (Account_Id)
REFERENCES Clients (Client_Id);
---------------------------------------------------------
-----Cards-----Accounts--------------
ALTER TABLE Cards
ADD CONSTRAINT FK_Cards_Accounts
FOREIGN KEY (Account_Id)
REFERENCES Accounts (Account_Id);
----------------------------------------------------------
-----Clients-----Banks-----------------
ALTER TABLE Clients
ADD CONSTRAINT FK_Clients_Banks
FOREIGN KEY (Bank_Id)
REFERENCES Banks (Bank_Id);
----------------------------------------------------------
-----Clients----SocialStatus------------
ALTER TABLE Clients
ADD CONSTRAINT FK_Clients_SocialStatus
FOREIGN KEY (SocialStatus_Id)
REFERENCES SocialStatus (SocialStatus_Id);
------------------------------------------------------------
-----Subsidiary-----Banks---------------
ALTER TABLE Subsidiaries
ADD CONSTRAINT FK_Subsidiaries_Banks
FOREIGN KEY (Bank_Id)
REFERENCES Banks (Bank_Id);
------------------------------------------------------------
