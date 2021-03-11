import XCTest
@testable import DeltaDNA

class DDNAProductTests: XCTestCase {
    var product: DDNAProduct!

    override func setUpWithError() throws {
        product = DDNAProduct()
    }
    
    func test_addItemNamesWithCorrectValues_generateCorrectDictionary() throws {
        product.addItemName("grow", type: "potion", amount: 2)
        product.addItemName("shrink", type: "potion", amount: 1)
        
        let result: [String : Any] = ["items" : [
                                        ["item" :
                                            ["itemName" : "grow",
                                             "itemType" : "potion",
                                             "itemAmount" : 2
                                            ]
                                        ],
                                        [ "item" :
                                            [ "itemName" : "shrink",
                                              "itemType" : "potion",
                                              "itemAmount" : 1
                                            ]
                                        ] ] ]
        XCTAssertEqual(product.dictionary() as NSDictionary, result as NSDictionary)
    }
    
    func test_addVirtualCurrencyWithCorrectValues_generateCorrectDictionary() throws {
        product.addVirtualCurrencyName("VIP Points", type: "GRIND", amount: 50)
        product.addVirtualCurrencyName("Gold Coins", type: "In-Game", amount: 100)
        
        let result: NSDictionary = [
            "virtualCurrencies": [
                [
                    "virtualCurrency": [
                        "virtualCurrencyName": "VIP Points",
                        "virtualCurrencyType": "GRIND",
                        "virtualCurrencyAmount": 50
                    ]
                ],
                [
                    "virtualCurrency": [
                        "virtualCurrencyName": "Gold Coins",
                        "virtualCurrencyType": "In-Game",
                        "virtualCurrencyAmount": 100
                    ]
                ]
            ]
        ]
        
        XCTAssertEqual(product.dictionary() as NSDictionary, result)
    }
    
    func test_setRealCurrency_generateCorrectDictionary() throws {
        product.setRealCurrencyType("USD", amount: 15)
        
        let result: NSDictionary = [
            "realCurrency": [
                "realCurrencyType": "USD",
                "realCurrencyAmount": 15
            ]
        ]
        
        XCTAssertEqual(product.dictionary() as NSDictionary, result)
    }
    
    func test_nameIsNil_throwInvalidArgumentException() throws {
        do {
            try ObjC.catchException {
                self.product.addItemName("", type: "potion", amount: 2)
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
                self.product.addItemName("", type: "potion", amount: 2)
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
                self.product.addItemName("name", type: nil, amount: 2)
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
                self.product.addItemName("name", type: "", amount: 2)
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
    
    func test_virtualCurrencyNameIsNil_throwInvalidArgumentException() throws {
        do {
            try ObjC.catchException {
                self.product.addVirtualCurrencyName(nil, type: "GRIND", amount: 50)
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
    
    func test_virtualCurrencyNameIsEmptyString_throwInvalidArgumentException() throws {
        do {
            try ObjC.catchException {
                self.product.addVirtualCurrencyName("", type: "GRIND", amount: 50)
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
    
    func test_virtualCurrencyTypeIsNil_throwInvalidArgumentException() throws {
        do {
            try ObjC.catchException {
                self.product.addVirtualCurrencyName("VIP Points", type: "", amount: 50)
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
    
    func test_virtualCurrencyTypeIsEmptyString_throwInvalidArgumentException() throws {
        do {
            try ObjC.catchException {
                self.product.addVirtualCurrencyName("VIP Points", type: "", amount: 50)
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
    
    func test_realCurrencyTypeIsNil_throwInvalidArgumentException() throws {
        do {
            try ObjC.catchException {
                self.product.setRealCurrencyType(nil, amount: 50)
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
    
    func test_realCurrencyTypeIsEmptyString_throwInvalidArgumentException() throws {
        do {
            try ObjC.catchException {
                self.product.setRealCurrencyType("", amount: 50)
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
    
    func test_currencyConvertionValueIsNil_throwInvalidArgumentException() throws {
        do {
            try ObjC.catchException {
                DDNAProduct.convertCurrencyCode("EUR", value: nil)
            }
        }
        catch {
            let error = error as NSError
            XCTAssertNotNil(error)
            XCTAssertEqual(error.domain, NSExceptionName.invalidArgumentException.rawValue)
            XCTAssertEqual(error.localizedFailureReason, "value cannot be nil")
            return
        }
        XCTFail()
    }
    
    func test_currencyConvertionCodeIsNil_throwInvalidArgumentException() throws {
        do {
            try ObjC.catchException {
                DDNAProduct.convertCurrencyCode(nil, value: 1.23)
            }
        }
        catch {
            let error = error as NSError
            XCTAssertNotNil(error)
            XCTAssertEqual(error.domain, NSExceptionName.invalidArgumentException.rawValue)
            XCTAssertEqual(error.localizedFailureReason, "code cannot be nil or empty")
            return
        }
        XCTFail()
    }
    
    func test_currencyConvertionCodeIsEmptyString_throwInvalidArgumentException() throws {
        do {
            try ObjC.catchException {
                DDNAProduct.convertCurrencyCode("", value: 1.23)
            }
        }
        catch {
            let error = error as NSError
            XCTAssertNotNil(error)
            XCTAssertEqual(error.domain, NSExceptionName.invalidArgumentException.rawValue)
            XCTAssertEqual(error.localizedFailureReason, "code cannot be nil or empty")
            return
        }
        XCTFail()
    }
    
    func test_currencyConvertionCodeIsInvalid_returnValueIsZero() throws {
        do {
            try ObjC.catchException {
                let value = DDNAProduct.convertCurrencyCode("ZZZ", value: 1.23)
                XCTAssertEqual(value, 0)
            }
        }
        catch {
            XCTFail()
        }
    }
    
    func test_currencyConvertionValueIsZero_returnValueIsZero() throws {
        do {
            try ObjC.catchException {
                let value: Int = DDNAProduct.convertCurrencyCode("EUR", value: 0)
                XCTAssertEqual(value, 0)
            }
        }
        catch {
            XCTFail()
        }
    }
    
    func test_currencyConvertionValueHasTooHighNumberOfDecimalPoints_returnFlooredValue() throws {
        do {
            try ObjC.catchException {
                let value: Int = DDNAProduct.convertCurrencyCode("EUR", value: NSDecimalNumber(string: "1.235"))
                XCTAssertEqual(value as NSNumber, NSNumber(value: 123))
            }
        }
        catch {
            XCTFail()
        }
    }
    
    private struct TestCase {
        let code: String
        let value: String
        let expectedResult: Int
    }
    
    func test_currencyConvertionWithCorrectCodesAndValues_returnCorrectValues() throws {
        
        let tests: [TestCase] = [TestCase(code: "EUR", value: "1.23", expectedResult: 123),
                                 TestCase(code: "JPY", value: "123", expectedResult: 123),
                                 TestCase(code: "KWD", value: "1.234", expectedResult: 1234)]
        
        for test in tests {
            do {
                try ObjC.catchException {
                    let value: Int = DDNAProduct.convertCurrencyCode(test.code, value: NSDecimalNumber(string: test.value))
                    XCTAssertEqual(value as NSNumber, NSNumber(value: test.expectedResult))
                }
            }
            catch {
                XCTFail()
            }
        }
    }
}
