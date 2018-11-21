import OrderedSet

public struct PagingInfo<T> {
    public let page: Int
    public let items: [T]
    
    public init(page: Int, items: [T]) {
        self.page = page
        self.items = items
    }
}

extension PagingInfo where T: Hashable {
    public var itemSet: OrderedSet<T> {
        return OrderedSet(sequence: items)
    }
}
