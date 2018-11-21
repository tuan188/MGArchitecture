import OrderedSet

public struct PagingInfo<T> {
    public let page: Int
    public let items: [T]
}

extension PagingInfo where T: Hashable {
    public var itemSet: OrderedSet<T> {
        return OrderedSet(sequence: items)
    }
}
