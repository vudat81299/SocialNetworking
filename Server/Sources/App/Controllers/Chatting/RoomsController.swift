//
//  RoomsController.swift
//  App
//
//  Created by Vũ Quý Đạt  on 23/12/2020.
//

import Vapor
import Crypto

struct RoomsController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let roomsRoute = router.grouped("api", "rooms")
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = roomsRoute.grouped(basicAuthMiddleware)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = roomsRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthGroup.get(use: getAllRooms)
        tokenAuthGroup.get(Room.parameter, "messages", use: getMessagesOfRoomID)
        roomsRoute.delete(Room.parameter, use: deleteRoomID)
    }
    func deleteRoomID(_ req: Request) throws -> Future<HTTPStatus> {
        return try req
            .parameters
            .next(Room.self)
            .delete(on: req)
            .transform(to: .noContent)
    }
    
    func getMessagesOfRoomID(_ req: Request)
        throws -> Future<ResponseGetMessagesOfRoomID> {
            return try req
                .parameters.next(Room.self)
                .flatMap(to: ResponseGetMessagesOfRoomID.self) { room in
                    try room
                        .messages
                        .query(on: req)
                        .all()
                        .map(to: ResponseGetMessagesOfRoomID.self) { messages in
                            return ResponseGetMessagesOfRoomID(code: 1000, message: "Successful!", data: messages)
                        }
            }
    }
    
    func getAllRooms(_ req: Request) throws -> Future<ResponseGetAllRooms> {
        return Room
            .query(on: req)
            .decode(data: Room.self)
            .all()
            .map(to: ResponseGetAllRooms.self) { rooms in
                return ResponseGetAllRooms(code: 1000, message: "Successful!", data: rooms)
            }
    }
}
