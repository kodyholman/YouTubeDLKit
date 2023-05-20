//
//  YTError.swift
//  
//
//  Created by Dani on 3/5/23.
//

import Foundation

public enum YTError {
    case invalidURL(context: Context = Context())
    case parsingError(context: Context = Context())
    case unavailableFormatAndQuality(format: YTFileFormat, quality: YTVideoFormat.Quality, context: Context = Context())
    case downloadError(context: Context = Context())
    case downloadCancelled(context: Context = Context())
    case unknown(context: Context = Context())
}

extension YTError {
    var context: Context {
        switch self {
        case .invalidURL(let context):
            return context
        case .parsingError(let context):
            return context
        case .unavailableFormatAndQuality(_, _, let context):
            return context
        case .downloadError(let context):
            return context
        case .downloadCancelled(let context):
            return context
        case .unknown(let context):
            return context
        }
    }
}

extension YTError {
    public struct Context {
        public var underlyingError: Error?
        private var message: String?
        public var description: String? {
            underlyingError?.localizedDescription ?? message
        }
        
        public init() {}
        
        public init(underlyingError: Error?) {
            self.underlyingError = underlyingError
        }
        
        public init(message: String?) {
            self.message = message
        }
    }
}

extension YTError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The input URL is not a valid YouTube video."
        case .parsingError:
            return "An error occurred while parsing the API response."
        case .unavailableFormatAndQuality(let fileFormat, let quality, _):
            return "The format '\(fileFormat.rawValue)' with quality '\(quality.rawValue)' is not available for this video."
        case .downloadError:
            return "An error occurred while downloading a video."
        case .downloadCancelled:
            return "The download was cancelled."
        case .unknown:
            return "An unknown error occurred. Please try later."
        }
    }
    
    public var failureReason: String? {
        context.description
    }
}

extension YTError {
    static func asyncWrapper<T>(_ code: () async throws -> T) async throws -> T {
        do {
            return try await code()
        } catch {
            if let error = error as? YTError {
                throw error
            }
            throw YTError.unknown(context: YTError.Context(underlyingError: error))
        }
    }
    
    static func wrapper<T>(_ code: () throws -> T) throws -> T {
        do {
            return try code()
        } catch {
            if let error = error as? YTError {
                throw error
            }
            throw YTError.unknown(context: YTError.Context(underlyingError: error))
        }
    }
}
