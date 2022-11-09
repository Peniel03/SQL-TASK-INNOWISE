-----------------------------------------------------------------------------Query1---------------------------------------------------------------------------------
/*Прочитать условия запросов и создать структуру базы. Заполнить базу значениями. 
В каждой таблице-словаре минимум по 5 значений. */
-----------------------------------------------------------------------------Query2---------------------------------------------------------------------------------
/*Покажи мне список банков у которых есть филиалы в городе X (выбери один из городов)*/
USE Bank
SELECT Banks.Bank_Name 
FROM Banks  JOIN Subsidiaries ON Banks.Bank_Id = Subsidiaries.Bank_Id
WHERE Subsidiaries.Subsidiary_City = 'paris';
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------Query3---------------------------------------------------------------------------------
/* Получить список карточек с указанием имени владельца, баланса и названия банка */
USE Bank
SELECT  Clients.Client_Name, Cards.Card_Number , Cards.Card_Balance  , Banks.Bank_name
FROM Banks JOIN Clients ON Banks.Bank_Id = Clients.Bank_Id
JOIN 
Accounts ON Clients.client_Id = Accounts.Account_Id 
JOIN
Cards ON Accounts.Account_Id = Cards.Account_Id 
WHERE Clients.Client_Name = 'peter' ;
------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------Query4---------------------------------------------------------------------------------
/*Показать список банковских аккаунтов у которых баланс не совпадает с суммой баланса 
по карточкам. В отдельной колонке вывести разницу  */
SELECT Accounts.Account_Balance,Cards.Card_Balance, 
Accounts.Account_Balance - SUM(Cards.Card_Balance) AS "Difference" 
FROM Accounts JOIN Cards ON Accounts.Account_Id = Cards.Account_Id
GROUP BY Accounts.Account_Balance,Cards.Card_Balance
HAVING SUM(Cards.Card_Balance) != Accounts.Account_Balance  
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------Query5---------------------------------------------------------------------------------
/*Вывести кол-во банковских карточек для каждого соц статуса 
(2 реализации, GROUP BY и подзапросом) */
SELECT SUM(Accounts.Account_Number_of_Cards)  AS "Total Number of Cards By social Status" ,SocialStatus.SocialStatus_Name
FROM SocialStatus JOIN Clients ON SocialStatus.SocialStatus_Id = Clients.SocialStatus_Id
JOIN
Accounts ON Clients.client_Id = Accounts.Account_Id 
WHERE SocialStatus.SocialStatus_Id = Clients.SocialStatus_Id
GROUP BY SocialStatus.SocialStatus_Name
//--------------------------------
/* подзапрос*/
SELECT SUM(Accounts.Account_Number_of_Cards)  AS "Total Number of Cards By social Status",SocialStatus_Name
FROM Accounts JOIN (SELECT Clients.client_Id, SocialStatus_Name
					FROM Clients JOIN SocialStatus ON SocialStatus.SocialStatus_Id = Clients.SocialStatus_Id)
					AS x
	ON x.client_Id = Accounts.Account_Id
GROUP BY SocialStatus_Name
 --------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ----------------------------------------------------------------------Query6---------------------------------------------------------------------------------------
 /*Написать stored procedure которая будет добавлять по 10$ на каждый банковский аккаунт для определенного соц статуса
 (У каждого клиента бывают разные соц. статусы. Например, пенсионер, инвалид и прочее).
 Входной параметр процедуры - Id социального статуса. Обработать исключительные ситуации 
 (например, был введен неверные номер соц. статуса. Либо когда у этого статуса нет привязанных аккаунтов).*/
 CREATE PROCEDURE _ADD_TEN_DOLLARS__(@id_socialStatus integer)
