// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Bookstore {

    struct Book {
        string title;
        string author;
        string publication;
        uint id;
        bool available;
    }

    Book[] books;

    mapping(uint => bool) available;

    address owner;
    uint nextBookId = 0; 

    constructor() {owner=msg.sender;}

    modifier onlyOwner() {
        require(msg.sender==owner, "Only the owner can use this");
         _;
    }


    // this function can add a book and only accessible by gavin
    function addBook(string memory _title, string memory _author, string memory _publication) public onlyOwner {
        
        //increment nextBookId
        nextBookId++;
       
        //create new book entry
        Book memory newBook = Book({
            title: _title,
            author: _author,
            publication: _publication,
            id: nextBookId,
            available: true
        });

        //push new book
        books.push(newBook);
    }


    // this function makes book unavailable and only accessible by gavin
    function removeBook(uint _id) public onlyOwner {
        require(_id > 0 && _id <= books.length, "Invalid book ID");
        
        uint _tempId = _id - 1; 
        books[_tempId].available = false;
    }


    // this function modifies the book details and only accessible by gavin
    function updateDetails(uint _id, string memory _title, string memory _author, string memory _publication, bool _available) public onlyOwner {
        require(_id > 0 && _id <= books.length, "Invalid book ID");

        uint _tempId = _id - 1; 

        Book storage bookUpdate = books[_tempId];

            //this checks all fields to see if changes need to be made
            //if no changes need to be made, you can enter "" to keep previous entry
            if(bytes(_title).length > 0) {
            bookUpdate.title = _title;
            }
            if(bytes(_author).length > 0) {
            bookUpdate.author = _author;
            }
            if(bytes(_publication).length > 0){
            bookUpdate.publication = _publication;
            }
            if(_available != bookUpdate.available) {
            bookUpdate.available = _available;
            }   
    }


    // this function returns the ID of all books with given title
    function findBookByTitle(string memory _title) public view returns (uint[] memory)  {
        
        uint[] memory _matchingIDs;

        for(uint i=0; i<books.length; i++) {
            if(keccak256(bytes(books[i].title)) == keccak256(bytes(_title))) {
                if (msg.sender == owner) {
                    uint[] memory _temp = new uint[](_matchingIDs.length + 1);
                    
                    for (uint j=0; j<_matchingIDs.length; j++) {
                        _temp[j] = _matchingIDs[j];
                    }
                    _temp[_temp.length - 1] = books[i].id;
                    _matchingIDs = _temp;

                } else if (books[i].available == true) {
                    uint[] memory _temp = new uint[](_matchingIDs.length + 1);
                    
                    for (uint j=0; j<_matchingIDs.length; j++) {
                        _temp[j] = _matchingIDs[j];
                    }
                    _temp[_temp.length - 1] = books[i].id;
                    _matchingIDs = _temp; 
                }    
            }
        }
        return _matchingIDs;
    }


    // this function returns the ID of all books with given publication
    function findAllBooksOfPublication (string memory _publication) public view returns (uint[] memory)  {
        
        uint[] memory _matchingPubs;

        for(uint i=0; i<books.length; i++) {
            if(keccak256(bytes(books[i].publication)) == keccak256(bytes(_publication))) {
                if (msg.sender == owner) {
                    uint[] memory _temp = new uint[](_matchingPubs.length + 1);
                    
                    for (uint j=0; j<_matchingPubs.length; j++) {
                        _temp[j] = _matchingPubs[j];
                    }
                    _temp[_temp.length - 1] = books[i].id;
                    _matchingPubs = _temp;

                } else if (books[i].available == true) {
                    uint[] memory _temp = new uint[](_matchingPubs.length + 1);
                    
                    for (uint j=0; j<_matchingPubs.length; j++) {
                        _temp[j] = _matchingPubs[j];
                    }
                    _temp[_temp.length - 1] = books[i].id;
                    _matchingPubs = _temp; 
                }    
            }
        }
        return _matchingPubs;
    }



    // this function returns the ID of all books with given author
    function findAllBooksOfAuthor (string memory _author) public view returns (uint[] memory)  {
        
        uint[] memory _matchingAuthors;

        for(uint i=0; i<books.length; i++) {
            if(keccak256(bytes(books[i].author)) == keccak256(bytes(_author))) {
                if (msg.sender == owner) {
                    uint[] memory _temp = new uint[](_matchingAuthors.length + 1);
                    
                    for (uint j=0; j<_matchingAuthors.length; j++) {
                        _temp[j] = _matchingAuthors[j];
                    }
                    _temp[_temp.length - 1] = books[i].id;
                    _matchingAuthors = _temp;

                } else if (books[i].available == true) {
                    uint[] memory _temp = new uint[](_matchingAuthors.length + 1);
                    
                    for (uint j=0; j<_matchingAuthors.length; j++) {
                        _temp[j] = _matchingAuthors[j];
                    }
                    _temp[_temp.length - 1] = books[i].id;
                    _matchingAuthors = _temp; 
                }    
            }
        }
        return _matchingAuthors;
    }


    // this function returns all the details of book with given ID
    function getDetailsById(uint _id) public view returns (string memory _title, string memory _author, string memory _publication, bool _available)  {
        require(_id > 0 && _id <= books.length, "Invalid book ID");
        
        uint _tempId = _id-1;

        Book memory selectedBook = books[_tempId];
        
        if (msg.sender == owner || selectedBook.available) {
            return (selectedBook.title, selectedBook.author, selectedBook.publication, selectedBook.available);
        } else {
            return ("", "", "", false);
        }
    }
}