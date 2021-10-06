import XCTest
@testable import DeltaDNA

class DDNATransactionTests: XCTestCase {
    
    var productsReceived: DDNAProduct! = DDNAProduct()
    var productsSpent: DDNAProduct! = DDNAProduct()    
    var transaction: DDNATransaction!

    func test_createTransaction_dictionaryReturnsExpectedResult() throws {
        transaction = DDNATransaction(name: "shop", type: "weapon", productsReceived: productsReceived, productsSpent: productsSpent)
        
        let result: [String : Any] = ["eventName" : "transaction",
                           "eventParams" : [
                            "transactionName" : "shop",
                            "transactionType" : "weapon",
                            "productsReceived" : [:],
                            "productsSpent" : [:]
                           ]]
        
        XCTAssertEqual(transaction.dictionary() as NSDictionary, result as NSDictionary)
    }

    func test_createTransation_includeOptionalValues_dictionaryReturnsExpectedResult() throws {
        transaction = DDNATransaction(name: "shop", type: "weapon", productsReceived: productsReceived, productsSpent: productsSpent)
        transaction.setTransactionId("12345")
        transaction.setServer("local")
        transaction.setReceipt("123223----***5433")
        transaction.setTransactorId("abcde")
        transaction.setProductId("5678-4332")
        
        let result: [String : Any] = ["eventName" : "transaction",
                           "eventParams" : [
                            "transactionName" : "shop",
                            "transactionType" : "weapon",
                            "productsReceived" : [:],
                            "productsSpent" : [:],
                            "transactionID": "12345",
                            "transactionServer": "local",
                            "transactionReceipt": "123223----***5433",
                            "transactorID": "abcde",
                            "productID": "5678-4332"
                           ]]
        
        XCTAssertEqual(transaction.dictionary() as NSDictionary, result as NSDictionary)
    }
    
    func test_nameIsNil_throwInvalidArgumentException() throws {
        do {
            try ObjC.catchException {
                let _ = DDNATransaction(name: nil, type: "weapon", productsReceived: self.productsReceived, productsSpent: self.productsSpent)
            }
        }
        catch {
            let error = error as NSError
            XCTAssertNotNil(error)
            XCTAssertEqual(error.domain, NSExceptionName.invalidArgumentException.rawValue)
            XCTAssertEqual(error.localizedFailureReason, "name cannot be nil or empty")
            return
        }
        XCTFail()
    }
    
    func test_nameIsEmptyString_throwInvalidArgumentException() throws {
        do {
            try ObjC.catchException {
                let _ = DDNATransaction(name: "", type: "weapon", productsReceived: self.productsReceived, productsSpent: self.productsSpent)
            }
        }
        catch {
            let error = error as NSError
            XCTAssertNotNil(error)
            XCTAssertEqual(error.domain, NSExceptionName.invalidArgumentException.rawValue)
            XCTAssertEqual(error.localizedFailureReason, "name cannot be nil or empty")
            return
        }
        XCTFail()
    }
    
    func test_typeIsNil_throwInvalidArgumentException() throws {
        do {
            try ObjC.catchException {
                let _ = DDNATransaction(name: "shop", type: nil, productsReceived: self.productsReceived, productsSpent: self.productsSpent)
            }
        }
        catch {
            let error = error as NSError
            XCTAssertNotNil(error)
            XCTAssertEqual(error.domain, NSExceptionName.invalidArgumentException.rawValue)
            XCTAssertEqual(error.localizedFailureReason, "type cannot be nil or empty")
            return
        }
        XCTFail()
    }
    
    func test_typeIsEmptyString_throwInvalidArgumentException() throws {
        do {
            try ObjC.catchException {
                let _ = DDNATransaction(name: "shop", type: "", productsReceived: self.productsReceived, productsSpent: self.productsSpent)
            }
        }
        catch {
            let error = error as NSError
            XCTAssertNotNil(error)
            XCTAssertEqual(error.domain, NSExceptionName.invalidArgumentException.rawValue)
            XCTAssertEqual(error.localizedFailureReason, "type cannot be nil or empty")
            return
        }
        XCTFail()
    }
    
    func test_productsReceivedIsNil_throwInvalidArgumentException() throws {
        do {
            try ObjC.catchException {
                let _ = DDNATransaction(name: "shop", type: "weapon", productsReceived: nil, productsSpent: self.productsSpent)
            }
        }
        catch {
            let error = error as NSError
            XCTAssertNotNil(error)
            XCTAssertEqual(error.domain, NSExceptionName.invalidArgumentException.rawValue)
            XCTAssertEqual(error.localizedFailureReason, "productsReceived cannot be nil")
            return
        }
        XCTFail()
    }
    
    func test_productsSpentIsEmptyString_throwInvalidArgumentException() throws {
        do {
            try ObjC.catchException {
                let _ = DDNATransaction(name: "shop", type: "weapon", productsReceived: self.productsReceived, productsSpent: nil)
            }
        }
        catch {
            let error = error as NSError
            XCTAssertNotNil(error)
            XCTAssertEqual(error.domain, NSExceptionName.invalidArgumentException.rawValue)
            XCTAssertEqual(error.localizedFailureReason, "productsSpent cannot be nil")
            return
        }
        XCTFail()
    }


}
