USE DiscHavenDB
GO

---Security SPs---
DROP PROCEDURE IF EXISTS uspOpenKeys;
GO
CREATE PROCEDURE uspOpenKeys
AS
BEGIN
	SET NOCOUNT ON
    OPEN SYMMETRIC KEY DHKey DECRYPTION BY CERTIFICATE DHCertificate
END
GO

DROP FUNCTION IF EXISTS usfEncrypt;
GO
CREATE FUNCTION usfEncrypt
(
	@pPlainValue	NVARCHAR(MAX)
)
	RETURNS VARBINARY(256)
AS
BEGIN
	RETURN EncryptByKey(Key_GUID('DHKey'), @pPlainValue)
END
GO

DROP FUNCTION IF EXISTS usfDecrypt;
GO
CREATE FUNCTION usfDecrypt
(
	@pEncryptedValue	VARBINARY(256)
)
	RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN DecryptByKey(@pEncryptedValue)
END
GO

---Customer SPs---

DROP PROCEDURE IF EXISTS uspAddCustomer
GO
Create PROCEDURE uspAddCustomer
	@UserName NVARCHAR(50),
	@FirstName NVARCHAR(50),	
	@LastName NVARCHAR(50),	
	@Password NVARCHAR(100),
	@Email NVARCHAR(MAX),
	@PostalNumber NVARCHAR(40), 
	@PostalStreet NVARCHAR(100),
	@PostalSuburb NVARCHAR(100),
	@PostalTown NVARCHAR(100),
	@PostalState NVARCHAR(4),
	@PostalCountry NVARCHAR(100),
	@ShippingNumber NVARCHAR(40),
	@ShippingStreet NVARCHAR(100),
	@ShippingSuburb NVARCHAR(100),
	@ShippingTown NVARCHAR(100),
	@ShippingState NVARCHAR(4),
	@ShippingCountry NVARCHAR(100),
	@PostalIsShipping BIT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Salt UNIQUEIDENTIFIER = NEWID()
	BEGIN TRY
		INSERT INTO tblCustomer
		(
			UserName,
			FirstName,
			LastName,
			Email,
			PasswordHash,
			Salt,
			PostalNumber,
			PostalStreet,
			PostalSuburb,
			PostalTown,
			PostalState,
			PostalCountry,
			ShippingNumber,
			ShippingStreet,
			ShippingSuburb,
			ShippingTown,
			ShippingState,
			ShippingCountry,
			PostalIsShipping
		)
		VALUES
		(
			@UserName,
			@FirstName,
			@LastName,
			@Email,
			HASHBYTES('SHA2_512', @Password + CAST(@Salt AS NVARCHAR(36))),
			@Salt,
			@PostalNumber,
			@PostalStreet,
			@PostalSuburb,
			@PostalTown,
			@PostalState,
			@PostalCountry,
			@ShippingNumber,
			@ShippingStreet,
			@ShippingSuburb,
			@ShippingTown,
			@ShippingState,
			@ShippingCountry,
			@PostalIsShipping
		)
		SET @pBigResult = CAST (SCOPE_IDENTITY() AS BIGINT)
		SET @pErrorMessage = NULL
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0
		SET @pErrorMessage = ERROR_MESSAGE()
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspUpdateCustomer
GO
CREATE PROCEDURE uspUpdateCustomer
	@ID BIGINT,
	@UserName NVARCHAR(50),
	@FirstName NVARCHAR(50),	
	@LastName NVARCHAR(50),	
	@Password NVARCHAR(100),
	@Email NVARCHAR(MAX),
	@PostalNumber NVARCHAR(40), 
	@PostalStreet NVARCHAR(100),
	@PostalSuburb NVARCHAR(100),
	@PostalTown NVARCHAR(100),
	@PostalState NVARCHAR(4),
	@PostalCountry NVARCHAR(100),
	@ShippingNumber NVARCHAR(40),
	@ShippingStreet NVARCHAR(100),
	@ShippingSuburb NVARCHAR(100),
	@ShippingTown NVARCHAR(100),
	@ShippingState NVARCHAR(4),
	@ShippingCountry NVARCHAR(100),
	@PostalIsShipping BIT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
	IF (@Password IS NOT NULL AND LEN(@Password) > 1)
	BEGIN
		UPDATE 
			tblCustomer
		SET
			Username = @Username,
			FirstName = @FirstName,
			LastName = @LastName,
			PasswordHash = HASHBYTES('SHA2_512', @Password + CAST(Salt AS NVARCHAR(36))),
			Email = @Email,
			PostalNumber = @PostalNumber,
			PostalStreet = @PostalStreet,
			PostalSuburb = @PostalSuburb,
			PostalTown = @PostalTown,
			PostalState = @PostalState,
			PostalCountry = @PostalCountry,
			ShippingNumber = @ShippingNumber,
			ShippingStreet = @ShippingStreet,
			ShippingSuburb = @ShippingSuburb,
			ShippingTown = @ShippingTown,
			ShippingState =	@ShippingState,
			ShippingCountry = @ShippingCountry,
			PostalIsShipping = @PostalIsShipping
		WHERE
			ID = @ID

		SET @pBigResult = ROWCOUNT_BIG();
		RETURN 1;
	END
	BEGIN
		UPDATE 
			tblCustomer
		SET
			Username = @Username,
			FirstName = @FirstName,
			LastName = @LastName,
			Email = @Email,
			PostalNumber = @PostalNumber,
			PostalStreet = @PostalStreet,
			PostalSuburb = @PostalSuburb,
			PostalTown = @PostalTown,
			PostalState = @PostalState,
			PostalCountry = @PostalCountry,
			ShippingNumber = @ShippingNumber,
			ShippingStreet = @ShippingStreet,
			ShippingSuburb = @ShippingSuburb,
			ShippingTown = @ShippingTown,
			ShippingState =	@ShippingState,
			ShippingCountry = @ShippingCountry,
			PostalIsShipping = @PostalIsShipping
		WHERE
			ID = @ID

		SET @pBigResult = ROWCOUNT_BIG();
		RETURN 1;
	END
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0;
		SET @pErrorMessage = ERROR_MESSAGE();
		RETURN -1;
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspCustomerLogin
GO
CREATE PROCEDURE uspCustomerLogin
	@Username AS NVARCHAR(MAX),
	@Password AS NVARCHAR(MAX),
	@pBigResult	BIGINT = 0 OUTPUT,
	@pErrorMessage	NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN
	BEGIN TRY
	SELECT
		C.*
	FROM
		tblCustomer C
	WHERE
		C.UserName = @Username AND
		C.PasswordHash = (HASHBYTES('SHA2_512', @Password + CAST(Salt AS NVARCHAR(36))))
	END TRY
	BEGIN CATCH
		SET @pBigResult = -1;
		SET @pErrorMessage = ERROR_MESSAGE();
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspDeleteCustomer
GO
CREATE PROCEDURE uspDeleteCustomer
	@pID BIGINT,
	@pBigResult	BIGINT = 0 OUTPUT,
	@pErrorMessage	NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN
	BEGIN TRY
	DELETE 
		tblCustomer
	WHERE
		ID = @pID

	SET @pBigResult = ROWCOUNT_BIG();
	RETURN 1
	END TRY
	BEGIN CATCH
		SET @pBigResult = -1;
		SET @pErrorMessage = ERROR_MESSAGE();
		RETURN -1;
	END CATCH
