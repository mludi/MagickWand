import Foundation
import XCTest
@testable import MagickWand

func open(file: String, ofType type: String) -> Data? {
    var fileData: Data?
    #if os(Linux)
        fileData = try? Data(contentsOf: URL(fileURLWithPath: "\(file).\(type)"))
    #else
        if let path = Bundle(for: MagickWandTests.self).path(forResource: file, ofType: type) {
            fileData = try? Data(contentsOf: URL(fileURLWithPath: path))
        } else {
            fileData = try? Data(contentsOf: URL(fileURLWithPath: "\(file).\(type)"))
        }
    #endif
    
    return fileData
}


class MagickWandTests: XCTestCase {
    
    func testGenesisTerminus() {
        XCTAssertFalse(MagickWand.isInstantiated)
        
        MagickWand.genesis()
        
        XCTAssertTrue(MagickWand.isInstantiated)
        
        let url = URL(fileURLWithPath: "img.png")
        print(url)
        print(url.absoluteString)
        
        let data = ImageWand(color: "red")?.data
        do {
            print(data)
        try data!.write(to: url)
        } catch {
            print(error)
        }
        
        MagickWand.terminus()
        
        XCTAssertFalse(MagickWand.isInstantiated)
        
        
    }


    static var allTests : [(String, (MagickWandTests) -> () throws -> Void)] {
        return [
            ("Test Genesis - Terminus", testGenesisTerminus),
        ]
    }
}
