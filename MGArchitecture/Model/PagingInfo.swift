import OrderedSet

public struct PagingInfo<T: Hashable> {
    public let page: Int
    public let items: OrderedSet<T>
    
    public init(page: Int, items: OrderedSet<T>) {
        self.page = page
        self.items = items
    }
}