AS 
DECLARE
@ten_dollars money,
@message varchar(30);
SET
@ten_dollars = 10 ;
BEGIN
BEGIN TRY
SELECT SocialStatus.[SocialStatus_Name] ,Accounts.[Account_Balance]
FROM SocialStatus JOIN Clients ON SocialStatus.[SocialStatus_Id] = Clients.[SocialStatus_Id]
JOIN Accounts ON Clients.[client_Id] = Accounts.[Account_Id] 
UPDATE Accounts
SET Account.[Account_Banlance] = Account.[Account_Banlance] + @ten_dollars
WHERE SocialStatus.[SocialStatus_Number] = @id_socialStatus  
END TRY
BEGIN CATCH
SELECT @message = 'There is not any corresponding socialStatus to this Id'
END CATCH
END;        
EXEC _ADD_TEN_DOLLARS 
@id_socialStatus = 2 
SELECT SocialStatus.[SocialStatus_Name] ,Accounts.[Account_Balance]
FROM SocialStatus JOIN Clients ON SocialStatus.[SocialStatus_Id] = Clients.[SocialStatus_Id]
JOIN Accounts ON Clients.[client_Id] = Accounts.[Account_Id] ;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------Query7-----------------------------------------------------------------------------------------------
/* Получить список доступных средств для каждого клиента. 
То есть если у клиента на банковском аккаунте 60 рублей, и у него 2 карточки по 15 рублей на каждой,
то у него доступно 30 рублей для перевода на любую из карт */
SELECT Clients.Client_Name , SUM(Cards.Card_Balance) AS 'Available funds'
FROM Clients JOIN Accounts ON Clients.Client_Id = Accounts.Account_Id 
JOIN Cards ON Accounts.Account_Id = Cards.Account_Id
WHERE Accounts.Account_Id = Cards.Account_Id 
GROUP BY Clients.Client_Name
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------Query8-----------------------------------------------------------------------------------------------
/*Написать процедуру которая будет переводить определённую сумму со счёта на карту этого аккаунта. 
При этом будем считать что деньги на счёту все равно останутся, просто сумма средств на карте увеличится. 
Например, у меня есть аккаунт на котором 1000 рублей и две карты по 300 рублей на каждой.
Я могу перевести 200 рублей на одну из карт, при этом баланс аккаунта останется 1000 рублей, 
а на картах будут суммы 300 и 500 рублей соответственно.
После этого я уже не смогу перевести 400 рублей с аккаунта ни на одну из карт,
так как останется всего 200 свободных рублей (1000-300-500). Переводить БЕЗОПАСНО. То есть использовать транзакцию */

CREATE PROCEDURE TranferFromAccountToCards 
    	@Amount_To_Transfer MONEY,
	    @Id_Account INT,
	    @Id_Card INT,
	   @AmountToTransfer MONEY
AS
DECLARE @account_balance MONEY
DECLARE @cards_balance MONEY
BEGIN
BEGIN TRY
BEGIN TRANSACTION
IF NOT EXISTS(
SELECT *  FROM Accounts WHERE Accounts.Account_Id = @Id_Account)
RAISERROR('There is not any account corresponding with this account Id',2,1)
IF NOT EXISTS(SELECT * FROM Cards WHERE Cards.Card_Id = @Id_Card)
RAISERROR('There is not any card corresponding with this card Id',2,1)
IF NOT EXISTS(SELECT * FROM Cards WHERE Card_Id = @Id_Card AND Account_Id = @Id_Account)
RAISERROR('this card and account are not corresponding',2,1)
UPDATE Cards
SET Card_Balance += @Amount_To_Transfer
FROM
(SELECT Cards.Card_Id FROM Cards WHERE Card_Id = @Id_Card) as Selected
WHERE Selected.Id = Cards.Cards_Id
SELECT @account_balance = Accounts.Account_Balance
FROM Accounts
WHERE Account_Id = @Id_Account
SELECT @cards_balance = SUM(Cards.Card_Balance)
FROM Cards
WHERE AccountId = @Id_Account
IF (@account_balance < @cards_balance)
   RAISERROR('The Account Balance can not be less than the cards balance !!',2,1)
END TRY
BEGIN CATCH
  RAISERROR('Error !!',2,1)
ROLLBACK TRANSACTION
RETURN
END CATCH
COMMIT TRANSACTION
END	
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------Query9---------------------------------------------------------------------------------------------------
/*Написать триггер на таблицы Account/Cards чтобы нельзя была занести значения в поле баланс если это противоречит условиям
(то есть нельзя изменить значение в Account на меньшее, чем сумма балансов по всем карточкам.
И соответственно нельзя изменить баланс карты если в итоге сумма на картах будет больше чем баланс аккаунта) */
 CREATE TRIGGER AccountBalanceMustBeGreaterThanSumOfCardsBalance
 AFTER INSERT OR UPDATE ON Accounts 
DECLARE 
 @card_Balance money;
BEGIN
BEGIN TRANSACTION
  WHERE EXISTS
  (
    SELECT Accounts.Account_Balance
    FROM Accounts
    WHERE Accounts.Account_Id = Cards.Account_Id
  )
  SET 
@card_Balance = SUM(Cards.Card_Balance);
IF Accounts.Account_Balance < @card_Balance
  RAISERROR('The Account Balance can not be less than the cards balance !!',2,1)
ROLLBACK TRANSACTION
END
-----------------------------------------------------------------
CREATE TRIGGER  SumOfCardsBalanceMustBeLessThanAccountBalance
 AFTER INSERT OR UPDATE ON Cards 
DECLARE 
@account_balance money,
@card_Balance money;
BEGIN
BEGIN TRANSACTION
  WHERE EXISTS
  (
    SELECT Cards.Card_Balance
    FROM Cards
    WHERE Cards.Account_I = Accounts.Account_Id 
  )
 SET 
@card_Balance = SUM(Cards.Card_Balance);
IF @card_Balance > Accounts.Account_Balance  
    RAISERROR('The card balance must be less than the acccount Balance !!',2,1)
ROLLBACK TRANSACTION
END
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------

 








 
 
