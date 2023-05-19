import CollectionsBenchmark
import Foundation

var benchmark = Benchmark(title: "Demo Benchmark")

func benchmarkDictionaryCreation<Dictionary: DictProtocol>(_ keys: [Dictionary.Key],
                                                           _ values: [Dictionary.Value],
                                                           _ dict: inout Dictionary) {
    for (key, value) in zip(keys, values) {
        dict[key] = value
    }
    
    for key in keys.shuffled() {
        _ = dict.removeValue(forKey: key)
    }
}


benchmark.addSimple(
    title: "ThreadSafeUserDict Concurrent Queue, sync + async(.barrier)",
    input: ([Int], [Int]).self
) { keys, values in
    var dict = ThreadSafeUserDict(from: [Int: Int]())
    
    benchmarkDictionaryCreation(keys, values, &dict)
}

benchmark.addSimple(
    title: "ThreadSafeUserDict - Struct Atomic",
    input: ([Int], [Int]).self
) { keys, values in
    var dict = ThreadSafeUserDictStructAtomic(from: [Int: Int]())
    
    benchmarkDictionaryCreation(keys, values, &dict)
}

benchmark.addSimple(
    title: "ThreadSafeUserDict - Class Atomic",
    input: ([Int], [Int]).self
) { keys, values in
    var dict = ThreadSafeUserDictClassAtomic(from: [Int: Int]())
    
    benchmarkDictionaryCreation(keys, values, &dict)
}

benchmark.addSimple(
    title: "ThreadSafeUserDict - Class Atomic Clean",
    input: ([Int], [Int]).self
) { keys, values in
    var dict = ThreadSafeUserDictClassAtomicClean(from: [Int: Int]())
    
    benchmarkDictionaryCreation(keys, values, &dict)
}

protocol DictProtocol {
    associatedtype Key: Hashable & Equatable
    associatedtype Value
    
    mutating func removeAll(keepingCapacity: Bool)
    mutating func removeValue(forKey key: Key) -> Value?
    
    subscript(_ key: Key) -> Value? { get set }
    
    var count: Int { get }
}

extension Dictionary: DictProtocol {
    typealias Key = Key
    typealias Value = Value
}



final class ThreadSafeUserDict<Key: Hashable & Equatable, Value>: DictProtocol {
    
    var _dict: Dictionary<Key, Value>
    
    private let queue = DispatchQueue(
        label: "com.example.ThreadSafeDictionary",
        attributes: .concurrent
    )
    
    init(from dict: Dictionary<Key, Value>) {
        self._dict = dict
    }
    
    func removeAll(keepingCapacity: Bool) {
        queue.async(flags: .barrier) { [weak self] in
            self?._dict.removeAll(keepingCapacity: keepingCapacity)
        }
    }
    
    func removeValue(forKey key: Key) -> Value? {
        var value: Value?
        queue.sync { [weak self] in
            value = self?._dict.removeValue(forKey: key)
        }
        return value
    }
    
    subscript(_ key: Key) -> Value? {
        get {
            var value: Value?
            queue.sync {
                value = _dict[key]
            }
            return value
        }
        set {
            queue.async(flags: .barrier) { [weak self] in
                self?._dict[key] = newValue
            }
        }
    }
    
    var count: Int {
        queue.sync {
            _dict.count
        }
    }
}



// MARK: os_unfair_lock_lock
@propertyWrapper
struct StructAtomic<Value> {
    private var value: Value
    private var lock = os_unfair_lock()
    
    var wrappedValue: Value {
        mutating get {
            os_unfair_lock_lock(&lock)
            defer { os_unfair_lock_unlock(&lock) }
            return value
        }
        set {
            os_unfair_lock_lock(&lock)
            defer { os_unfair_lock_unlock(&lock) }
            value = newValue
        }
    }
    
    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
}

@propertyWrapper
class ClassAtomic<Value> {
    private var value: Value
    private var lock = os_unfair_lock()
    
    var wrappedValue: Value {
        get {
            os_unfair_lock_lock(&lock)
            defer { os_unfair_lock_unlock(&lock) }
            return value
        }
        set {
            os_unfair_lock_lock(&lock)
            defer { os_unfair_lock_unlock(&lock) }
            value = newValue
        }
    }
    
    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
}

@propertyWrapper
class ClassAtomicClean<Value> {
    private var value: Value
    
    var wrappedValue: Value {
        get {
            return value
        }
        set {
            value = newValue
        }
    }
    
    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
}


final class ThreadSafeUserDictStructAtomic<Key: Hashable & Equatable, Value>: DictProtocol {
    
    var _dict: StructAtomic<Dictionary<Key, Value>>
    
    private let queue = DispatchQueue(
        label: "com.example.ThreadSafeDictionary",
        attributes: .concurrent
    )
    
    init(from dict: Dictionary<Key, Value>) {
        self._dict = StructAtomic(wrappedValue: dict)
    }
    
    func removeAll(keepingCapacity: Bool) {
        _dict.wrappedValue.removeAll(keepingCapacity: keepingCapacity)
    }
    
    func removeValue(forKey key: Key) -> Value? {
        _dict.wrappedValue.removeValue(forKey: key)
    }
    
    subscript(_ key: Key) -> Value? {
        get {
            _dict.wrappedValue[key]
        }
        set {
            _dict.wrappedValue[key] = newValue
        }
    }
    
    var count: Int {
        _dict.wrappedValue.count
    }
}

final class ThreadSafeUserDictClassAtomic<Key: Hashable & Equatable, Value>: DictProtocol {
    
    var _dict: ClassAtomic<Dictionary<Key, Value>>
    
    private let queue = DispatchQueue(
        label: "com.example.ThreadSafeDictionary",
        attributes: .concurrent
    )
    
    init(from dict: Dictionary<Key, Value>) {
        self._dict = ClassAtomic(wrappedValue: dict)
    }
    
    func removeAll(keepingCapacity: Bool) {
        _dict.wrappedValue.removeAll(keepingCapacity: keepingCapacity)
    }
    
    func removeValue(forKey key: Key) -> Value? {
        _dict.wrappedValue.removeValue(forKey: key)
    }
    
    subscript(_ key: Key) -> Value? {
        get {
            _dict.wrappedValue[key]
        }
        set {
            _dict.wrappedValue[key] = newValue
        }
    }
    
    var count: Int {
        _dict.wrappedValue.count
    }
}

final class ThreadSafeUserDictClassAtomicClean<Key: Hashable & Equatable, Value>: DictProtocol {
    
    var _dict: ClassAtomicClean<Dictionary<Key, Value>>
    
    private let queue = DispatchQueue(
        label: "com.example.ThreadSafeDictionary",
        attributes: .concurrent
    )
    
    init(from dict: Dictionary<Key, Value>) {
        self._dict = ClassAtomicClean(wrappedValue: dict)
    }
    
    func removeAll(keepingCapacity: Bool) {
        _dict.wrappedValue.removeAll(keepingCapacity: keepingCapacity)
    }
    
    func removeValue(forKey key: Key) -> Value? {
        _dict.wrappedValue.removeValue(forKey: key)
    }
    
    subscript(_ key: Key) -> Value? {
        get {
            _dict.wrappedValue[key]
        }
        set {
            _dict.wrappedValue[key] = newValue
        }
    }
    
    var count: Int {
        _dict.wrappedValue.count
    }
}



benchmark.main()
