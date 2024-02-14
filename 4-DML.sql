USE DiscHavenDB
GO

--Initialisation for table values
--INSERT INTO tblRole(EmploymentType)VALUES('Staff')
--INSERT INTO tblRole(EmploymentType)VALUES('Admin')

INSERT INTO tblProperties(ID)VALUES(1);

INSERT INTO tblRole(Name)VALUES('Staff')
INSERT INTO tblRole(Name)VALUES('Admin')

INSERT INTO tblStatus(Status)VALUES('Pending')
INSERT INTO tblStatus(Status)VALUES('BackOrder')
INSERT INTO tblStatus(Status)VALUES('Shipped')
INSERT INTO tblStatus(Status)VALUES('Fufilled')

INSERT INTO tblItemStatus(ItemStatus)VALUES('BackOrder')
INSERT INTO tblItemStatus(ItemStatus)VALUES('Stocked')

INSERT INTO tblMediaType(MediaType)VALUES('DVD')
INSERT INTO tblMediaType(MediaType)VALUES('VHS')
INSERT INTO tblMediaType(MediaType)VALUES('CD')
INSERT INTO tblMediaType(MediaType)VALUES('Tape')

INSERT INTO tblStockLocation([Name])VALUES('Albany')
INSERT INTO tblStockLocation([Name])VALUES('Bunbury')
INSERT INTO tblStockLocation([Name])VALUES('Manjimup')
INSERT INTO tblStockLocation([Name])VALUES('Busselton')

DECLARE @JoeID	BIGINT;
DECLARE @DeezID	BIGINT;
DECLARE @MaxID	BIGINT;
DECLARE @AdminID BIGINT;
DECLARE @RowsUpdated BIGINT;
DECLARE @pErrorMessage NVARCHAR(MAX);
DECLARE @pBigResult BIGINT;

EXECUTE [uspAddCustomer]
	@UserName = N'JoeCucumber',
	@FirstName = N'Joe',
	@LastName = N'Cucumber',
	@Password = N'Cucumber1',
	@Email = N'ImcucumberJoe@gmail.com',
	@PostalNumber = '189',
	@PostalStreet = 'York Street',
	@PostalSuburb = 'Albany',
	@PostalTown = 'Albany',
	@PostalState = 'WA',
	@PostalCountry = 'Australia',
	@ShippingNumber = '189',
	@ShippingStreet = 'York Street',
	@ShippingSuburb = 'Albany',
	@ShippingTown = 'Albany',
	@ShippingState = 'WA',
	@ShippingCountry = 'Australia',
	@PostalIsShipping = 0,
	@pBigResult = @JoeID OUTPUT,
	@pErrorMessage = @pErrorMessage OUTPUT

SELECT * FROM tblCustomer

EXECUTE [uspAddCustomer]
	@UserName = N'DeezKnuts',
	@FirstName = N'Deez',
	@LastName = N'Knuts',
	@Password = N'Password1',
	@Email = N'somethingcaminthemailtoday@gmail.com',
	@PostalNumber = '189',
	@PostalStreet = 'York Street',
	@PostalSuburb = 'Albany',
	@PostalTown = 'Albany',
	@PostalState = 'WA',
	@PostalCountry = 'Australia',
	@ShippingNumber = '189',
	@ShippingStreet = 'York Street',
	@ShippingSuburb = 'Albany',
	@ShippingTown = 'Albany',
	@ShippingState = 'WA',
	@ShippingCountry = 'Australia',
	@PostalIsShipping = 0,
	@pBigResult = @DeezID OUTPUT,
	@pErrorMessage = @pErrorMessage OUTPUT

EXECUTE [uspAddCustomer]
	@UserName = N'MaxMoeFoe2',
	@FirstName = N'Max',
	@LastName = N'MoeFoe',
	@Password = N'OnlyASpoonful1',
	@Email = N'maxmoefoepokemon@gmail.com',
	@PostalNumber = '189',
	@PostalStreet = 'York Street',
	@PostalSuburb = 'Albany',
	@PostalTown = 'Albany',
	@PostalState = 'WA',
	@PostalCountry = 'Australia',
	@ShippingNumber = '189',
	@ShippingStreet = 'York Street',
	@ShippingSuburb = 'Albany',
	@ShippingTown = 'Albany',
	@ShippingState = 'WA',
	@ShippingCountry = 'Australia',
	@PostalIsShipping = 0,
	@pBigResult = @DeezID OUTPUT,
	@pErrorMessage = @pErrorMessage OUTPUT

