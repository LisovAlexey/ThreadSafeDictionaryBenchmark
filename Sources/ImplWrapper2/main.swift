import CollectionsBenchmark

var benchmark = Benchmark(title: "Demo Benchmark")

func benchmarkDictionaryCreation<Dictionary: DictProtocol>(_ keys: [Dictionary.Key],
                                                           _ values: [Dictionary.Value],
                                                           _ dict: inout Dictionary) {
    for (key, value) in zip(keys, values) {
        dict[key] = value
    }
}

benchmark.addSimple(
    title: "System dict with extension",
    input: ([Int], [Int]).self
) { keys, values in

    var dict = [Int: Int]()
    benchmarkDictionaryCreation(keys, values, &dict)
}

benchmark.addSimple(
    title: "UserDict with extension",
    input: ([Int], [Int]).self
) { keys, values in
    var dict = ThreadSafeDictionary(from: [Int: Int]())
    
    benchmarkDictionaryCreation(keys, values, &dict)
}


protocol DictProtocol {
    associatedtype Key: Hashable & Equatable
    associatedtype Value
    
    mutating func removeAll(keepingCapacity: Bool)
    mutating func removeValue(forKey key: Key) -> Value?
    
    subscript(_ key: Key) -> Value? {get set }
    
    var count: Int { get }
}

extension Dictionary: DictProtocol {
    typealias Key = Key
    typealias Value = Value
}



final class ThreadSafeDictionary<Key: Hashable & Equatable, Value>: DictProtocol {

    var _dict: Dictionary<Key, Value>

    init(from dict: Dictionary<Key, Value>) {
        self._dict = dict
    }

    func removeAll(keepingCapacity: Bool) {
        _dict.removeAll(keepingCapacity: keepingCapacity)
    }

    func removeValue(forKey key: Key) -> Value? {
        _dict.removeValue(forKey: key)
    }

    subscript(_ key: Key) -> Value? {
        get {
            _dict[key]
        }
        set {
            _dict[key] = newValue
        }
    }

    var count: Int {
        _dict.count
    }
}

benchmark.main()