END
GO

---Staff SP's---

DROP PROCEDURE IF EXISTS uspAddStaff
GO
Create PROCEDURE uspAddStaff
	@Username NVARCHAR(50),
	@FirstName NVARCHAR(50),
	@LastName NVARCHAR(50),
	@Password NVARCHAR(100),
	@Email NVARCHAR(50),
	@FKRoleID BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		DECLARE @Salt UNIQUEIDENTIFIER = NEWID()

		INSERT INTO tblStaff
		(
			Username,
			FirstName,
			LastName,
			PasswordHash,
			Salt,
			Email,
			FKRoleID
		)
		VALUES
		(
			@Username,
			@FirstName,
			@LastName,
			HASHBYTES('SHA2_512', @Password + CAST(@Salt AS NVARCHAR(36))),
			@Salt,
			@Email,
			@FKRoleID
		)

		SET @pBigResult = ROWCOUNT_BIG();
		RETURN 1;
	END TRY
	BEGIN CATCH
		SET @pBigResult = -1;
		SET @pErrorMessage = ERROR_MESSAGE();
		RETURN -1;
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspEditStaff
GO
CREATE PROCEDURE uspEditStaff
	@ID BIGINT,
	@Username NVARCHAR(50),
	@FirstName NVARCHAR(50),
	@LastName NVARCHAR(50),
	@Password NVARCHAR(100),
	@Email NVARCHAR(50),
	@FKRoleID BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		IF (@Password IS NOT NULL AND LEN(@Password) > 1)
		BEGIN
		UPDATE 
			tblStaff
		SET
			Username = @Username,
			FirstName = @FirstName,
			LastName = @LastName,
			PasswordHash = HASHBYTES('SHA2_512', @Password + CAST(Salt AS NVARCHAR(36))),
			Email = @Email,
			FKRoleID = @FKRoleID
		WHERE
			ID = @ID
		END
		ELSE
		BEGIN
		UPDATE 
			tblStaff
		SET
			Username = @Username,
			FirstName = @FirstName,
			LastName = @LastName,
			Email = @Email,
			FKRoleID = @FKRoleID
		WHERE
			ID = @ID
		END
	END TRY
	BEGIN CATCH
		SET @pBigResult = -1;
		SET @pErrorMessage = ERROR_MESSAGE();
		RETURN -1;
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspDeleteStaff
GO
CREATE PROCEDURE uspDeleteStaff
	@ID BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
	DELETE 
		tblStaff
	WHERE
		ID = @ID

	SET @pBigResult = ROWCOUNT_BIG();
	RETURN 1
	END TRY
	BEGIN CATCH
		SET @pBigResult = -1;
		SET @pErrorMessage = ERROR_MESSAGE();
		RETURN -1;
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspChangeStaffRole
GO
CREATE PROCEDURE uspChangeStaffRole
	@ID BIGINT,
	@FKRoleID BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
	UPDATE 
		tblStaff
	SET
		FKRoleID = @FKRoleID
	WHERE
		ID = @ID

	SET @pBigResult = ROWCOUNT_BIG();
	RETURN 1
	END TRY
	BEGIN CATCH
		SET @pBigResult = -1;
		SET @pErrorMessage = ERROR_MESSAGE();
		RETURN -1;
	END CATCH