EXECUTE [uspUpdateCustomer]
		@ID = @JoeID,
		@UserName = N'CucumberJoe',
		@FirstName = N'Joe',
		@LastName = N'Cucumber',
		@Password = N'Cucumber2',
		@Email = N'ImcucumberJoe@gmail.com',
		@PostalNumber = '189',
		@PostalStreet = 'York Street',
		@PostalSuburb = 'Albany',
		@PostalTown = 'Albany',
		@PostalState = 'WA',
		@PostalCountry = 'Australia',
		@ShippingNumber = '189',
		@ShippingStreet = 'York Street',
		@ShippingSuburb = 'Albany',
		@ShippingTown = 'Albany',
		@ShippingState = 'WA',
		@ShippingCountry = 'Australia',
		@PostalIsShipping = 0,
		@pErrorMessage = @pErrorMessage OUTPUT,
		@pBigResult = @RowsUpdated OUTPUT

SELECT * FROM tblCustomer;

EXEC uspCustomerLogin @Username = 'CucumberJoe', @Password = 'Cucumber2';

EXECUTE [uspAddStaff]
	@Username = N'TestAdmin',
	@FirstName = N'Joe',
	@LastName = N'Schmo',
	@Password = N'TestAdmin@123',
	@Email = N'ImAnAdmin@gmail.com',
	@FKRoleID = 2,
	@pBigResult = @AdminID OUTPUT,
	@pErrorMessage = @pErrorMessage OUTPUT

EXECUTE [uspAddStaff]
	@Username = N'TestStaff',
	@FirstName = N'John',
	@LastName = N'Doe',
	@Password = N'TestStaff@123',
	@Email = N'ImAnStaff@gmail.com',
	@FKRoleID = 1,
	@pBigResult = @AdminID OUTPUT,
	@pErrorMessage = @pErrorMessage OUTPUT

DECLARE @CategoryID BIGINT;
DECLARE @WorkID BIGINT;
DECLARE @ProductID BIGINT;

EXEC uspCreateCategory @Category = 'Comedy', @pErrorMessage = @pErrorMessage OUTPUT, @pBigResult = @CategoryID OUTPUT;
EXEC uspCreateCategory @Category = 'Scary', @pErrorMessage = @pErrorMessage OUTPUT, @pBigResult = @CategoryID OUTPUT;
EXEC uspCreateCategory @Category = 'Sad', @pErrorMessage = @pErrorMessage OUTPUT, @pBigResult = @CategoryID OUTPUT;

EXEC uspCreateWork 'Shrek', 1, @pErrorMessage OUTPUT, @WorkID OUTPUT;
EXEC uspCreateWork 'Scream', 2, @pErrorMessage OUTPUT, @WorkID OUTPUT;
EXEC uspCreateWork 'Marley and Me', 3, @pErrorMessage OUTPUT, @WorkID OUTPUT;
EXEC uspCreateWork 'Red Dog', 3, @pErrorMessage OUTPUT, @WorkID OUTPUT;

EXEC uspAddProduct @ProductName = 'Shrek 4K', @ProductDescription = 'Shrek movie in 4K', @ProductImage = 'https://cdn.discordapp.com/attachments/568660693033811999/917352227860013056/unknown.png', @RRP = '40.00', @SpecialPrice = null, @ProductStatus = 1, @FKMediaTypeID = 1, @FKWorkID = 1, @pBigResult = @pBigResult OUTPUT, @pErrorMessage = @pErrorMessage OUTPUT
EXEC uspAddProduct @ProductName = 'Marley and Me', @ProductDescription = 'Marley and me original movie', @ProductImage = 'https://cdn.discordapp.com/attachments/568660693033811999/922060689227522088/unknown.png', @RRP = '10.00', @SpecialPrice = '5.00', @ProductStatus = 1, @FKMediaTypeID = 1, @FKWorkID = 3, @pBigResult = @pBigResult OUTPUT, @pErrorMessage = @pErrorMessage OUTPUT
EXEC uspAddProduct @ProductName = 'Marley and Me Remaster', @ProductDescription = 'Marley and me remastered for dolby atmos', @ProductImage = 'https://cdn.discordapp.com/attachments/568660693033811999/922060098610814986/unknown.png', @RRP = '30.00', @SpecialPrice = null, @ProductStatus = 0, @FKMediaTypeID = 1, @FKWorkID = 3, @pBigResult = @pBigResult OUTPUT, @pErrorMessage = @pErrorMessage OUTPUT
EXEC uspAddProduct @ProductName = 'Shrek', @ProductDescription = 'Shrek movie', @ProductImage = 'https://cdn.discordapp.com/attachments/568660693033811999/922060270346592306/Z.png', @RRP = '10.00', @SpecialPrice = null,  @ProductStatus = 1, @FKMediaTypeID = 1, @FKWorkID = 1, @pBigResult = @pBigResult OUTPUT, @pErrorMessage = @pErrorMessage OUTPUT
EXEC uspAddProduct @ProductName = 'Red Dog', @ProductDescription = 'Original red dog movie', @ProductImage = 'https://cdn.discordapp.com/attachments/568660693033811999/922059815629504552/unknown.png', @RRP = '20.00', @SpecialPrice = '5.00', @ProductStatus = 1, @FKMediaTypeID = 1, @FKWorkID = 4, @pBigResult = @pBigResult OUTPUT, @pErrorMessage = @pErrorMessage OUTPUT
EXEC uspAddProduct @ProductName = 'Scream', @ProductDescription = 'Scream movie', @ProductImage = 'https://cdn.discordapp.com/attachments/568660693033811999/917353041387220992/unknown.png', @RRP = '10.00', @SpecialPrice = null, @ProductStatus = 1, @FKMediaTypeID = 2, @FKWorkID = 2, @pBigResult = @pBigResult OUTPUT, @pErrorMessage = @pErrorMessage OUTPUT

