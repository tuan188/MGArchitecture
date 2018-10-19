public protocol HasID {
    associatedtype IDType
    var id: IDType { get }
}

extension Hashable where Self: HasID, Self.IDType == Int {
    public var hashValue: Int {
        return id
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Hashable where Self: HasID, Self.IDType == String {
    public var hashValue: Int {
        return id.hashValue
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
