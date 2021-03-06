import Vapor
import FluentMySQL

final class Comment: Codable {
    var id: Int?
    var content: String
    var date: String
    var time: String
    var postID: Post.ID
    var owner: User.ID
    
    init(content: String, date: String, time: String, postID: Post.ID, owner: User.ID) {
        self.content = content
        self.date = date
        self.time = time
        self.postID = postID
        self.owner = owner
    }
}

/// Uncomment to use instead of MySQLModel extension below, but which is using is better more than code in comment.
//extension Acronym: Model {
//    typealias  Database = SQLiteDatabase
//    typealias ID = Int
//    public static var idKey: IDKey = \Acronym.id
//}

//extension Acronym: MySQLModel {}
extension Comment: MySQLModel {
    typealias Database = MySQLDatabase
}
//extension Acronym: Migration {}
extension Comment: Content {}
extension Comment: Parameter {}

//MARK: Help to get users of acronyms.
extension Comment {
    var post: Parent<Comment, Post> {
        return parent(\.postID)
    }
    
//    // 1
//    var categories: Siblings<Post, Category, AcronymCategoryPivot> {
//        // 2
//        return siblings()
//    }/*
//     1. Add a computed property to Acronym to get an acronym’s categories. This returns Fluent’s generic Sibling type. It returns the siblings of an Acronym that are of type Category and held using the AcronymCategoryPivot.
//     2. Use Fluent’s siblings() function to retrieve all the categories. Fluent handles everything else.
//     */
}

//MARK: Foreign key constraints.
///     Using foreign key constraints has a number of benefits:
///     It ensures you can’t create acronyms with users that don’t exist.
///     You can’t delete users until you’ve deleted all their acronyms.
///     You can’t delete the user table until you’ve deleted the acronym table.
extension Comment: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.postID, to: \Post.id)
        }
    }
}



