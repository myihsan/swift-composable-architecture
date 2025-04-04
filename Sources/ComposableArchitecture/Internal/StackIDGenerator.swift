import Foundation

extension DependencyValues {
  @_spi(Internals) public var stackElementID: StackElementIDGenerator {
    get { self[StackElementIDGenerator.self] }
    set { self[StackElementIDGenerator.self] = newValue }
  }
}

@_spi(Internals) public struct StackElementIDGenerator: DependencyKey, Sendable {
  public let next: @Sendable (AnyHashable) -> StackElementID
  public let peek: @Sendable (AnyHashable) -> StackElementID

  @_spi(Internals)
  public func callAsFunction(for elementIdentifier: AnyHashable) -> StackElementID {
    self.next(elementIdentifier)
  }

  public static var liveValue: Self {
    let nextGeneration = LockIsolated(0)
    return Self(
      next: {
//        defer {
//          nextGeneration.withValue { $0 += 1 }
//        }
        return .init(generation: nextGeneration.value, elementIdentifier: $0)
      },
      peek: { .init(generation: nextGeneration.value, elementIdentifier: $0)}
    )
  }

  func incrementingCopy() -> Self {
    fatalError()
//    let peek = self.peek()
//    let next = LockIsolated(StackElementID(generation: peek.generation))
//    return Self(
//      next: {
//        defer {
//          next.withValue {
//            $0 = StackElementID(generation: $0.generation + 1)
//          }
//        }
//        return next.value
//      },
//      peek: { next.value }
//    )
  }
}