END

DROP PROCEDURE IF EXISTS uspDeactivateStaff
GO
CREATE PROCEDURE uspDeactivateStaff
	@ID BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
	UPDATE 
		tblStaff
	SET
		DateDeactivated = GETDATE()
	WHERE
		ID = @ID

	SET @pBigResult = ROWCOUNT_BIG();
	RETURN 1
	END TRY
	BEGIN CATCH
		SET @pBigResult = -1;
		SET @pErrorMessage = ERROR_MESSAGE();
		RETURN -1;
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspReactivateStaff
GO
CREATE PROCEDURE uspReactivateStaff
	@ID BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
	UPDATE 
		tblStaff
	SET
		DateDeactivated = NULL
	WHERE
		ID = @ID

	SET @pBigResult = ROWCOUNT_BIG();
	RETURN 1
	END TRY
	BEGIN CATCH
		SET @pBigResult = -1;
		SET @pErrorMessage = ERROR_MESSAGE();
		RETURN -1;
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uppStaffLogin
GO
CREATE PROCEDURE uppStaffLogin
	@Username NVARCHAR(50),
	@Password NVARCHAR(100),
	@pErrorMessage NVARCHAR(MAX) OUTPUT,
	@pBigResult BIGINT OUTPUT
AS
BEGIN
	BEGIN TRY
	SELECT
		S.*
	FROM
		tblStaff S
	WHERE
		S.Username = @Username AND
		S.PasswordHash = (HASHBYTES('SHA2_512', @Password + CAST(Salt AS NVARCHAR(36))))
	END TRY
	BEGIN CATCH
		SET @pBigResult = -1;
		SET @pErrorMessage = ERROR_MESSAGE();
	END CATCH
