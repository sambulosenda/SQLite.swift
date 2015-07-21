import XCTest
import SQLite

class ConnectionTests : SQLiteTestCase {

    override func setUp() {
        super.setUp()

        CreateUsersTable()
    }

    func test_init_withInMemory_returnsInMemoryConnection() {
        let db = try! Connection(.InMemory)
        XCTAssertEqual("", db.description)
    }

    func test_init_returnsInMemoryByDefault() {
        let db = try! Connection()
        XCTAssertEqual("", db.description)
    }

    func test_init_withTemporary_returnsTemporaryConnection() {
        let db = try! Connection(.Temporary)
        XCTAssertEqual("", db.description)
    }

    func test_init_withURI_returnsURIConnection() {
        let db = try! Connection(.URI("\(NSTemporaryDirectory())/SQLite.swift Tests.sqlite3"))
        XCTAssertEqual("\(NSTemporaryDirectory())/SQLite.swift Tests.sqlite3", db.description)
    }

    func test_init_withString_returnsURIConnection() {
        let db = try! Connection("\(NSTemporaryDirectory())/SQLite.swift Tests.sqlite3")
        XCTAssertEqual("\(NSTemporaryDirectory())/SQLite.swift Tests.sqlite3", db.description)
    }

    func test_readonly_returnsFalseOnReadWriteConnections() {
        XCTAssertFalse(db.readonly)
    }

    func test_readonly_returnsTrueOnReadOnlyConnections() {
        let db = try! Connection(readonly: true)
        XCTAssertTrue(db.readonly)
    }

    func test_lastInsertRowid_returnsNilOnNewConnections() {
        XCTAssert(db.lastInsertRowid == nil)
    }

    func test_lastInsertRowid_returnsLastIdAfterInserts() {
        InsertUser("alice")
        XCTAssertEqual(1, db.lastInsertRowid!)
    }

    func test_changes_returnsZeroOnNewConnections() {
        XCTAssertEqual(0, db.changes)
    }

    func test_changes_returnsNumberOfChanges() {
        InsertUser("alice")
        XCTAssertEqual(1, db.changes)
        InsertUser("betsy")
        XCTAssertEqual(1, db.changes)
    }

    func test_totalChanges_returnsTotalNumberOfChanges() {
        XCTAssertEqual(0, db.totalChanges)
        InsertUser("alice")
        XCTAssertEqual(1, db.totalChanges)
        InsertUser("betsy")
        XCTAssertEqual(2, db.totalChanges)
    }

    func test_prepare_preparesAndReturnsStatements() {
        _ = try! db.prepare("SELECT * FROM users WHERE admin = 0")
        _ = try! db.prepare("SELECT * FROM users WHERE admin = ?", 0)
        _ = try! db.prepare("SELECT * FROM users WHERE admin = ?", [0])
        _ = try! db.prepare("SELECT * FROM users WHERE admin = $admin", ["$admin": 0])
    }

    func test_run_preparesRunsAndReturnsStatements() {
        try! db.run("SELECT * FROM users WHERE admin = 0")
        try! db.run("SELECT * FROM users WHERE admin = ?", 0)
        try! db.run("SELECT * FROM users WHERE admin = ?", [0])
        try! db.run("SELECT * FROM users WHERE admin = $admin", ["$admin": 0])
        AssertSQL("SELECT * FROM users WHERE admin = 0", 4)
    }

    func test_scalar_preparesRunsAndReturnsScalarValues() {
        XCTAssertEqual(0, try! db.scalar("SELECT count(*) FROM users WHERE admin = 0") as! Int64)
        XCTAssertEqual(0, try! db.scalar("SELECT count(*) FROM users WHERE admin = ?", 0) as! Int64)
        XCTAssertEqual(0, try! db.scalar("SELECT count(*) FROM users WHERE admin = ?", [0]) as! Int64)
        XCTAssertEqual(0, try! db.scalar("SELECT count(*) FROM users WHERE admin = $admin", ["$admin": 0]) as! Int64)
        AssertSQL("SELECT count(*) FROM users WHERE admin = 0", 4)
    }

    func test_transaction_beginsAndCommitsTransactions() {
        let stmt = try! db.prepare("INSERT INTO users (email, admin) VALUES (?, ?)", "alice@example.com", 1)

        try! db.transaction {
            try stmt.run()
        }

        AssertSQL("BEGIN DEFERRED TRANSACTION")
        AssertSQL("INSERT INTO users (email, admin) VALUES ('alice@example.com', 1)")
        AssertSQL("COMMIT TRANSACTION")
        AssertSQL("ROLLBACK TRANSACTION", 0)
    }

    func test_transaction_beginsAndRollsTransactionsBack() {
        let stmt = try! db.run("INSERT INTO users (email, admin) VALUES (?, ?)", "alice@example.com", 1)

        do {
            try db.transaction {
                try stmt.run()
            }
        } catch {
        }

        AssertSQL("BEGIN DEFERRED TRANSACTION")
        AssertSQL("INSERT INTO users (email, admin) VALUES ('alice@example.com', 1)", 2)
        AssertSQL("ROLLBACK TRANSACTION")
        AssertSQL("COMMIT TRANSACTION", 0)
    }

}
