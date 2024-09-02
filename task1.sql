-- Create the database
drop database db_LibraryManagement;
CREATE DATABASE IF NOT EXISTS db_LibraryManagement;
USE db_LibraryManagement;

-- ======================= TABLES ========================

-- Publisher table
CREATE TABLE tbl_publisher (
    publisher_PublisherName VARCHAR(100) PRIMARY KEY NOT NULL,
    publisher_PublisherAddress VARCHAR(200) NOT NULL,
    publisher_PublisherPhone VARCHAR(50) NOT NULL
);

-- Book table
CREATE TABLE tbl_book (
    book_BookID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    book_Title VARCHAR(100) NOT NULL,
    book_PublisherName VARCHAR(100) NOT NULL,
    FOREIGN KEY (book_PublisherName) REFERENCES tbl_publisher(publisher_PublisherName)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Library branch table
CREATE TABLE tbl_library_branch (
    library_branch_BranchID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    library_branch_BranchName VARCHAR(100) NOT NULL,
    library_branch_BranchAddress VARCHAR(200) NOT NULL
);

-- Borrower table
CREATE TABLE tbl_borrower (
    borrower_CardNo INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    borrower_BorrowerName VARCHAR(100) NOT NULL,
    borrower_BorrowerAddress VARCHAR(200) NOT NULL,
    borrower_BorrowerPhone VARCHAR(50) NOT NULL
);

-- Book loans table
CREATE TABLE tbl_book_loans (
    book_loans_LoansID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    book_loans_BookID INT NOT NULL,
    book_loans_BranchID INT NOT NULL,
    book_loans_CardNo INT NOT NULL,
    book_loans_DateOut DATE NOT NULL,
    book_loans_DueDate DATE NOT NULL,
    FOREIGN KEY (book_loans_BookID) REFERENCES tbl_book(book_BookID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (book_loans_BranchID) REFERENCES tbl_library_branch(library_branch_BranchID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (book_loans_CardNo) REFERENCES tbl_borrower(borrower_CardNo)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Book copies table
CREATE TABLE tbl_book_copies (
    book_copies_CopiesID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    book_copies_BookID INT NOT NULL,
    book_copies_BranchID INT NOT NULL,
    book_copies_No_Of_Copies INT NOT NULL,
    FOREIGN KEY (book_copies_BookID) REFERENCES tbl_book(book_BookID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (book_copies_BranchID) REFERENCES tbl_library_branch(library_branch_BranchID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Book authors table
CREATE TABLE tbl_book_authors (
    book_authors_AuthorID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    book_authors_BookID INT NOT NULL,
    book_authors_AuthorName VARCHAR(50) NOT NULL,
    FOREIGN KEY (book_authors_BookID) REFERENCES tbl_book(book_BookID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- Insert into publisher table with IGNORE to skip duplicates
INSERT IGNORE INTO tbl_publisher (publisher_PublisherName, publisher_PublisherAddress, publisher_PublisherPhone)
VALUES
    ('DAW Books', '375 Hudson Street, New York, NY 10014', '212-366-2000'),
    ('Viking', '375 Hudson Street, New York, NY 10014', '212-366-2000'),
    ('Picador USA', '175 Fifth Avenue, New York, NY 10010', '646-307-5745');

-- Insert into book table with IGNORE to skip duplicates
INSERT IGNORE INTO tbl_book (book_Title, book_PublisherName)
VALUES 
    ('The Name of the Wind', 'DAW Books'),
    ('It', 'Viking'),
    ('The Lost Tribe', 'Picador USA');

-- Insert into library branch table with IGNORE to skip duplicates
INSERT IGNORE INTO tbl_library_branch (library_branch_BranchName, library_branch_BranchAddress)
VALUES
    ('Sharpstown', '32 Corner Road, New York, NY 10012'),
    ('Central', '491 3rd Street, New York, NY 10014'),
    ('Ann Arbor', '101 South University, Ann Arbor, MI 48104');

-- Insert into borrower table with IGNORE to skip duplicates
INSERT IGNORE INTO tbl_borrower (borrower_BorrowerName, borrower_BorrowerAddress, borrower_BorrowerPhone)
VALUES
    ('Joe Smith', '1321 4th Street, New York, NY 10014', '212-312-1234'),
    ('Jane Smith', '1321 4th Street, New York, NY 10014', '212-931-4124'),
    ('Michael Horford', '653 Glen Avenue, Ann Arbor, MI 48104');

-- Insert into book_copies table with IGNORE to skip duplicates
INSERT IGNORE INTO tbl_book_copies (book_copies_BookID, book_copies_BranchID, book_copies_No_Of_Copies)
VALUES
    (1, 1, 5),
    (2, 1, 5),
    (3, 3, 5);

-- Insert into book_loans table with IGNORE to skip duplicates
INSERT IGNORE INTO tbl_book_loans (book_loans_BookID, book_loans_BranchID, book_loans_CardNo, book_loans_DateOut, book_loans_DueDate)
VALUES
    (1, 1, 1, '2018-01-01', '2018-02-02'),
    (2, 1, 1, '2018-01-01', '2018-02-02'),
    (1, 3, 3, '2018-02-02', '2018-03-02');

-- Insert into book_authors table with IGNORE to skip duplicates
INSERT IGNORE INTO tbl_book_authors (book_authors_BookID, book_authors_AuthorName)
VALUES
    (1, 'Patrick Rothfuss'),
    (2, 'Stephen King'),
    (3, 'Mark Lee');

-- Set delimiter
DELIMITER //

-- Procedure for book copies at Sharpstown
CREATE PROCEDURE bookCopiesAtAllSharpstown (
    IN bookTitle VARCHAR(70), 
    IN branchName VARCHAR(70)
)
BEGIN
    SELECT 
        copies.book_copies_BranchID AS BranchID, 
        branch.library_branch_BranchName AS BranchName,
        copies.book_copies_No_Of_Copies AS NumberOfCopies,
        book.book_Title AS BookTitle
    FROM tbl_book_copies AS copies
    INNER JOIN tbl_book AS book ON copies.book_copies_BookID = book.book_BookID
    INNER JOIN tbl_library_branch AS branch ON copies.book_copies_BranchID = branch.library_branch_BranchID
    WHERE book.book_Title = bookTitle AND branch.library_branch_BranchName = branchName;
END //

-- Execute the procedure
CALL bookCopiesAtAllSharpstown('The Lost Tribe', 'Sharpstown');

-- Procedure for book copies at all branches
CREATE PROCEDURE bookCopiesAtAllBranches (
    IN bookTitle VARCHAR(70)
)
BEGIN
    SELECT 
        copies.book_copies_BranchID AS BranchID, 
        branch.library_branch_BranchName AS BranchName,
        copies.book_copies_No_Of_Copies AS NumberOfCopies,
        book.book_Title AS BookTitle
    FROM tbl_book_copies AS copies
    INNER JOIN tbl_book AS book ON copies.book_copies_BookID = book.book_BookID
    INNER JOIN tbl_library_branch AS branch ON copies.book_copies_BranchID = branch.library_branch_BranchID
    WHERE book.book_Title = bookTitle;
END //

-- Execute the procedure
CALL bookCopiesAtAllBranches('The Lost Tribe');

-- Procedure for borrowers with no loans
CREATE PROCEDURE NoLoans()
BEGIN
    SELECT borrower_BorrowerName 
    FROM tbl_borrower
    WHERE NOT EXISTS (
        SELECT * FROM tbl_book_loans
        WHERE book_loans_CardNo = borrower_CardNo
    );
END //

-- Execute the procedure
CALL NoLoans();

-- Procedure for loaners info
DELIMITER //

CREATE PROCEDURE LoanersInfo(
    IN LibraryBranchName VARCHAR(50) 
)
BEGIN
    -- Declare a variable to store the due date
    DECLARE DueDate DATE;
    
    -- Set DueDate to the current date
    SET DueDate = CURDATE();

    SELECT 
        Branch.library_branch_BranchName AS Branch_Name,  
        Book.book_Title AS Book_Name,
        Borrower.borrower_BorrowerName AS Borrower_Name, 
        Borrower.borrower_BorrowerAddress AS Borrower_Address,
        Loans.book_loans_DateOut AS Date_Out, 
        Loans.book_loans_DueDate AS Due_Date
    FROM tbl_book_loans AS Loans
    INNER JOIN tbl_book AS Book ON Loans.book_loans_BookID = Book.book_BookID
    INNER JOIN tbl_borrower AS Borrower ON Loans.book_loans_CardNo = Borrower.borrower_CardNo
    INNER JOIN tbl_library_branch AS Branch ON Loans.book_loans_BranchID = Branch.library_branch_BranchID
    WHERE Loans.book_loans_DueDate = DueDate 
      AND Branch.library_branch_BranchName = LibraryBranchName;
END //

DELIMITER ;

-- To call the procedure with a specific branch name, use:
CALL LoanersInfo('Sharpstown');

DELIMITER //

CREATE PROCEDURE TotalLoansPerBranch()
BEGIN
    SELECT  
        Branch.library_branch_BranchName AS Branch_Name, 
        COUNT(Loans.book_loans_BranchID) AS Total_Loans
    FROM tbl_book_loans AS Loans
    INNER JOIN tbl_library_branch AS Branch ON Loans.book_loans_BranchID = Branch.library_branch_BranchID
    GROUP BY Branch.library_branch_BranchName;
END //

DELIMITER ;

CALL TotalLoansPerBranch();
DELIMITER //

DELIMITER //

CREATE PROCEDURE BooksLoanedOut(
    IN BooksCheckedOut INT
)
BEGIN
    -- Declare a variable to hold the default value
    DECLARE DefaultBooksCheckedOut INT DEFAULT 5;

    -- Use the provided parameter or default value if NULL
    SET BooksCheckedOut = IFNULL(BooksCheckedOut, DefaultBooksCheckedOut);

    SELECT 
        Borrower.borrower_BorrowerName AS Borrower_Name, 
        Borrower.borrower_BorrowerAddress AS Borrower_Address,
        COUNT(Loans.book_loans_CardNo) AS Books_Checked_Out
    FROM tbl_book_loans AS Loans
    INNER JOIN tbl_borrower AS Borrower ON Loans.book_loans_CardNo = Borrower.borrower_CardNo
    GROUP BY Borrower.borrower_BorrowerName, Borrower.borrower_BorrowerAddress
    HAVING COUNT(Loans.book_loans_CardNo) >= BooksCheckedOut;
END //

DELIMITER ;

-- To call the procedure with the default value (5) use:
CALL BooksLoanedOut(NULL);

-- To call the procedure with a specific number, e.g., 6 use:
CALL BooksLoanedOut(6);

DELIMITER //

CREATE PROCEDURE BookbyAuthorandBranch(
    IN BranchName VARCHAR(50),
    IN AuthorName VARCHAR(50)
)
BEGIN
    -- Set default values if parameters are NULL
    SET BranchName = IFNULL(BranchName, 'Central');
    SET AuthorName = IFNULL(AuthorName, 'Stephen King');

    SELECT 
        Branch.library_branch_BranchName AS Branch_Name, 
        Book.book_Title AS Title, 
        Copies.book_copies_No_Of_Copies AS Number_of_Copies
    FROM tbl_book_authors AS Authors
    INNER JOIN tbl_book AS Book ON Authors.book_authors_BookID = Book.book_BookID
    INNER JOIN tbl_book_copies AS Copies ON Authors.book_authors_BookID = Copies.book_copies_BookID
    INNER JOIN tbl_library_branch AS Branch ON Copies.book_copies_BranchID = Branch.library_branch_BranchID
    WHERE Branch.library_branch_BranchName = BranchName 
      AND Authors.book_authors_AuthorName = AuthorName;
END //

DELIMITER ;

-- To call the procedure using default values:
CALL BookbyAuthorandBranch(NULL, NULL);

-- To call the procedure with specific parameters:
CALL BookbyAuthorandBranch('Central', 'Stephen King');