END
GO


---Product SPs---

DROP PROCEDURE IF EXISTS uspAddProduct
GO
Create PROCEDURE uspAddProduct
	@ProductName AS NVARCHAR(MAX),
	@ProductDescription AS NVARCHAR(MAX),
	@ProductImage AS NVARCHAR(MAX),
	@RRP AS DECIMAL(19, 2),
	@SpecialPrice AS DECIMAL(19, 2),
	@ProductStatus AS BIT,
	@FKWorkID AS BIGINT,
	@FKMediaTypeID AS BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		INSERT INTO tblProduct
		(
			[Name],
			[Description],
			[Image],
			RRP,
			SpecialPrice,
			[Status],
			FKWorkID,
			FKMediaTypeID
		)
		VALUES
		(
			@ProductName,
			@ProductDescription,
			@ProductImage,
			@RRP,
			@SpecialPrice,
			@ProductStatus,
			@FKWorkID,
			@FKMediaTypeID			
		)
		SET @pBigResult = CAST (SCOPE_IDENTITY() AS BIGINT)
		SET @pErrorMessage = NULL
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0
		SET @pErrorMessage = ERROR_MESSAGE()
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspUpdateProduct
GO
CREATE PROCEDURE uspUpdateProduct
	@ID AS BIGINT,
	@ProductName AS NVARCHAR(MAX),
	@ProductDescription AS NVARCHAR(MAX),
	@ProductImage AS NVARCHAR(MAX),
	@RRP AS DECIMAL(19, 2),
	@SpecialPrice AS DECIMAL(19, 2),
	@ProductStatus AS BIT,
	@FKWorkID AS BIGINT,
	@FKMediaTypeID AS BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		UPDATE 
			tblProduct
		SET
			[Name] = @ProductName,
			[Description] = @ProductDescription,
			[Image] = @ProductImage,
			RRP = @RRP,
			SpecialPrice = @SpecialPrice,
			[Status] = @ProductStatus,
			FKWorkID = @FKWorkID,
			FKMediaTypeID = @FKMediaTypeID
		WHERE
			ID = @ID

		SET @pBigResult = ROWCOUNT_BIG();
		RETURN 1;
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0;
		SET @pErrorMessage = ERROR_MESSAGE();
		RETURN -1;
	END CATCH
END

DROP PROCEDURE IF EXISTS uspDeleteProduct
GO
CREATE PROCEDURE uspDeleteProduct
	@pID BIGINT,
	@pErrorMessage	NVARCHAR(MAX) = '' OUTPUT
AS
BEGIN
	DECLARE @ProductCount INT = (SELECT COUNT(*) FROM tblOrderItem WHERE FKProductID = @pID) 
	IF(@ProductCount < 1)
	BEGIN TRY
		DELETE 
			tblProduct
		WHERE
			ID = @pID
		RETURN 1;
	END TRY
	BEGIN CATCH
		SET @pErrorMessage = ERROR_MESSAGE();
		RETURN -1;
	END CATCH
END	

--DROP PROCEDURE IF EXISTS GetProductsInBackOrder
--GO
--CREATE PROCEDURE GetProductsInBackOrder
--	@pBigResult BIGINT OUTPUT,
--	@pErrorMessage NVARCHAR(MAX) OUTPUT
--AS
--BEGIN
--	BEGIN TRY
--		SELECT
--			P.ID,
--			P.Name,
--			RRP,
--			SpecialPrice,
--			FKMediaTypeID,
--			Category
--		FROM
--			tblProduct P INNER JOIN tblStock S ON P.ID = S.FKProductID INNER JOIN tblWork W ON P.FKWorkID = W.ID INNER JOIN tblCategory C ON W.FKCategoryID = C.ID
--		WHERE
--			S.Stock < 0

