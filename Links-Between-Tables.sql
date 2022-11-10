
ALTER TABLE Accounts
ADD CONSTRAINT FK_Accounts_Clients
FOREIGN KEY (Account_Id)
REFERENCES Clients (Client_Id);
 
 
ALTER TABLE Cards
ADD CONSTRAINT FK_Cards_Accounts
FOREIGN KEY (Account_Id)
REFERENCES Accounts (Account_Id);
 
 
ALTER TABLE Clients
ADD CONSTRAINT FK_Clients_Banks
FOREIGN KEY (Bank_Id)
REFERENCES Banks (Bank_Id);
 
 
ALTER TABLE Clients
ADD CONSTRAINT FK_Clients_SocialStatus
FOREIGN KEY (SocialStatus_Id)
REFERENCES SocialStatus (SocialStatus_Id);
 
 
ALTER TABLE Subsidiaries
ADD CONSTRAINT FK_Subsidiaries_Banks
FOREIGN KEY (Bank_Id)
REFERENCES Banks (Bank_Id);

