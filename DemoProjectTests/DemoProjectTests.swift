//
//  DemoProjectTests.swift
//  DemoProjectTests
//
//  Created by Thanh Quang on 31/5/25.
//

import Testing
@testable import DemoProject

struct DemoProjectTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        var o: O? = O()
        o?.doSth()
        var temp = 123
        let callback = {
            o?.doSth()
        }
    //    Task {
    //        callback()
    //    }
        callback()
    }

}


class O {
    init() {
        
    }
    
    func doSth() {
        print("hihihi")
    }
}

func doSomething() {
   
    
}