--		SET @pBigResult = ROWCOUNT_BIG();
--		SET @pErrorMessage = NULL;
--	END TRY
--	BEGIN CATCH
--		SET @pBigResult = 0;
--		SET @pErrorMessage = ERROR_MESSAGE();
--	END CATCH
--END

---Secret Questions and Answers SPs---

DROP PROCEDURE IF EXISTS uspAddSecretQA
GO
Create PROCEDURE uspAddSecretQA
	@SecretQuestion NVARCHAR(MAX),
	@SecretAnswer NVARCHAR(MAX),
	@CustomerID BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @Salt UNIQUEIDENTIFIER = NEWID()
	BEGIN TRY
		EXECUTE uspOpenKeys;
		INSERT INTO tblSecretQA
		(
			Question,
			Answer,
			Salt,
			FKCustomerID
		)
		VALUES
		(
			dbo.usfEncrypt(@SecretQuestion),
			HASHBYTES('SHA2_512', @SecretAnswer + CAST(@Salt AS NVARCHAR(36))),
			@Salt,
			@CustomerID
		)
		SET @pBigResult = CAST (SCOPE_IDENTITY() AS BIGINT)
		SET @pErrorMessage = NULL
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0
		SET @pErrorMessage = ERROR_MESSAGE()
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspUnlockSecretQA
GO
Create PROCEDURE uspUnlockSecretQA
	@CID BIGINT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	EXECUTE uspOpenKeys;

	BEGIN TRY
		SELECT
			Q.ID,
			dbo.usfDecrypt(Q.Question) AS [SecretQDecrypted]
		FROM
			[tblSecretQA] Q
		WHERE
			@CID = Q.FKCustomerID;
	END TRY
	BEGIN CATCH
		SET @pErrorMessage = ERROR_MESSAGE()
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspQAVerify
GO
CREATE PROCEDURE uspQAVerify
	@ID BIGINT,
	@Answer NVARCHAR(MAX),
	@CID BIGINT
AS
BEGIN
	EXECUTE uspOpenKeys;

	SELECT
		A.ID
	FROM
		tblSecretQA A
	WHERE
		A.FKCustomerID = @CID AND A.Answer = (HASHBYTES('SHA2_512', @Answer + CAST(A.Salt AS NVARCHAR(36))))
END
GO

DROP PROCEDURE IF EXISTS uspGetSecretQAs
GO
CREATE PROCEDURE  uspGetSecretQAs
	@CustomerID BIGINT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
	DECLARE @NumChallenges INT = (SELECT RequiredQA FROM tblProperties) 

	SELECT TOP (@NumChallenges) 
		Q.*
	FROM 
		tblSecretQA Q
	WHERE 
		Q.FKCustomerID = @CustomerID 
	ORDER BY
		NEWID() 
	END TRY
	BEGIN CATCH
		SET @pErrorMessage = ERROR_MESSAGE()
	END CATCH
END

---Search Item SPs---

DROP PROCEDURE IF EXISTS uspAddSearchItem
GO
CREATE PROCEDURE uspAddSearchItem
	@CustomerID BIGINT,
	@SearchTerm NVARCHAR(MAX),
	@WorkID BIGINT,
	@CategoryID BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		BEGIN
			INSERT INTO tblSearch
			(
				SearchTerm,
				WorkID,
				CategoryID,
				FKCustomerID
			)
			VALUES
			(
				@SearchTerm,
				@WorkID,
				@CategoryID,
				@CustomerID
			)
			SET @pBigResult = CAST (SCOPE_IDENTITY() AS BIGINT)
		END
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0;
		SET @pErrorMessage = ERROR_MESSAGE();
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspGetCustomerSearches
GO
CREATE PROCEDURE uspGetCustomerSearches
	@CustomerID BIGINT
AS
BEGIN
	SELECT
		S.*
	FROM
		tblSearch S
	WHERE
		S.FKCustomerID = @CustomerID
END
GO

---Order SPs---