SELECT * FROM tblProduct;

EXEC uspAddSearchItem @CustomerID = 1, @SearchTerm = '4K', @WorkID = null, @CategoryID = null, @pBigResult = @pBigResult, @pErrorMessage = @pErrorMessage OUTPUT;
EXEC uspAddSearchItem @CustomerID = 1, @SearchTerm = 'Shrek', @WorkID = null, @CategoryID = null, @pBigResult = @pBigResult, @pErrorMessage = @pErrorMessage OUTPUT;
EXEC uspAddSearchItem @CustomerID = 2, @SearchTerm = null, @WorkID = 2, @CategoryID = null, @pBigResult = @pBigResult, @pErrorMessage = @pErrorMessage OUTPUT;

EXEC uspGetCustomerSearches @CustomerID = 1;

EXEC uspCreateOrder 1, 1, 10.00, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspCreateOrder 3, 1, 10.00, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspCreateOrder 4, 1, 10.00, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspCreateOrder 1, 2, 10.00, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspCreateOrder 2, 2, 10.00, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspCreateOrder 4, 2, 10.00, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspCreateOrder 4, 1, 10.00, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspCreateOrder 3, 1, 10.00, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspCreateOrder 4, 1, 10.00, @pBigResult OUTPUT, @pErrorMessage OUTPUT;

EXEC uspAddOrderItem 10, 10.00, '', 17287, 1, 2, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddOrderItem 1, null, '',  17287, 3, 2, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddOrderItem 100, 5.00, '',  17287, 4, 2, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddOrderItem 10, 7.00, '',  17287, 6, 2, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddOrderItem 1, 15.00, '',  17288, 5, 2, @pBigResult OUTPUT, @pErrorMessage OUTPUT;

EXEC uspAddCartItem 5, 1, 1, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddCartItem 1, 3, 1, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddCartItem 10, 6, 1, @pBigResult OUTPUT, @pErrorMessage OUTPUT;

EXEC uspGetUserCart 1, @pErrorMessage OUTPUT;

EXEC uspRetrieveOrders 1;
EXEC uspRetrieveOrderItems 17287;

EXEC uspAddStock 10, 1, 1, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock -10, 2, 1, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 10, 3, 1, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 1, 4, 1, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock -19, 1, 2, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 17, 2, 2, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 14, 3, 2, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock -10, 4, 2, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 10, 1, 3, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 0, 2, 3, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock -100, 3, 3, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 0, 4, 3, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 0, 1, 4, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 0, 2, 4, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 16, 3, 4, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 0, 4, 4, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 0, 1, 5, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 0, 2, 5, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 100, 3, 5, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 0, 4, 5, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 17, 1, 6, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 0, 2, 6, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 57, 3, 6, @pBigResult OUTPUT, @pErrorMessage OUTPUT;
EXEC uspAddStock 0, 4, 6, @pBigResult OUTPUT, @pErrorMessage OUTPUT;

EXEC uspRetrieveStock 2, 1;

SELECT * FROM tblOrder;
SELECT * FROM tblOrderItem;
SELECT * FROM tblStock;