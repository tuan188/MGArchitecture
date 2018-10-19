import OrderedSet

public struct PagingInfo<T: Hashable> {
    public let page: Int
    public let items: OrderedSet<T>
}