DROP PROCEDURE IF EXISTS uspCreateOrder
GO
CREATE PROCEDURE uspCreateOrder
	@FKStatusID BIGINT,
	@CustomerID BIGINT,
	@GST DECIMAL(19, 2),
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		INSERT INTO tblOrder
		(
			GST,
			FKStatusID,
			FKCustomerID
		)
		VALUES
		(
			@GST,
			@FKStatusID,
			@CustomerID
		)
		SET @pBigResult = CAST (SCOPE_IDENTITY() AS BIGINT)
		SET @pErrorMessage = NULL
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0
		SET @pErrorMessage = ERROR_MESSAGE()
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspAddOrderItem
GO
CREATE PROCEDURE uspAddOrderItem
	@Quantity INT,
	@SalePrice DECIMAL(19, 2),
	@Description NVARCHAR(MAX),
	@FKOrderID BIGINT,
	@FKProductID BIGINT,
	@FKItemStatusID BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		INSERT INTO tblOrderItem
		(
			Quantity,
			SalePrice,
			[Description],
			FKOrderID,
			FKProductID,
			FKItemStatusID
		)
		VALUES
		(
			@Quantity,
			@SalePrice,
			@Description,
			@FKOrderID,
			@FKProductID,
			@FKItemStatusID
		)
		SET @pBigResult = CAST (SCOPE_IDENTITY() AS BIGINT)
		SET @pErrorMessage = NULL
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0
		SET @pErrorMessage = ERROR_MESSAGE()
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspRetrieveOrderItems
GO
CREATE PROCEDURE uspRetrieveOrderItems
	@OrderID INT
AS
BEGIN
	BEGIN TRY
		SELECT
			I.*
		FROM
			tblOrderItem I
		WHERE
			I.FKOrderID = @OrderID
	END TRY
	BEGIN CATCH
		
	END CATCH
END

DROP PROCEDURE IF EXISTS uspRetrieveOrders
GO
CREATE PROCEDURE uspRetrieveOrders
	@CustomerID INT
AS
BEGIN
	SELECT
		O.*
	FROM
		tblOrder O
	WHERE
		O.FKCustomerID = @CustomerID
END

--- Cart SPs ---

DROP PROCEDURE IF EXISTS uspGetUserCart
GO
CREATE PROCEDURE uspGetUserCart
	@CustomerID BIGINT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		SELECT
			C.*
		FROM
			tblCartItem C
		WHERE
			C.FKCustomerID = @CustomerID
		RETURN 1;
	END TRY
	BEGIN CATCH
		RETURN 0;
		SET @pErrorMessage = ERROR_MESSAGE()
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspAddCartItem
GO
CREATE PROCEDURE uspAddCartItem
	@Quantity INT,
	@ProductID BIGINT,
	@CustomerID BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		INSERT INTO tblCartItem
		(
			Quantity,
			FKProductID,
			FKCustomerID
		)
		VALUES
		(
			@Quantity,
			@ProductID,
			@CustomerID
		)
		SET @pBigResult = SCOPE_IDENTITY()
		RETURN 1
	END TRY
	BEGIN CATCH
		SET @pErrorMessage = ERROR_MESSAGE()
		RETURN -1
	END CATCH
END

DROP PROCEDURE IF EXISTS uspRemoveCartItem
GO
CREATE PROCEDURE uspRemoveCartItem
	@pID BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		DELETE
			tblCartItem
		WHERE
			ID = @pID
		SET @pBigResult = 1
		SET @pErrorMessage = null
		RETURN 1
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0
		SET @pErrorMessage = ERROR_MESSAGE()
		RETURN -1
	END CATCH
END
GO

CREATE PROCEDURE uspDeleteUserCart
	@CustomerID BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		DELETE
			tblCartItem
		WHERE
			FKCustomerID = @CustomerID
		SET @pBigResult = 0
		SET @pErrorMessage = null;
		RETURN 1
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0
		SET @pErrorMessage = ERROR_MESSAGE()
		RETURN -1
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspUpdateCartItem
GO
CREATE PROCEDURE uspUpdateCartItem
	@ID BIGINT,
	@Quantity INT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		UPDATE
			tblCartItem
		SET
			Quantity = @Quantity
		WHERE
			ID = @ID

		SET @pBigResult = ROWCOUNT_BIG();
		RETURN 1;
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0;
		SET @pErrorMessage = ERROR_MESSAGE();
		RETURN -1;
	END CATCH
