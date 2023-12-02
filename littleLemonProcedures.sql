-- Creating the CancelBooking procedure
DELIMITER //

CREATE PROCEDURE CancelBooking(IN pBookingID INT)
BEGIN
    -- Deleting the booking record for the specified booking ID
    DELETE FROM Bookings
    WHERE BookingID = pBookingID;
    
    -- Output result
    SELECT CONCAT('Booking ID ', pBookingID, ' canceled successfully.') AS Status;
END //

DELIMITER ;

-- Creating the UpdateBooking procedure
DELIMITER //

CREATE PROCEDURE UpdateBooking(IN pBookingID INT, IN pBookingDate DATE)
BEGIN
    -- Update the booking date for the specified booking ID
    UPDATE Bookings
    SET BookingDate = pBookingDate
    WHERE BookingID = pBookingID;
    
    -- Output result
    SELECT CONCAT('Booking ID ', pBookingID, ' updated successfully.') AS Status;
END //

DELIMITER ;


-- Creating the AddBooking procedure
DELIMITER $$

CREATE PROCEDURE AddBooking(IN pBookingID INT, IN pCustomerID INT, IN pBookingDate DATE, IN pTableNumber INT)
BEGIN
    -- Inserting a new booking record
    INSERT INTO Bookings (BookingID, CustomerID, BookingDate, TableNo)
    VALUES (pBookingID, pCustomerID, pBookingDate, pTableNumber);
    
    -- Output result
    SELECT CONCAT('Booking ID ', pBookingID, ' added successfully.') AS Status;
END $$

DELIMITER ;

-- add valid booking
DELIMITER $$
CREATE PROCEDURE `AddValidBooking`(IN pBookingDate DATE, IN pTableNumber INT)
BEGIN
    DECLARE tableStatus VARCHAR(255);

    -- Start the transaction
    START TRANSACTION;

    -- Insert the new booking record
    INSERT INTO Bookings (BookingDate, TableNo, CustomerID)
    VALUES (pBookingDate, pTableNumber, NEW_CUSTOMER_ID);

    -- Check if the table is already booked on the given date
    SELECT CASE WHEN COUNT(*) > 0 THEN 'Booked' ELSE 'Available' END
    INTO tableStatus
    FROM Bookings
    WHERE BookingDate = pBookingDate AND TableNo = pTableNumber;

    -- If the table is already booked, rollback the transaction
    IF tableStatus = 'Booked' THEN
        ROLLBACK;
        SELECT 'Booking declined. Table is already booked.' AS Status;
    ELSE
        -- If the table is available, commit the transaction
        COMMIT;
        SELECT 'Booking successful.' AS Status;
    END IF;
END$$
DELIMITER ;

-- cancelorder
DELIMITER $$
CREATE  PROCEDURE `CancelOrder`(IN p_OrderID INT)
BEGIN
    -- Check if the order exists before deleting
    IF EXISTS (SELECT 1 FROM Orders WHERE OrderID = p_OrderID) THEN
        -- Delete the order
        DELETE FROM Orders WHERE OrderID = p_OrderID;
        SELECT 'Order '+ p_OrderID + ' is cancelled' AS Result;
    ELSE
        SELECT 'Order not found. No action taken.' AS Result;
    END IF;
END$$
DELIMITER ;

-- check booking
DELIMITER $$
CREATE PROCEDURE `CheckBooking`(IN pBookingDate DATE, IN pTableNumber INT)
BEGIN
    DECLARE tableStatus VARCHAR(255);

    -- Check if the table is already booked on the given date
    SELECT CASE WHEN COUNT(*) > 0 THEN 'Booked' ELSE 'Available' END
    INTO tableStatus
    FROM Bookings
    WHERE BookingDate = pBookingDate AND TableNo = pTableNo;

    -- Output the result
    SELECT tableStatus AS Status;
END$$
DELIMITER ;

-- get max order

DELIMITER $$
CREATE DEFINER=`meta`@`%` PROCEDURE `GetMaxQuantity`()
BEGIN
	SELECT MAX(OI.Quantity) AS 'Max Quantity Ordered'
	From Orders AS O
	INNER JOIN OrderItems AS OI
	ON O.OrderID = OI.OrderID;
END$$
DELIMITER ;
