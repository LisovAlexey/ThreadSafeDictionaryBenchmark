import CollectionsBenchmark

var benchmark = Benchmark(title: "Demo Benchmark")

benchmark.addSimple(
    title: "System dict creation",
    input: ([Int], [Int]).self
) { keys, values in
    var dict = [Int: Int]()
    for (key, value) in zip(keys, values) {
        dict[key] = value
    }
}

benchmark.addSimple(
    title: "UserDict creation",
    input: ([Int], [Int]).self
) { keys, values in
    var dict = ThreadSafeDictionary(from: [Int: Int]())
    for (key, value) in zip(keys, values) {
        dict[key] = value
    }
}

benchmark.addSimple(
    title: "UserDict protocoled creation",
    input: ([Int], [Int]).self
) { keys, values in
    var dict = ThreadSafeDictionaryProtocoled(from: [Int: Int]())
    for (key, value) in zip(keys, values) {
        dict[key] = value
    }
}

func benchmarkDictionaryCreation<Dictionary: DictProtocol>(_ keys: [Dictionary.Key],
                                                           _ values: [Dictionary.Value],
                                                           _ dict: inout Dictionary) {
    for (key, value) in zip(keys, values) {
        dict[key] = value
    }
}

benchmark.addSimple(
    title: "UserDict protocoled outer function creation",
    input: ([Int], [Int]).self
) { keys, values in
    var dict = ThreadSafeDictionaryProtocoled(from: [Int: Int]())
    
    benchmarkDictionaryCreation(keys, values, &dict)
}

protocol DictProtocol {
    associatedtype Key: Hashable & Equatable
    associatedtype Value
    
    func removeAll()
    func removeValue(forKey key: Key)
    
    subscript(_ key: Key) -> Value? {get set }
    
    var count: Int { get }
}



final class ThreadSafeDictionary<Key: Hashable & Equatable, Value> {

    var _dict: Dictionary<Key, Value>

    init(from dict: Dictionary<Key, Value>) {
        self._dict = dict
    }

    func removeAll() {
        _dict.removeAll()
    }

    func removeValue(forKey key: Key) {
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

final class ThreadSafeDictionaryProtocoled<Key: Hashable & Equatable, Value>: DictProtocol {
    
    var _dict: Dictionary<Key, Value>
    
    init(from dict: Dictionary<Key, Value>) {
        self._dict = dict
    }
    
    func removeAll() {
        _dict.removeAll()
    }
    
    func removeValue(forKey key: Key) {
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