END
GO

--- Stock Sp's---

DROP PROCEDURE IF EXISTS uspAddStock
GO
CREATE PROCEDURE uspAddStock
	@Stock INT,
	@FKLocationID BIGINT,
	@FKProductID BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		INSERT INTO tblStock
		(
			Stock,
			FKLocationID,
			FKProductID
		)
		VALUES
		(
			@Stock,
			@FKLocationID,
			@FKProductID
		)
		SET @pBigResult = SCOPE_IDENTITY()
		RETURN 1
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0;
		SET @pErrorMessage = ERROR_MESSAGE();
		RETURN -1;
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspUpdateStock
GO
CREATE PROCEDURE uspUpdateStock
	@ID BIGINT,
	@Stock INT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		UPDATE
			tblStock
		SET
			Stock = @Stock
		WHERE
			ID = @ID
		SET @pBigResult = ROWCOUNT_BIG();
		RETURN 1;
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0;
		SET @pErrorMessage = ERROR_MESSAGE();
		RETURN -1;
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspRetrieveStock
GO
CREATE PROCEDURE uspRetrieveStock
	@FKLocationID BIGINT,
	@FKProductID BIGINT
AS
BEGIN
	SELECT
		S.*
	FROM
		tblStock S
	WHERE
		S.FKLocationID = @FKLocationID AND
		S.FKProductID = @FKProductID
END
GO

DROP PROCEDURE IF EXISTS uspDeleteStock
GO
CREATE PROCEDURE uspDeleteStock
	@ID BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		DELETE
			tblStock
		WHERE
			ID = @ID
		SET @pBigResult = 1
		SET @pErrorMessage = null
		RETURN 1
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0
		SET @pErrorMessage = ERROR_MESSAGE()
		RETURN -1
	END CATCH
END
GO

--- MediaType SPs ---

DROP PROCEDURE IF EXISTS uspCreateMediaType
GO
CREATE PROCEDURE uspCreateMediaType
	@Name NVARCHAR(50),
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		INSERT INTO tblMediaType
		(
			MediaType
		)
		VALUES
		(
			@Name
		)

		SET @pBigResult = SCOPE_IDENTITY()
		SET @pErrorMessage = NULL
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0
		SET @pErrorMessage = ERROR_MESSAGE()
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspUpdateMediaType
GO
CREATE PROCEDURE uspUpdateMediaType
	@ID BIGINT,
	@Name NVARCHAR(50),
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		UPDATE
			tblMediaType
		SET
			MediaType = @Name
		WHERE
			ID = @ID

		SET @pBigResult = ROWCOUNT_BIG();
		SET @pErrorMessage = NULL;
		RETURN 1;
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0;
		SET @pErrorMessage = ERROR_MESSAGE();
		RETURN -1;
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspDeleteMediaType
GO
CREATE PROCEDURE uspDeleteMediaType
	@ID BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		DELETE
			tblMediaType
		WHERE
			ID = @ID

		SET @pBigResult = ROWCOUNT_BIG();
		SET @pErrorMessage = NULL;
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0;
		SET @pErrorMessage = ERROR_MESSAGE();
	END CATCH
END

--- Category SPs ---

DROP PROCEDURE IF EXISTS uspCreateCategory
GO
CREATE PROCEDURE uspCreateCategory
	@Category NVARCHAR(30),
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		INSERT INTO tblCategory
		(
			Category
		)
		VALUES
		(
			@Category
		)

		SET @pBigResult = SCOPE_IDENTITY()
		SET @pErrorMessage = NULL
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0
		SET @pErrorMessage = ERROR_MESSAGE()
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspUpdateCategory
GO
CREATE PROCEDURE uspUpdateCategory
	@ID BIGINT,
	@Category NVARCHAR(30),
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		UPDATE
			tblCategory
		SET
			Category = @Category
		WHERE
			ID = @ID

		SET @pBigResult = ROWCOUNT_BIG();
		SET @pErrorMessage = NULL;
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0;
		SET @pErrorMessage = ERROR_MESSAGE();
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspGetCategories
GO
CREATE PROCEDURE uspGetCategories
	@pBigResult BIGINT OUTPUT
