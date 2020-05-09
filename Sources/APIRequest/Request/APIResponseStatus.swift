/*
*  Copyright (C) 2020 Groupe MINASTE
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with this program; if not, write to the Free Software Foundation, Inc.,
* 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*
*/

import Foundation

public enum APIResponseStatus {
    
    // 200 OK
    case ok
    
    // 201 Created
    case created
    
    // 400 Bad Request
    case badRequest
    
    // 401 Unauthorized
    case unauthorized
    
    // 403 Forbidden
    case forbidden
    
    // 404 Not Found
    case notFound
    
    // Error while creating the request
    case error
    
    // Device is offline
    case offline
    
    // Device is loading ressource
    case loading
    
    /// Return the status associated with the HTTP status code, or error if the status is not registered
    /// - Parameter code: The HTTP status code
    /// - Returns: The APIResponseStatus
    public static func status(forCode code: Int) -> APIResponseStatus {
        switch code {
        case 200:
            return .ok
        case 201:
            return .created
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        default:
            return .error
        }
    }
    
}