AS
BEGIN
	BEGIN TRY
		SELECT
			*
		FROM
			tblCategory

		SET @pBigResult = SCOPE_IDENTITY()
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0
	END CATCH
END

--- Work SPs ---

DROP PROCEDURE IF EXISTS uspCreateWork
GO
CREATE PROCEDURE uspCreateWork
	@WorkName NVARCHAR(100),
	@FKCategoryID BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		INSERT INTO tblWork
		(
			Name,
			FKCategoryID
		)
		VALUES
		(
			@WorkName,
			@FKCategoryID
		)

		SET @pBigResult = CAST (SCOPE_IDENTITY() AS BIGINT)
		SET @pErrorMessage = NULL
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0
		SET @pErrorMessage = ERROR_MESSAGE()
	END CATCH
END
GO

DROP PROCEDURE IF EXISTS uspUpdateWork
GO
CREATE PROCEDURE uspUpdateWork
	@ID BIGINT,
	@WorkName NVARCHAR(100),
	@FKCategoryID BIGINT,
	@pBigResult BIGINT OUTPUT,
	@pErrorMessage NVARCHAR(MAX) OUTPUT
AS
BEGIN
	BEGIN TRY
		UPDATE
			tblWork
		SET
			Name = @WorkName,
			FKCategoryID = @FKCategoryID
		WHERE
			ID = @ID

		SET @pBigResult = ROWCOUNT_BIG();
		SET @pErrorMessage = NULL;
	END TRY
	BEGIN CATCH
		SET @pBigResult = 0;
		SET @pErrorMessage = ERROR_MESSAGE();
	END CATCH
END
GO

--- Properties SPs --

DROP PROCEDURE IF EXISTS GetProperties
GO
CREATE PROCEDURE GetProperties
AS
BEGIN
	SELECT
		*
	FROM
		tblProperties
END
GO

DROP PROCEDURE IF EXISTS UpdateProperties
GO
CREATE PROCEDURE UpdateProperties
	@pID BIGINT,
	@GST DECIMAL(19,2),
	@SecretQAAmount INT,
	@WareHouseStoreID BIGINT,
	@RequiredQA INT
AS
BEGIN
	BEGIN TRY
		UPDATE
			tblProperties
		SET
			GST = @GST,
			SecretQAAmount = @SecretQAAmount,
			WareHouseStoreID = @WareHouseStoreID,
			RequiredQA = @RequiredQA
		WHERE
			ID = @pID

		RETURN 1
	END TRY
	BEGIN CATCH
		RETURN -1
	END CATCH
END

--- Admin Queries ---

DROP PROCEDURE IF EXISTS GetProductsInStock
GO
CREATE PROCEDURE GetProductsInStock
	@LocationID BIGINT
AS
BEGIN
	SELECT
		P.ID
	FROM
		tblProduct P INNER JOIN tblStock S ON P.ID = S.FKProductID INNER JOIN tblWork W ON P.FKWorkID = W.ID INNER JOIN tblCategory C ON W.FKCategoryID = C.ID
	WHERE
		S.FKLocationID = @LocationID AND
		S.Stock > 0
	GROUP BY
		C.Category, P.ID
END

DROP PROCEDURE IF EXISTS GetProductsInBackOrder
GO
CREATE PROCEDURE GetProductsInBackOrder
	@LocationID BIGINT
AS
BEGIN
	SELECT
		P.*
	FROM
		tblProduct P INNER JOIN tblStock S ON P.ID = S.FKProductID
	WHERE
		S.Stock < 0 AND S.FKLocationID = @LocationID
END

---Stored Procedure Template---

--DROP PROCEDURE IF EXISTS 
--GO
--CREATE PROCEDURE 
	
--AS
--BEGIN
--	BEGIN TRY

--	END TRY
--	BEGIN CATCH

--	END CATCH
--END
